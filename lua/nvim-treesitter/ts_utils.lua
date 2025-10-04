local api = vim.api

local ts = vim.treesitter

local M = {}

local function get_node_text(node, bufnr)
  bufnr = bufnr or api.nvim_get_current_buf()
  if not node then
    return {}
  end

  -- We have to remember that end_col is end-exclusive
  local start_row, start_col, end_row, end_col = ts.get_node_range(node)

  if start_row ~= end_row then
    local lines = api.nvim_buf_get_lines(bufnr, start_row, end_row + 1, false)
    if next(lines) == nil then
      return {}
    end
    lines[1] = string.sub(lines[1], start_col + 1)
    -- end_row might be just after the last line. In this case the last line is not truncated.
    if #lines == end_row - start_row + 1 then
      lines[#lines] = string.sub(lines[#lines], 1, end_col)
    end
    return lines
  else
    local line = api.nvim_buf_get_lines(bufnr, start_row, start_row + 1, false)[1]
    -- If line is nil then the line is empty
    return line and { string.sub(line, start_col + 1, end_col) } or {}
  end
end

---@private
---@param node TSNode
---@param type_patterns string[]
---@param transform_fn fun(line: string): string
---@param bufnr integer
---@return string
function M._get_line_for_node(node, type_patterns, transform_fn, bufnr)
  local node_type = node:type()
  local is_valid = false
  for _, rgx in ipairs(type_patterns) do
    if node_type:find(rgx) then
      is_valid = true
      break
    end
  end
  if not is_valid then
    return ""
  end
  local line = transform_fn(vim.trim(get_node_text(node, bufnr)[1] or ""), node)
  -- Escape % to avoid statusline to evaluate content as expression
  return line:gsub("%%", "%%%%")
end

-- Gets the actual text content of a node
-- @deprecated Use vim.treesitter.get_node_text
-- @param node the node to get the text from
-- @param bufnr the buffer containing the node
-- @return list of lines of text of the node
function M.get_node_text(node, bufnr)
  vim.notify_once(
    "nvim-treesitter.ts_utils.get_node_text is deprecated: use vim.treesitter.get_node_text",
    vim.log.levels.WARN
  )
  return get_node_text(node, bufnr)
end

-- Determines whether a node is the parent of another
-- @param dest the possible parent
-- @param source the possible child node
function M.is_parent(dest, source)
  if not (dest and source) then
    return false
  end

  local current = source
  while current ~= nil do
    if current == dest then
      return true
    end

    current = current:parent()
  end

  return false
end

-- Get next node with same parent
---@param node                  TSNode
---@param allow_switch_parents? boolean allow switching parents if last node
---@param allow_next_parent?    boolean allow next parent if last node and next parent without children
function M.get_next_node(node, allow_switch_parents, allow_next_parent)
  local destination_node ---@type TSNode
  local parent = node:parent()

  if not parent then
    return
  end
  local found_pos = 0
  for i = 0, parent:named_child_count() - 1, 1 do
    if parent:named_child(i) == node then
      found_pos = i
      break
    end
  end
  if parent:named_child_count() > found_pos + 1 then
    destination_node = parent:named_child(found_pos + 1)
  elseif allow_switch_parents then
    local next_node = M.get_next_node(node:parent())
    if next_node and next_node:named_child_count() > 0 then
      destination_node = next_node:named_child(0)
    elseif next_node and allow_next_parent then
      destination_node = next_node
    end
  end

  return destination_node
end

-- Get previous node with same parent
---@param node                   TSNode
---@param allow_switch_parents?  boolean allow switching parents if first node
---@param allow_previous_parent? boolean allow previous parent if first node and previous parent without children
function M.get_previous_node(node, allow_switch_parents, allow_previous_parent)
  local destination_node ---@type TSNode
  local parent = node:parent()
  if not parent then
    return
  end

  local found_pos = 0
  for i = 0, parent:named_child_count() - 1, 1 do
    if parent:named_child(i) == node then
      found_pos = i
      break
    end
  end
  if 0 < found_pos then
    destination_node = parent:named_child(found_pos - 1)
  elseif allow_switch_parents then
    local previous_node = M.get_previous_node(node:parent())
    if previous_node and previous_node:named_child_count() > 0 then
      destination_node = previous_node:named_child(previous_node:named_child_count() - 1)
    elseif previous_node and allow_previous_parent then
      destination_node = previous_node
    end
  end
  return destination_node
end

function M.get_named_children(node)
  local nodes = {} ---@type TSNode[]
  for i = 0, node:named_child_count() - 1, 1 do
    nodes[i + 1] = node:named_child(i)
  end
  return nodes
end

function M.get_node_at_cursor(winnr, ignore_injected_langs)
  winnr = winnr or 0
  local cursor = api.nvim_win_get_cursor(winnr)
  local cursor_range = { cursor[1] - 1, cursor[2] }

  local buf = vim.api.nvim_win_get_buf(winnr)
  local ok, parser = pcall(ts.get_parser, buf)
  if not ok then
    return
  end

  local root ---@type TSNode|nil
  if ignore_injected_langs then
    for _, tree in pairs(parser:trees()) do
      local tree_root = tree:root()
      if tree_root and ts.is_in_node_range(tree_root, cursor_range[1], cursor_range[2]) then
        root = tree_root
        break
      end
    end
  else
    root = M.get_root_for_position(cursor_range[1], cursor_range[2], parser)
  end

  if not root then
    return
  end

  return root:named_descendant_for_range(cursor_range[1], cursor_range[2], cursor_range[1], cursor_range[2])
end

function M.get_root_for_position(line, col, parser)
  if not parser then
    local ok, parsed = pcall(ts.get_parser, api.nvim_get_current_buf())
    if not ok then
      return
    end
    parser = parsed
  end

  local root ---@type TSNode
  for _, tree in pairs(parser:trees()) do
    local tree_root = tree:root()
    if tree_root and ts.is_in_node_range(tree_root, line, col) then
      root = tree_root
      break
    end
  end

  return root
end

function M.get_vim_range(range, bufnr, _)
  if not range or not range[1] then
    return
  end
  bufnr = bufnr or api.nvim_get_current_buf()
  local start_row, start_col, end_row, end_col = unpack(range)

  start_row = start_row + 1
  start_col = start_col + 1
  end_row = end_row + 1

  if end_col == 0 then
    end_row = end_row - 1
    local line = api.nvim_buf_get_lines(bufnr, end_row - 1, end_row, false)[1] or ""
    end_col = #line
  end

  return start_row, start_col, end_row, end_col
end

return M
