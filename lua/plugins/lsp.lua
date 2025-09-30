return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    opts = function(_, opts)
      opts = opts or {}

      -- Default servers merged with any existing definitions
      local servers = {
        -- Java
        jdtls = {},
        -- Go
        gopls = {},
        -- Rust
        rust_analyzer = {},
        -- Python
        pyright = {},
        -- C/C++
        clangd = {},
        -- Web / Frontend
        html = {},
        cssls = {},
        jsonls = {},
        eslint = {},
        tsserver = {},
        tailwindcss = {},
        emmet_ls = {
          filetypes = {
            "html",
            "css",
            "javascript",
            "javascriptreact",
            "typescript",
            "typescriptreact",
            "svelte",
            "vue",
            "astro",
          },
        },
        -- Svelte
        svelte = {},
        -- Optional: Vue / Astro if present in projects
        volar = {},
        astro = {},
      }

      opts.servers = vim.tbl_deep_extend("force", servers, opts.servers or {})

      -- Diagnostics UI and behavior
      opts.diagnostics = vim.tbl_deep_extend("force", opts.diagnostics or {}, {
        update_in_insert = true,
        severity_sort = true,
        underline = true,
        virtual_text = { spacing = 2, source = "if_many" },
      })

      -- Send didChange quickly to servers
      local function ensure_flags(conf)
        conf = conf or {}
        conf.flags = vim.tbl_deep_extend("force", conf.flags or {}, {
          debounce_text_changes = 100,
        })
        return conf
      end

      for name, conf in pairs(opts.servers) do
        opts.servers[name] = ensure_flags(conf)
      end

      for _, name in ipairs({ "rust_analyzer", "jdtls", "gopls", "pyright", "clangd" }) do
        opts.servers[name] = ensure_flags(opts.servers[name])
      end

      opts.servers.rust_analyzer = vim.tbl_deep_extend("force", opts.servers.rust_analyzer or {}, {
        settings = {
          ["rust-analyzer"] = {
            diagnostics = { enable = true },
          },
        },
      })

      return opts
    end,
  },
}
