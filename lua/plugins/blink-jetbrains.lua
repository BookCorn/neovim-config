-- Configure blink.cmp to behave closer to JetBrains
-- - <Tab>: accept completion (or Copilot ghost) when appropriate; fallback otherwise
-- - <CR>: accept completion when the menu is visible, otherwise newline
-- - <C-Space>: manual completion trigger (like IDEA)
-- - <C-y>: accept completion explicitly when the menu is visible
-- - Sources: LSP, snippets, path, buffer
-- - Enable signature help and docs popup
return {
  "saghen/blink.cmp",
  opts = function(_, opts)
    opts = opts or {}

    -- Appearance similar to nvim-cmp (icons, menu labels)
    opts.appearance = opts.appearance or {}
    opts.appearance.use_nvim_cmp_as_default = true

    -- Sources: show a broad set like JetBrains
    opts.sources = opts.sources or {}
    opts.sources.default = { "lsp", "snippets", "path", "buffer" }

    -- Completion behavior: don’t auto-commit; show menu and let user confirm
    opts.completion = opts.completion or {}
    opts.completion.list = opts.completion.list or {}
    opts.completion.list.selection = opts.completion.list.selection or {}
    -- Show the menu even with a single item, and do not pre-insert
    opts.completion.menu = opts.completion.menu or {}
    opts.completion.menu.auto_show = true
    opts.completion.accept = opts.completion.accept or {}
    opts.completion.accept.auto_brackets = { enabled = false }

    -- Keep defaults for signature/docs to follow blink.cmp schema

    -- Keymaps: JetBrains-like flow with Copilot integration
    opts.keymap = opts.keymap or {}
    opts.keymap.preset = "none"

    local function feed(keys)
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
    end

    local function copilot_accept_if_visible()
      local ok, suggestion = pcall(require, "copilot.suggestion")
      if ok and suggestion.is_visible() then
        suggestion.accept()
        return true
      end
      return false
    end

    local function cmp_is_visible()
      local ok, cmp = pcall(require, "blink.cmp")
      if not ok or not cmp.is_visible then
        return false, nil
      end
      return cmp.is_visible(), cmp
    end

    local function accept_cmp()
      local visible, cmp = cmp_is_visible()
      if visible then
        cmp.accept()
        return true
      end
      return false
    end

    local function map_tab()
      if copilot_accept_if_visible() then
        return
      end
      if accept_cmp() then
        return
      end
      feed("<Tab>")
    end

    local function map_cr_accept_or_newline()
      if accept_cmp() then
        return
      end
      feed("<CR>")
    end

    local function map_accept_on_ctrl_y()
      if accept_cmp() then
        return
      end
      feed("<C-y>")
    end

    local function map_select_next()
      local visible, cmp = cmp_is_visible()
      if visible and cmp.select_next then
        cmp.select_next()
      else
        feed("<Down>")
      end
    end

    local function map_select_prev()
      local visible, cmp = cmp_is_visible()
      if visible and cmp.select_prev then
        cmp.select_prev()
      else
        feed("<Up>")
      end
    end

    -- Set explicit mappings in insert/select mode
    vim.keymap.set({ "i", "s" }, "<Tab>", map_tab, { desc = "Accept completion or Copilot suggestion" })
    vim.keymap.set({ "i", "s" }, "<CR>", map_cr_accept_or_newline, { desc = "Accept completion or newline" })
    vim.keymap.set({ "i", "s" }, "<C-y>", map_accept_on_ctrl_y, { desc = "Accept completion" })
    vim.keymap.set({ "i", "s" }, "<C-Space>", function()
      local ok, cmp = pcall(require, "blink.cmp")
      if ok and cmp.show then
        cmp.show()
      end
    end, { desc = "Manual completion" })
    vim.keymap.set({ "i", "s" }, "<Down>", map_select_next, { desc = "Next completion item or cursor down" })
    vim.keymap.set({ "i", "s" }, "<Up>", map_select_prev, { desc = "Prev completion item or cursor up" })

    return opts
  end,
}
