return {
  -- Opinionated formatting setup for web stacks
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = function(_, opts)
      opts = opts or {}

      local function ensure_condition(name, predicate)
        opts.formatters = opts.formatters or {}
        local cfg = opts.formatters[name]
        if cfg == nil then
          cfg = {}
          opts.formatters[name] = cfg
        elseif type(cfg) == "function" then
          cfg = { format = cfg }
          opts.formatters[name] = cfg
        end
        local prev = cfg.condition
        cfg.condition = function(self, ctx)
          if prev and not prev(self, ctx) then return false end
          return predicate(ctx)
        end
      end

      opts.formatters_by_ft = opts.formatters_by_ft or {}
      local web = { "prettierd", "prettier", "biome" }
      for _, ft in ipairs({
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "svelte",
        "vue",
        "astro",
        "css",
        "scss",
        "less",
        "html",
        "json",
        "yaml",
        "markdown",
        "markdown.mdx",
      }) do
        opts.formatters_by_ft[ft] = opts.formatters_by_ft[ft] or web
      end

      local function within_size_limit(ctx)
        local name = vim.api.nvim_buf_get_name(ctx.buf)
        if name == "" then return true end
        local stat = (vim.uv or vim.loop).fs_stat(name)
        return not (stat and stat.size and stat.size > 200 * 1024)
      end

      for _, formatter in ipairs({ "prettierd", "prettier", "biome" }) do
        ensure_condition(formatter, within_size_limit)
      end
    end,
  },
}
