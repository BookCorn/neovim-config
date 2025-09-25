return {
  "rmagatti/goto-preview",
  event = "LspAttach",
  config = function()
    require("goto-preview").setup({
      default_mappings = false,
      focus_on_open = true,
      dismiss_on_move = true,
      resizing_mappings = false,
      opacity = nil,
      height = 20,
      width = 80,
      border = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
    })

    -- Quick Definition / Quick Type Definition like IDEA's quick view (Ctrl-Shift-I)
    vim.keymap.set("n", "<A-d>", require("goto-preview").goto_preview_definition, {
      desc = "Preview definition",
    })
    vim.keymap.set("n", "<A-D>", require("goto-preview").goto_preview_type_definition, {
      desc = "Preview type definition",
    })
    vim.keymap.set("n", "<A-esc>", require("goto-preview").close_all_win, {
      desc = "Close all previews",
    })
  end,
}

