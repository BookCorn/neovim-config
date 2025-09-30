-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle file explorer" })

-- JetBrains-like LSP navigation
-- Note: Terminal Neovim usually cannot receive Command (⌘) keys, so we use Alt (⌥) as a close analogue
local lsp = vim.lsp.buf

-- Go to declaration/definition (IDEA: Cmd-B)
vim.keymap.set("n", "<A-b>", function()
  if lsp.definition then lsp.definition() end
end, { desc = "LSP: Go to definition" })

-- Find usages (IDEA: Alt-F7)
vim.keymap.set("n", "<A-r>", function()
  if lsp.references then lsp.references() end
end, { desc = "LSP: Find references" })

-- Go to implementation (IDEA: Cmd-Alt-B)
vim.keymap.set("n", "<A-i>", function()
  if lsp.implementation then lsp.implementation() end
end, { desc = "LSP: Go to implementation" })

-- Go to type definition (IDEA: Ctrl-Shift-B)
vim.keymap.set("n", "<A-t>", function()
  if lsp.type_definition then lsp.type_definition() end
end, { desc = "LSP: Go to type definition" })

-- Also enable in Visual mode to query at cursor
vim.keymap.set({ "n", "v" }, "K", function()
  if lsp.hover then lsp.hover() end
end, { desc = "LSP: Hover documentation" })

-- Parameter Info (IDEA: Ctrl-P)
-- Extend to Visual mode for consistency (uses cursor position)
vim.keymap.set({ "i", "n", "v" }, "<A-p>", function()
  if lsp.signature_help then lsp.signature_help() end
end, { desc = "LSP: Signature help" })
