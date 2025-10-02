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
  {
    "brenton-leighton/multiple-cursors.nvim",
    branch = "main",
    event = "VeryLazy",
    opts = {},
    config = function(_, opts)
      local mc = require("multiple-cursors")
      mc.setup(opts)

      local set = vim.keymap.set
      local function cmd(name)
        return "<Cmd>" .. name .. "<CR>"
      end

      set({ "n", "x" }, "<leader>mk", cmd("MultipleCursorsAddUp"), { desc = "Multi: add cursor above" })
      set({ "n", "x" }, "<leader>mj", cmd("MultipleCursorsAddDown"), { desc = "Multi: add cursor below" })

      set({ "n", "x" }, "<leader>mn", cmd("MultipleCursorsAddJumpNextMatch"), { desc = "Multi: add next match cursor" })
      set({ "n", "x" }, "<leader>mN", cmd("MultipleCursorsAddJumpPrevMatch"), { desc = "Multi: add previous match cursor" })

      set({ "n", "x" }, "<leader>ms", cmd("MultipleCursorsJumpNextMatch"), { desc = "Multi: skip next match" })
      set({ "n", "x" }, "<leader>mS", cmd("MultipleCursorsJumpPrevMatch"), { desc = "Multi: skip previous match" })

      set({ "n", "x" }, "<leader>mA", cmd("MultipleCursorsAddMatches"), { desc = "Multi: add cursors to matches" })

      set({ "n", "x" }, "<leader>mm", cmd("MultipleCursorsLock"), { desc = "Multi: toggle lock" })

      set({ "n", "x" }, "<leader>mc", function()
        mc.deinit(true)
      end, { desc = "Multi: clear cursors" })

      set({ "n", "i" }, "<C-LeftMouse>", cmd("MultipleCursorsMouseAddDelete"), { desc = "Multi: add/remove cursor" })
    end,
  },
}
