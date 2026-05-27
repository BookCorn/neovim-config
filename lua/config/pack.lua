local function gh(repo)
  return "https://github.com/" .. repo
end

local specs = {
  gh("folke/which-key.nvim"),
  gh("lewis6991/gitsigns.nvim"),
  gh("folke/flash.nvim"),
  gh("ellisonleao/gruvbox.nvim"),
  gh("stevearc/conform.nvim"),
  gh("nvim-telescope/telescope.nvim"),
  gh("neovim/nvim-lspconfig"),
  gh("nvim-treesitter/nvim-treesitter"),
  gh("mbbill/undotree"),
  gh("nvim-mini/mini.pairs"),
  gh("kylechui/nvim-surround"),
  gh("gbprod/yanky.nvim"),
  gh("nvim-lua/plenary.nvim"),
}

vim.pack.add(specs, {
  load = function() end,
})

if vim.fn.exists(":PackUpdate") == 0 then
  vim.api.nvim_create_user_command("PackUpdate", function()
    vim.pack.update()
  end, { desc = "Update plugins managed by vim.pack" })
end
