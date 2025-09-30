return {
  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    build = ":Copilot auth",
    event = "InsertEnter",
    opts = {
      panel = { enabled = false },
      suggestion = {
        auto_trigger = true,
        debounce = 75,
        keymap = {
          accept = false,
          accept_word = false,
          accept_line = false,
          next = "<M-]>",
          prev = "<M-[>",
          dismiss = "<C-]>",
        },
      },
      filetypes = {
        markdown = true,
        gitcommit = true,
        help = true,
      },
    },
  },
  {
    "zbirenbaum/copilot.lua",
    opts = function()
      vim.keymap.set("i", "<C-l>", function()
        local ok, suggestion = pcall(require, "copilot.suggestion")
        if ok and suggestion.is_visible() then
          suggestion.accept()
          return
        end
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-l>", true, false, true), "n", false)
      end, { desc = "Copilot accept suggestion" })
    end,
  },
  {
    "saghen/blink.cmp",
    optional = true,
    dependencies = { "fang2hou/blink-copilot" },
    opts = function(_, opts)
      opts = opts or {}
      opts.sources = opts.sources or {}
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.copilot = opts.sources.providers.copilot
        or {
          name = "copilot",
          module = "blink-copilot",
          score_offset = 100,
          async = true,
        }

      local defaults = opts.sources.default or {}
      local has_copilot = false
      for _, name in ipairs(defaults) do
        if name == "copilot" then
          has_copilot = true
          break
        end
      end
      if not has_copilot then
        table.insert(defaults, 1, "copilot")
      end
      opts.sources.default = defaults

      return opts
    end,
  },
}
