local M = {}

local function termcodes(keys)
  return vim.api.nvim_replace_termcodes(keys, true, true, true)
end

function M.expr()
  local ok_blink, blink = pcall(require, "blink.cmp")
  if ok_blink and blink.is_visible and blink.is_visible() then
    blink.accept()
    return ""
  end

  local ok_cmp, cmp = pcall(require, "cmp")
  if ok_cmp and cmp.visible() then
    cmp.confirm({ select = true })
    return ""
  end

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
