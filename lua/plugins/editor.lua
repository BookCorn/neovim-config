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
    "nvim-mini/mini.pairs",
    opts = function(_, opts)
      opts = opts or {}
      opts.mappings = opts.mappings or {}
      local function ensure(pair)
        opts.mappings[pair] = opts.mappings[pair] or {}
      end
      ensure("(")
      ensure("{")
      ensure("[")
    end,
    config = function(_, opts)
      LazyVim.mini.pairs(opts)
      local pairs = { ["("] = ")", ["{"] = "}", ["["] = "]" }
      local function smart_cr()
        -- blink.cmp completion
        local ok_blink, blink = pcall(require, "blink.cmp")
        if ok_blink and blink.is_visible() then
          blink.select_and_accept()
          return ""
        end

        -- nvim-cmp completion
        local ok_cmp, cmp = pcall(require, "cmp")
        if ok_cmp and cmp.visible() then
          cmp.confirm({ select = true })
          return ""
        end

        if vim.fn.pumvisible() == 1 then
          return vim.api.nvim_replace_termcodes("<C-y>", true, true, true)
        end

        local col = vim.api.nvim_win_get_cursor(0)[2]
        local line = vim.api.nvim_get_current_line()
        local prev = col > 0 and line:sub(col, col) or ""
        local next = line:sub(col + 1, col + 1)
        if pairs[prev] == next then
          return require("mini.pairs").cr()
        end
        return vim.api.nvim_replace_termcodes("<CR>", true, true, true)
      end
      vim.keymap.set("i", "<CR>", smart_cr, {
        expr = true,
        replace_keycodes = false,
        desc = "Smart newline inside pairs",
      })
    end,
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

      local function with_virtual_cursors()
        local ok, vc = pcall(require, "multiple-cursors.virtual_cursors")
        if not ok then
          return nil
        end
        return vc
      end

      local common = require("multiple-cursors.common")

      local function ensure_lock_state(should_lock)
        local vc = with_virtual_cursors()
        if not vc then
          return
        end
        if vc.get_num_virtual_cursors() == 0 then
          return
        end
        if vc.is_locked() ~= should_lock then
          vc.toggle_lock()
        end
      end

      local function exec(name, after)
        return function()
          vim.cmd(name)
          if after then
            after()
          end
        end
      end

      local function relock_if_normal()
        if vim.api.nvim_get_mode().mode:sub(1, 1) == "n" then
          ensure_lock_state(true)
        end
      end

      local function add_cursor_step(direction)
        local vc = with_virtual_cursors()
        if not vc then
          return
        end

        local mode = vim.api.nvim_get_mode().mode
        local head = mode:sub(1, 1)
        local is_visual = head == "v" or head == "V" or head == "\22" or head == "s" or head == "S" or head == "\19"

        if is_visual then
          local l1, c1, l2, c2 = common.get_normalised_visual_area()
          mc.init()
          vc.add_with_visual_area(l2, c2, c2, l1, c1, true)
          vim.cmd("normal! <Esc>")
          head = "n"
        else
          local pos = vim.fn.getcurpos()
          mc.add_cursor(pos[2], pos[3], pos[5])
        end

        if head == "n" then
          ensure_lock_state(true)
        end

        local motion = direction and direction < 0 and "b" or "w"
        vim.cmd("normal! " .. motion)
      end

      local add_next_word = function()
        add_cursor_step(1)
      end

      local add_prev_word = function()
        add_cursor_step(-1)
      end

      set(
        { "n", "x" },
        "<leader>mk",
        exec("MultipleCursorsAddUp", relock_if_normal),
        { desc = "Multi: add cursor above", silent = true }
      )
      set(
        { "n", "x" },
        "<leader>mj",
        exec("MultipleCursorsAddDown", relock_if_normal),
        { desc = "Multi: add cursor below", silent = true }
      )

      set({ "n", "x" }, "<leader>mn", add_next_word, { desc = "Multi: add cursor then move forward", silent = true })
      set({ "n", "x" }, "<leader>mN", add_prev_word, { desc = "Multi: add cursor then move backward", silent = true })
      set(
        { "n", "x" },
        "<leader>ms",
        exec("MultipleCursorsJumpNextMatch"),
        { desc = "Multi: skip next match", silent = true }
      )
      set(
        { "n", "x" },
        "<leader>mS",
        exec("MultipleCursorsJumpPrevMatch"),
        { desc = "Multi: skip previous match", silent = true }
      )

      set(
        { "n", "x" },
        "<leader>mA",
        exec("MultipleCursorsAddMatches", relock_if_normal),
        { desc = "Multi: add cursors to matches", silent = true }
      )

      set({ "n", "x" }, "<leader>mm", exec("MultipleCursorsLock"), { desc = "Multi: toggle lock", silent = true })

      local clear = function()
        mc.deinit(true)
      end

      set({ "n", "x" }, "<leader>mc", clear, { desc = "Multi: clear cursors" })

      set(
        { "n", "i" },
        "<C-LeftMouse>",
        exec("MultipleCursorsMouseAddDelete", relock_if_normal),
        { desc = "Multi: add/remove cursor", silent = true }
      )

      set({ "n", "x" }, "<C-i>", add_next_word, { desc = "Multi: add cursor then move forward (Alt-n)", silent = true })

      local unlock_modes = {
        i = true,
        v = true,
        V = true,
        R = true,
        s = true,
        S = true,
      }
      unlock_modes["\22"] = true -- visual block
      unlock_modes["\19"] = true -- select block

      local group = vim.api.nvim_create_augroup("MultiCursorAutoLock", { clear = true })
      vim.api.nvim_create_autocmd("ModeChanged", {
        group = group,
        callback = function()
          local vc = with_virtual_cursors()
          if not vc or vc.get_num_virtual_cursors() == 0 then
            return
          end
          local mode = vim.api.nvim_get_mode().mode
          local head = mode:sub(1, 1)
          if head == "n" then
            ensure_lock_state(true)
          elseif unlock_modes[head] then
            ensure_lock_state(false)
          end
        end,
        desc = "Auto-lock multiple cursors in normal mode",
      })
    end,
  },
}
