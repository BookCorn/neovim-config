return {
  -- Opinionated formatting setup for web stacks
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function()
      local ok, conform = pcall(require, "conform")
      if not ok then return {} end
      return {
        format_on_save = function(bufnr)
          -- Skip very large files
          local max = 200 * 1024
          local ok_fs, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(bufnr))
          if ok_fs and stats and stats.size and stats.size > max then return nil end
          return { timeout_ms = 2000, lsp_fallback = true }
        end,
        formatters_by_ft = {
          javascript = { "prettierd", "prettier", "biome" },
          javascriptreact = { "prettierd", "prettier", "biome" },
          typescript = { "prettierd", "prettier", "biome" },
          typescriptreact = { "prettierd", "prettier", "biome" },
          svelte = { "prettierd", "prettier" },
          vue = { "prettierd", "prettier" },
          astro = { "prettierd", "prettier" },
          css = { "prettierd", "prettier" },
          scss = { "prettierd", "prettier" },
          less = { "prettierd", "prettier" },
          html = { "prettierd", "prettier" },
          json = { "prettierd", "prettier" },
          yaml = { "prettierd", "prettier" },
          markdown = { "prettierd", "prettier" },
          ["markdown.mdx"] = { "prettierd", "prettier" },
        },
      }
    end,
  },
}

