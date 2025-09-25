-- Realtime LSP diagnostics (VS Code / JetBrains-like)
-- - Enable diagnostic updates while typing
-- - Lower debounce so servers receive on-change updates quickly
-- - Keep language-specific defaults intact
return {
  "neovim/nvim-lspconfig",
  opts = function(_, opts)
    opts = opts or {}

    -- 1) Diagnostics UI and behavior
    opts.diagnostics = vim.tbl_deep_extend("force", opts.diagnostics or {}, {
      update_in_insert = true,
      severity_sort = true,
      underline = true,
      virtual_text = { spacing = 2, source = "if_many" },
    })

    -- 2) Send didChange quickly to servers
    opts.servers = opts.servers or {}
    local function ensure_flags(conf)
      conf = conf or {}
      conf.flags = vim.tbl_deep_extend("force", conf.flags or {}, {
        debounce_text_changes = 100, -- conservative and responsive
      })
      return conf
    end

    -- Apply to declared servers
    for name, conf in pairs(opts.servers) do
      opts.servers[name] = ensure_flags(conf)
    end

    -- Add common servers if not already declared (safe no-op if present)
    local common = { "rust_analyzer", "jdtls", "gopls", "pyright", "clangd" }
    for _, name in ipairs(common) do
      opts.servers[name] = ensure_flags(opts.servers[name])
    end

    -- 3) Rust: make sure semantic diagnostics are enabled
    opts.servers.rust_analyzer = vim.tbl_deep_extend("force", opts.servers.rust_analyzer or {}, {
      settings = {
        ["rust-analyzer"] = {
          diagnostics = { enable = true },
        },
      },
    })

    -- Optional: quick toggle for live diagnostics
    if not vim.g.__live_diag_toggle_defined then
      vim.g.__live_diag_toggle_defined = true
      vim.api.nvim_create_user_command("ToggleDiagLive", function()
        local cfg = vim.diagnostic.config()
        local new = not cfg.update_in_insert
        vim.diagnostic.config({ update_in_insert = new })
        vim.notify("diagnostics update_in_insert = " .. tostring(new))
      end, { desc = "Toggle diagnostics updates in insert mode" })
    end

    return opts
  end,
}

