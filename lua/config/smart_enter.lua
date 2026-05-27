local M = {}

local function termcodes(keys)
  return vim.api.nvim_replace_termcodes(keys, true, true, true)
end

function M.expr()
  if vim.fn.pumvisible() == 1 then
    return termcodes("<C-y>")
  end

  local ok_pairs, mini_pairs = pcall(require, "mini.pairs")
  if ok_pairs and mini_pairs.cr then
    return mini_pairs.cr()
  end

  return termcodes("<CR>")
end

return M
