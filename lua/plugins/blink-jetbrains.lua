-- Configure blink.cmp to behave closer to JetBrains
-- - <Tab>: accept completion only when the menu is visible; otherwise fallback
-- - <CR>: do not accept completion, keep default newline behavior
-- - <C-Space>: manual completion trigger (like IDEA)
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

    -- Keymaps: JetBrains-like acceptance on <Tab>/<CR>; arrow keys navigate menu
    opts.keymap = opts.keymap or {}
    opts.keymap.preset = "none"
    -- Use a small helper to keep compatibility across versions
    local function map_accept_on_tab()
      local ok, cmp = pcall(require, "blink.cmp")
      if not ok then return end
      if cmp.is_visible and cmp.is_visible() then
        cmp.accept()
      else
        -- Fallback to literal <Tab>
        local keys = vim.api.nvim_replace_termcodes("<Tab>", true, false, true)
        vim.api.nvim_feedkeys(keys, "n", false)
      end
    end
    local function map_cr_accept_or_newline()
      local ok, cmp = pcall(require, "blink.cmp")
      if ok and cmp.is_visible and cmp.is_visible() then
        cmp.accept()
      else
        local keys = vim.api.nvim_replace_termcodes("<CR>", true, false, true)
        vim.api.nvim_feedkeys(keys, "n", false)
      end
    end
    local function map_select_next()
      local ok, cmp = pcall(require, "blink.cmp")
      if ok and cmp.is_visible and cmp.is_visible() and cmp.select_next then
        cmp.select_next()
      else
        local keys = vim.api.nvim_replace_termcodes("<Down>", true, false, true)
        vim.api.nvim_feedkeys(keys, "n", false)
      end
    end
    local function map_select_prev()
      local ok, cmp = pcall(require, "blink.cmp")
      if ok and cmp.is_visible and cmp.is_visible() and cmp.select_prev then
        cmp.select_prev()
      else
        local keys = vim.api.nvim_replace_termcodes("<Up>", true, false, true)
        vim.api.nvim_feedkeys(keys, "n", false)
      end
    end

    -- Set explicit mappings in insert/select mode
    vim.keymap.set({ "i", "s" }, "<Tab>", map_accept_on_tab, { desc = "Accept completion or insert Tab" })
    vim.keymap.set({ "i", "s" }, "<CR>", map_cr_accept_or_newline, { desc = "Accept completion or newline" })
    vim.keymap.set({ "i", "s" }, "<C-Space>", function()
      local ok, cmp = pcall(require, "blink.cmp")
      if ok and cmp.show then cmp.show() end
    end, { desc = "Manual completion" })
    vim.keymap.set({ "i", "s" }, "<Down>", map_select_next, { desc = "Next completion item or cursor down" })
    vim.keymap.set({ "i", "s" }, "<Up>", map_select_prev, { desc = "Prev completion item or cursor up" })

    return opts
  end,
}
