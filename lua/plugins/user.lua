return {
  { import = "plugins.syntax" },
  { import = "plugins.ui" },
  { import = "plugins.editor" },
  { import = "plugins.testing" },
  {
    "kawre/leetcode.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "MunifTanjim/nui.nvim",
    },
    opts = {
      lang = "rust",

      cn = { -- leetcode.cn
        enabled = true, ---@type boolean
        translator = true, ---@type boolean
        translate_problems = true, ---@type boolean
      },
      storage = {
        home = vim.fn.stdpath("data") .. "/leetcode",
        cache = vim.fn.stdpath("cache") .. "/leetcode",
      },
    },
  },
}
