return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = {
        -- base
        "c",
        "cpp",
        "java",
        "go",
        "python",
        "rust",
        "lua",
        "vim",
        -- web/frontend
        "html",
        "css",
        "javascript",
        "typescript",
        "tsx",
        "json",
        "svelte",
        -- markdown inline rendering support
        "markdown",
        "markdown_inline",
      },
      highlight = { enable = true, additional_vim_regex_highlighting = false },
      indent = { enable = true },
      auto_install = true,
    },
    event = { "BufReadPost", "BufNewFile" },
  },
}
