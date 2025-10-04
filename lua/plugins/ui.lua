return {
  {
    "nvim-tree/nvim-tree.lua",
    event = "VeryLazy",
    config = function()
      require("nvim-tree").setup()
    end,
  },
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      require("lualine").setup({
        options = { theme = "gruvbox" },
      })
    end,
  },
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin-macchiato")
    end,
  },
  {
    "vyfor/cord.nvim",
    build = ":Cord update",
    event = "VeryLazy",
    config = function()
      require("cord").setup({})
    end,
  },
}
