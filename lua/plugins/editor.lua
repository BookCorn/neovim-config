return {
  {
    "ThePrimeagen/refactoring.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "<leader>re",
        function()
          require("refactoring").select_refactor()
        end,
        mode = { "v" },
        desc = "Refactor (select)",
      },
    },
  },
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      filetypes = {
        "css",
        "scss",
        "sass",
        "html",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "svelte",
        "vue",
        "astro",
      },
      user_default_options = {
        tailwind = true,
      },
    },
  },
  {
    "mbbill/undotree",
    cmd = { "UndotreeToggle", "UndotreeShow" },
    keys = {
      { "<leader>uu", "<cmd>UndotreeToggle<CR>", desc = "Toggle undotree" },
    },
  },
}
