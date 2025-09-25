return {
  {
    "williamboman/mason.nvim",
    dependencies = { "WhoIsSethDaniel/mason-tool-installer.nvim" },
    opts = function(_, opts)
      -- keep existing mason opts and append tool installer setup
      local ok, tool_installer = pcall(require, "mason-tool-installer")
      if not ok then return opts end
      tool_installer.setup {
        ensure_installed = {
          -- LSP servers (installed via mason)
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

          -- Formatters / Linters
          "prettierd",
          "prettier",
          "eslint_d",
        },
        auto_update = false,
        run_on_start = true,
      }
      return opts
    end,
  },
}

