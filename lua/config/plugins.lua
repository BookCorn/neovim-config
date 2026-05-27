local M = {}
local loaded_plugins = {}
local initialized = {}

local function load_plugin(name)
  if loaded_plugins[name] then
    return true
  end

  local ok, err = pcall(vim.cmd.packadd, name)
  if not ok then
    vim.schedule(function()
      vim.notify("Failed to load plugin " .. name .. ": " .. err, vim.log.levels.ERROR)
    end)
    return false
  end

  loaded_plugins[name] = true
  return true
end

local function once(name, fn)
  if initialized[name] then
    return true
  end

  initialized[name] = true
  fn()
  return true
end

local function safe_require(name)
  local ok, module = pcall(require, name)
  if ok then
    return module
  end
  vim.schedule(function()
    vim.notify("Failed to load " .. name .. ": " .. module, vim.log.levels.ERROR)
  end)
  return nil
end

local function setup_which_key()
  load_plugin("which-key.nvim")
  local which_key = safe_require("which-key")
  if which_key then
    which_key.setup({ preset = "helix" })
  end
end

local function setup_gitsigns()
  load_plugin("gitsigns.nvim")
  local gitsigns = safe_require("gitsigns")
  if not gitsigns then
    return
  end

  gitsigns.setup({
    signs = {
      add = { text = "+" },
      change = { text = "~" },
      delete = { text = "_" },
      topdelete = { text = "^" },
      changedelete = { text = "~" },
      untracked = { text = "?" },
    },
    on_attach = function(buffer)
      local function map(mode, lhs, rhs, desc)
        vim.keymap.set(mode, lhs, rhs, { buffer = buffer, desc = desc, silent = true })
      end

      map("n", "]h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "]c", bang = true })
        else
          gitsigns.nav_hunk("next")
        end
      end, "Next Hunk")
      map("n", "[h", function()
        if vim.wo.diff then
          vim.cmd.normal({ "[c", bang = true })
        else
          gitsigns.nav_hunk("prev")
        end
      end, "Prev Hunk")
      map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
      map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
      map("n", "<leader>ghS", gitsigns.stage_buffer, "Stage Buffer")
      map("n", "<leader>ghu", gitsigns.undo_stage_hunk, "Undo Stage Hunk")
      map("n", "<leader>ghR", gitsigns.reset_buffer, "Reset Buffer")
      map("n", "<leader>ghp", gitsigns.preview_hunk_inline, "Preview Hunk Inline")
      map("n", "<leader>ghb", function()
        gitsigns.blame_line({ full = true })
      end, "Blame Line")
      map("n", "<leader>ghd", gitsigns.diffthis, "Diff This")
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
    end,
  })
end

local function setup_flash()
  local function with_flash(callback)
    once("flash", function()
      load_plugin("flash.nvim")
      local flash = safe_require("flash")
      if flash then
        flash.setup({})
      end
    end)

    local flash = safe_require("flash")
    if flash then
      callback(flash)
    end
  end

  vim.keymap.set({ "n", "x", "o" }, "s", function()
    with_flash(function(flash)
      flash.jump()
    end)
  end, { desc = "Flash" })
  vim.keymap.set({ "n", "o", "x" }, "S", function()
    with_flash(function(flash)
      flash.treesitter()
    end)
  end, { desc = "Flash Treesitter" })
  vim.keymap.set("c", "<C-s>", function()
    with_flash(function(flash)
      flash.toggle()
    end)
  end, { desc = "Toggle Flash Search" })
end

local function setup_theme()
  load_plugin("gruvbox.nvim")
  local gruvbox = safe_require("gruvbox")
  if gruvbox then
    gruvbox.setup({})
  end
  require("config.theme").setup()
end

