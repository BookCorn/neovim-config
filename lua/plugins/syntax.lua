return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        -- minimal parsers for server profile
        "lua",
        "vim",
        "vimdoc",
        "bash",
        "json",
        "yaml",
        "markdown",
        "markdown_inline",
      },
      highlight = { enable = true, additional_vim_regex_highlighting = false },
      indent = { enable = true },
      auto_install = false,
    },
    event = { "BufReadPost", "BufNewFile" },
  },
}
