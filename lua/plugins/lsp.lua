return {
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    opts = function(_, opts)
      opts = opts or {}

      -- Server profile: keep LSP empty by default on servers
      -- Users can still add via `vim.g.extra_lsp_servers`
      local servers = {}

      local function is_list(value)
        if vim.tbl_islist then
          return vim.tbl_islist(value)
        end

        local max_index = 0
        for key in pairs(value) do
          if type(key) ~= "number" then
            return false
          end
          if key > max_index then
            max_index = key
          end
        end
        return max_index == #value
      end

      -- Allow users to add extra servers (e.g., rust_analyzer) via vim.g.extra_lsp_servers
      local user_servers = vim.g.extra_lsp_servers
      if type(user_servers) == "table" then
        if is_list(user_servers) then
          for _, name in ipairs(user_servers) do
            if type(name) == "string" then
              servers[name] = {}
            end
          end
        else
          for name, config in pairs(user_servers) do
            if type(name) == "string" then
              servers[name] = config == true and {} or config
            end
          end
        end
      end

      -- On server profile, override defaults instead of merging to avoid auto-installs
      opts.servers = servers

      -- Diagnostics UI and behavior
      opts.diagnostics = vim.tbl_deep_extend("force", opts.diagnostics or {}, {
        update_in_insert = true,
        severity_sort = true,
        underline = true,
        virtual_text = { spacing = 2, source = "if_many" },
      })

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

      return opts
    end,
  },
}
