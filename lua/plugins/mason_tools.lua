return {
  {
    "mason-org/mason.nvim",
    dependencies = {
      {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = {
          ensure_installed = {
            "css-lsp",
            "html-lsp",
            "json-lsp",
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
