local group = vim.api.nvim_create_augroup("UserConfig", { clear = true })

vim.api.nvim_create_autocmd("TextYankPost", {
  group = group,
  desc = "Highlight text after yanking",
  callback = function()
    vim.hl.on_yank()
  end,
})
