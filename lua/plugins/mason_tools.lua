return {
  {
    "mason-org/mason.nvim",
    dependencies = {
      {
        "WhoIsSethDaniel/mason-tool-installer.nvim",
        opts = {
          -- Server profile: do not auto-install tools
          ensure_installed = {},
          auto_update = false,
          run_on_start = false,
        },
        config = function(_, opts)
          require("mason-tool-installer").setup(opts)
        end,
      },
    },
  },
}