local function setup_editor()
  vim.keymap.set("n", "<leader>uu", function()
    load_plugin("undotree")
    vim.cmd.UndotreeToggle()
  end, { desc = "Toggle undotree" })

  load_plugin("mini.pairs")
  local mini_pairs = safe_require("mini.pairs")
  if mini_pairs then
    mini_pairs.setup({
      modes = { insert = true, command = true, terminal = false },
      skip_next = [=[[%w%%%'%[%"%.%`%$]]=],
      skip_ts = { "string" },
      skip_unbalanced = true,
      markdown = true,
    })
    vim.keymap.set("i", "<CR>", function()
      return require("config.smart_enter").expr()
    end, {
      expr = true,
      replace_keycodes = false,
      desc = "Smart newline inside pairs",
    })
  end

  load_plugin("nvim-surround")
  local surround = safe_require("nvim-surround")
  if surround then
    surround.setup({})
  end
end

local function setup_yanky()
  load_plugin("yanky.nvim")
  local yanky = safe_require("yanky")
  if not yanky then
    return
  end

  yanky.setup({ highlight = { timer = 150 } })

  local map = vim.keymap.set
  map({ "n", "x" }, "<leader>p", "<cmd>YankyRingHistory<CR>", { desc = "Open Yank History" })
  map({ "n", "x" }, "y", "<Plug>(YankyYank)", { desc = "Yank Text" })
  map({ "n", "x" }, "p", "<Plug>(YankyPutAfter)", { desc = "Put Text After Cursor" })
  map({ "n", "x" }, "P", "<Plug>(YankyPutBefore)", { desc = "Put Text Before Cursor" })
  map("n", "[y", "<Plug>(YankyCycleForward)", { desc = "Cycle Forward Through Yank History" })
  map("n", "]y", "<Plug>(YankyCycleBackward)", { desc = "Cycle Backward Through Yank History" })
  map("n", "]p", "<Plug>(YankyPutIndentAfterLinewise)", { desc = "Put Indented After Cursor" })
  map("n", "[p", "<Plug>(YankyPutIndentBeforeLinewise)", { desc = "Put Indented Before Cursor" })
end

local function setup_conform()
  load_plugin("conform.nvim")
  local conform = safe_require("conform")
  if not conform then
    return
  end

  conform.setup({
    formatters_by_ft = {
      lua = { "stylua" },
      sh = { "shfmt" },
      bash = { "shfmt" },
      zsh = { "shfmt" },
      json = { "jq" },
      yaml = { "yamlfmt", "prettier" },
      markdown = { "prettier" },
      python = { "ruff_format", "black" },
      go = { "gofmt" },
      rust = { "rustfmt" },
    },
    notify_on_error = false,
  })
end

local function setup_telescope()
  load_plugin("plenary.nvim")
  load_plugin("telescope.nvim")
  local telescope = safe_require("telescope")
  if not telescope then
    return
  end

  telescope.setup({
    defaults = {
      sorting_strategy = "ascending",
      layout_strategy = "horizontal",
      layout_config = {
        prompt_position = "top",
        preview_width = 0.58,
        width = 0.92,
        height = 0.88,
      },
      mappings = {
        i = {
          ["<Esc>"] = require("telescope.actions").close,
        },
      },
    },
    pickers = {
      keymaps = {
        show_plug = false,
        previewer = true,
      },
    },
  })
end

local function setup_lsp()
  load_plugin("nvim-lspconfig")

  vim.diagnostic.config({
    update_in_insert = false,
    severity_sort = true,
    underline = true,
    virtual_text = { spacing = 2, source = "if_many" },
  })

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  capabilities.textDocument.completion.completionItem.snippetSupport = true
  capabilities.textDocument.completion.completionItem.resolveSupport = {
    properties = { "documentation", "detail", "additionalTextEdits" },
  }

  local servers = {
    bashls = {},
    clangd = {},
    gopls = {},
    jsonls = {},
    lua_ls = {
      settings = {
        Lua = {
          diagnostics = { globals = { "vim" } },
          workspace = { checkThirdParty = false },
        },
      },
    },
    pyright = {},
    rust_analyzer = {},
    yamlls = {},
  }

  local user_servers = vim.g.extra_lsp_servers
  if type(user_servers) == "table" then
    for name, config in pairs(user_servers) do
      if type(name) == "string" then
        servers[name] = config == true and {} or config
      end
    end
  end

  for name, conf in pairs(servers) do
    local merged = vim.tbl_deep_extend("force", {
      capabilities = capabilities,
      flags = {
        debounce_text_changes = 150,
      },
    }, conf)
    vim.lsp.config(name, merged)
  end

  vim.lsp.enable(vim.tbl_keys(servers))

  vim.api.nvim_create_autocmd("LspAttach", {
    group = vim.api.nvim_create_augroup("ServerLspAttach", { clear = true }),
    callback = function(args)
      if not vim.lsp.completion then
        return
      end

      vim.lsp.completion.enable(true, args.data.client_id, args.buf, { autotrigger = true })
      vim.keymap.set("i", "<C-Space>", vim.lsp.completion.get, {
        buffer = args.buf,
        desc = "LSP completion",
      })
    end,
  })
end

local function setup_lsp_on_demand()
  vim.api.nvim_create_autocmd({ "BufReadPre", "BufNewFile" }, {
    once = true,
    callback = function()
      once("lsp", setup_lsp)
    end,
  })
end

local function setup_treesitter()
  local languages = {
    "bash",
    "c",
    "cpp",
    "go",
    "json",
    "lua",
    "markdown",
    "markdown_inline",
    "python",
    "rust",
    "vim",
    "yaml",
  }

  local function ensure_treesitter()
    once("treesitter", function()
      load_plugin("nvim-treesitter")
      local treesitter = safe_require("nvim-treesitter")
      if treesitter then
        treesitter.setup({
          install_dir = vim.fn.stdpath("data") .. "/site",
        })
      end
    end)

    return safe_require("nvim-treesitter")
  end

  if vim.fn.exists(":TSInstallConfigured") == 0 then
    vim.api.nvim_create_user_command("TSInstallConfigured", function(opts)
      local treesitter = ensure_treesitter()
      if not treesitter then
        return
      end
      local task = treesitter.install(languages)
      if opts.bang and task and task.wait then
        task:wait(300000)
      end
    end, {
      bang = true,
      desc = "Install configured Treesitter parsers; use ! to wait for completion",
    })
  end

  local group = vim.api.nvim_create_augroup("TreesitterRuntimeSetup", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = languages,
    callback = function(args)
      local treesitter = ensure_treesitter()
      if not treesitter then
        return
      end
      pcall(vim.treesitter.start, args.buf)
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })
end

function M.setup()
  setup_which_key()
  setup_gitsigns()
  setup_flash()
  setup_theme()
  setup_editor()
  setup_yanky()
  setup_lsp_on_demand()
  setup_treesitter()
end

function M.ensure_telescope()
  once("telescope", setup_telescope)
end

function M.ensure_conform()
  once("conform", setup_conform)
end

function M.load_plugin(name)
  return load_plugin(name)
end

M.setup()

return M
