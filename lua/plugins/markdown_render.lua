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
  {
    "iamcco/markdown-preview.nvim",
    ft = { "markdown", "md", "markdown.mdx" },
    build = "cd app && npm install",
    init = function()
      -- leave browser window open; manually stop with :MarkdownPreviewStop
      vim.g.mkdp_auto_close = 0
    end,
    keys = {
      {
        "<leader>mp",
        "<cmd>MarkdownPreviewToggle<CR>",
        desc = "Markdown: Browser preview",
        ft = { "markdown" },
      },
    },
  },
}
