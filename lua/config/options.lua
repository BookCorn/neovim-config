-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.o.completeopt = "menu,menuone,noselect"
vim.o.shortmess = vim.o.shortmess .. "c"

-- keep Neovim clipboard separate from system clipboard; use `"+` register when needed
vim.opt.clipboard = {}
vim.opt.smoothscroll = false
vim.g.snacks_scroll = false
