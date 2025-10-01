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
    "jake-stewart/multicursor.nvim",
    branch = "1.0",
    event = "VeryLazy",
    config = function()
      local mc = require("multicursor-nvim")
      mc.setup()

      local set = vim.keymap.set

      set({ "n", "x" }, "<leader>mk", function()
        mc.lineAddCursor(-1)
      end, { desc = "Multi: add cursor above" })

      set({ "n", "x" }, "<leader>mj", function()
        mc.lineAddCursor(1)
      end, { desc = "Multi: add cursor below" })

      set({ "n", "x" }, "<leader>mn", function()
        mc.matchAddCursor(1)
      end, { desc = "Multi: add next match cursor" })

      set({ "n", "x" }, "<leader>mN", function()
        mc.matchAddCursor(-1)
      end, { desc = "Multi: add previous match cursor" })

      set({ "n", "x" }, "<leader>ms", function()
        mc.matchSkipCursor(1)
      end, { desc = "Multi: skip next match" })

      set({ "n", "x" }, "<leader>mS", function()
        mc.matchSkipCursor(-1)
      end, { desc = "Multi: skip previous match" })

      set({ "n", "x" }, "<leader>mA", mc.matchAllAddCursors, { desc = "Multi: add cursors to all matches" })

      set({ "n", "x" }, "<leader>mm", mc.toggleCursor, { desc = "Multi: toggle cursor enable" })

      set({ "n", "x" }, "<leader>mc", function()
        if mc.hasCursors() then
          mc.clearCursors()
        end
      end, { desc = "Multi: clear cursors" })

      set("n", "<C-LeftMouse>", mc.handleMouse, { desc = "Multi: add cursor with mouse" })
      set("n", "<C-LeftDrag>", mc.handleMouseDrag, { desc = "Multi: drag multi cursor selection" })
      set("n", "<C-LeftRelease>", mc.handleMouseRelease, { desc = "Multi: finish multi cursor drag" })

      mc.addKeymapLayer(function(layerSet)
        layerSet({ "n", "x" }, "<leader>m,", mc.prevCursor)
        layerSet({ "n", "x" }, "<leader>m.", mc.nextCursor)
        layerSet({ "n", "x" }, "<leader>mx", mc.deleteCursor)
        layerSet("n", "<esc>", function()
          if not mc.cursorsEnabled() then
            mc.enableCursors()
          else
            mc.clearCursors()
          end
        end)
      end)
    end,
  },
}
