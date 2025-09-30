return {
  {
    "mason-org/mason.nvim",
    dependencies = {
      {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = {
          ensure_installed = {
            "svelte-language-server",
            "typescript-language-server",
            "tailwindcss-language-server",
            "emmet-ls",
            "css-lsp",
            "html-lsp",
            "json-lsp",
            "eslint-lsp",
            "vue-language-server",
            "astro-language-server",
            "prettierd",
            "prettier",
            "eslint_d",
          },
          auto_update = false,
          run_on_start = true,
        },
        config = function(_, opts)
          require("mason-tool-installer").setup(opts)
        end,
      },
    },
  },
}
