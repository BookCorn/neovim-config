return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    ft = { "markdown", "md", "markdown.mdx" },
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    opts = {
      -- sensible defaults; tweak if needed later
      file_types = { "markdown" },
      render_modes = { "nvim" },
      heading = { enabled = true },
      code = { enabled = true },
      bullet = { enabled = true },
      pipe_table = { enabled = true },
    },
    keys = {
      {
        "<leader>um",
        function()
          require("render-markdown").toggle()
        end,
        desc = "Markdown: Toggle inline render",
        ft = { "markdown" },
      },
    },
  },
}

