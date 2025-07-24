return {
  -- ======= NVIM-TREESITTER =======
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "c", "cpp", "java", "go", "python", "rust", "lua", "vim" },
      highlight = { enable = true, additional_vim_regex_highlighting = false },
      indent = { enable = true },
      auto_install = true,
    },
    event = { "BufReadPost", "BufNewFile" },
  },

  -- ======= NVIM-LSPCONFIG FOR JAVA/GO/PYTHON/RUST/C =======
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      servers = {
        -- Java
        jdtls = {},
        -- Go
        gopls = {},
        -- Rust
        rust_analyzer = {},
        -- Python
        pyright = {},
        -- C/C++
        clangd = {},
      },
    },
  },

  -- ======= Autocompletion (nvim-cmp) =======
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
    },
    event = "InsertEnter",
    opts = {},
  },

  -- ======= 文件浏览 (nvim-tree) =======
  {
    "nvim-tree/nvim-tree.lua",
    event = "VeryLazy",
    config = function()
      require("nvim-tree").setup()
    end,
  },

  -- ======= 状态栏 (lualine) =======
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      require("lualine").setup({
        options = { theme = "gruvbox" }, -- or 'auto' or any modern theme
      })
    end,
  },

  -- ======= 配色方案 (推荐 catppuccin / gruvbox) =======
  -- 提升美观和舒适度
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin-macchiato")
    end,
  },
}
