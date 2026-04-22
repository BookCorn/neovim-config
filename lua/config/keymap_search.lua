local M = {}

local MODES = { "n", "i", "v", "x", "s", "o", "c", "t" }

local function normalize(text)
  return (text or ""):lower()
end

local function mode_label(mode)
  local labels = {
    n = "NORMAL",
    i = "INSERT",
    v = "VISUAL",
    x = "VISUAL",
    s = "SELECT",
    o = "OPERATOR",
    c = "COMMAND",
    t = "TERMINAL",
  }
  return labels[mode] or mode
end

local function item_label(item)
  local detail = item.desc ~= "" and item.desc or item.rhs
  return string.format("[%s] %s  %s", mode_label(item.mode), item.lhs, detail)
end

local function collect_maps()
  local items = {}

  for _, mode in ipairs(MODES) do
    for _, map in ipairs(vim.api.nvim_get_keymap(mode)) do
      items[#items + 1] = {
        mode = mode,
        lhs = map.lhs or "",
        rhs = map.rhs or "",
        desc = map.desc or "",
        buffer = false,
      }
    end

    for _, map in ipairs(vim.api.nvim_buf_get_keymap(0, mode)) do
      items[#items + 1] = {
        mode = mode,
        lhs = map.lhs or "",
        rhs = map.rhs or "",
        desc = map.desc or "",
        buffer = true,
      }
    end
  end

  table.sort(items, function(a, b)
    if a.mode == b.mode then
      return a.lhs < b.lhs
    end
    return a.mode < b.mode
  end)

  return items
end

local function filter_maps(items, query)
  if query == "" then
    return items
  end

  local needle = normalize(query)
  local matches = {}

  for _, item in ipairs(items) do
    local haystack = table.concat({
      normalize(item.mode),
      normalize(item.lhs),
      normalize(item.desc),
      normalize(item.rhs),
    }, " ")

    if haystack:find(needle, 1, true) then
      matches[#matches + 1] = item
    end
  end

  return matches
end

function M.search()
  vim.ui.input({ prompt = "Search keymaps: " }, function(input)
    if input == nil then
      return
    end

    local matches = filter_maps(collect_maps(), vim.trim(input))
    if #matches == 0 then
      vim.notify("No keymaps matched: " .. input, vim.log.levels.INFO)
      return
    end

    vim.ui.select(matches, {
      prompt = "Matching keymaps",
      format_item = item_label,
    }, function(choice)
      if not choice then
        return
      end

      local lines = {
        string.format("mode: %s", mode_label(choice.mode)),
        string.format("lhs: %s", choice.lhs),
      }
      if choice.desc ~= "" then
        lines[#lines + 1] = string.format("desc: %s", choice.desc)
      end
      if choice.rhs ~= "" then
        lines[#lines + 1] = string.format("rhs: %s", choice.rhs)
      end
      if choice.buffer then
        lines[#lines + 1] = "scope: buffer-local"
      end

      vim.notify(table.concat(lines, "\n"), vim.log.levels.INFO, { title = "Keymap" })
    end)
  end)
end

return M
