local M = {}

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

local function is_list(value)
  if vim.tbl_islist then
    return vim.tbl_islist(value)
  end

  local count = 0
  for key in pairs(value) do
    if type(key) ~= "number" then
      return false
    end
    count = count + 1
  end
  return count == #value
end

local function tbl_contains(list, value)
  for _, item in ipairs(list) do
    if item == value then
      return true
    end
  end
  return false
end

local function is_adapter_enabled(name)
  local configured = vim.g.neotest_adapters
  if configured == nil then
    return true
  end

  if type(configured) == "table" then
    if is_list(configured) then
      return tbl_contains(configured, name)
    end

    local value = configured[name]
    if value ~= nil then
      return value
    end
    return false
  end

  if type(configured) == "string" then
    return configured == name
  end

  return false
end

local function add_adapter(adapters, name, factory)
  if not is_adapter_enabled(name) then
    return
  end

  local ok, adapter = pcall(factory)
  if ok and adapter then
    table.insert(adapters, adapter)
  end
end

local function setup_which_key()
  local which_key = safe_require("which-key")
  if not which_key then
    return
  end

  which_key.setup({
    preset = "helix",
  })
end

local function setup_gitsigns()
  local gitsigns = safe_require("gitsigns")
  if not gitsigns then
    return
  end

  gitsigns.setup({
    signs = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
      untracked = { text = "▎" },
    },
    signs_staged = {
      add = { text = "▎" },
      change = { text = "▎" },
      delete = { text = "" },
      topdelete = { text = "" },
      changedelete = { text = "▎" },
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
      map("n", "]H", function()
        gitsigns.nav_hunk("last")
      end, "Last Hunk")
      map("n", "[H", function()
        gitsigns.nav_hunk("first")
      end, "First Hunk")
      map({ "n", "v" }, "<leader>ghs", ":Gitsigns stage_hunk<CR>", "Stage Hunk")
      map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
      map("n", "<leader>ghS", gitsigns.stage_buffer, "Stage Buffer")
      map("n", "<leader>ghu", gitsigns.undo_stage_hunk, "Undo Stage Hunk")
      map("n", "<leader>ghR", gitsigns.reset_buffer, "Reset Buffer")
      map("n", "<leader>ghp", gitsigns.preview_hunk_inline, "Preview Hunk Inline")
      map("n", "<leader>ghb", function()
        gitsigns.blame_line({ full = true })
      end, "Blame Line")
      map("n", "<leader>ghB", gitsigns.blame, "Blame Buffer")
      map("n", "<leader>ghd", gitsigns.diffthis, "Diff This")
      map("n", "<leader>ghD", function()
        gitsigns.diffthis("~")
      end, "Diff This ~")
      map({ "o", "x" }, "ih", ":<C-U>Gitsigns select_hunk<CR>", "GitSigns Select Hunk")
    end,
  })
end

local function setup_flash()
  local flash = safe_require("flash")
  if not flash then
    return
  end

  flash.setup({})

  vim.keymap.set({ "n", "x", "o" }, "s", function()
    flash.jump()
  end, { desc = "Flash" })
  vim.keymap.set({ "n", "o", "x" }, "S", function()
    flash.treesitter()
  end, { desc = "Flash Treesitter" })
  vim.keymap.set("o", "r", function()
    flash.remote()
  end, { desc = "Remote Flash" })
  vim.keymap.set({ "o", "x" }, "R", function()
    flash.treesitter_search()
  end, { desc = "Treesitter Search" })
  vim.keymap.set("c", "<C-s>", function()
    flash.toggle()
  end, { desc = "Toggle Flash Search" })
  vim.keymap.set({ "n", "o", "x" }, "<C-Space>", function()
    flash.treesitter({
      actions = {
        ["<C-Space>"] = "next",
        ["<BS>"] = "prev",
      },
    })
  end, { desc = "Treesitter Incremental Selection" })
end

local function setup_ui()
  local catppuccin = safe_require("catppuccin")
  if catppuccin then
    catppuccin.setup({
      transparent_background = false,
      float = {
        transparent = false,
      },
      styles = {
        comments = {},
        conditionals = {},
        loops = {},
        functions = {},
        keywords = {},
      },
    })
  end

  local gruvbox = safe_require("gruvbox")
  if gruvbox then
    gruvbox.setup({})
  end

  local nvim_tree = safe_require("nvim-tree")
  if nvim_tree then
    nvim_tree.setup({})
  end

  local bufferline = safe_require("bufferline")
  if bufferline then
    bufferline.setup({
      options = {
        mode = "buffers",
        diagnostics = "nvim_lsp",
        always_show_bufferline = true,
        separator_style = "slant",
        offsets = {
          {
            filetype = "NvimTree",
            text = "File Explorer",
            highlight = "Directory",
            text_align = "left",
          },
        },
      },
    })
  end

  require("config.theme").setup()

  local cord = safe_require("cord")
  if cord then
    cord.setup({})
  end
end

local function setup_blink()
  local blink = safe_require("blink.cmp")
  if not blink then
    return
  end

  local function feed(keys)
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes(keys, true, false, true), "n", false)
  end

  local function copilot_accept_if_visible()
    local ok, suggestion = pcall(require, "copilot.suggestion")
    if ok and suggestion.is_visible() then
      suggestion.accept()
      return true
    end
    return false
  end

  local function cmp_is_visible()
    local ok, cmp = pcall(require, "blink.cmp")
    if not ok or not cmp.is_visible then
      return false, nil
    end
    return cmp.is_visible(), cmp
  end

  local function accept_cmp()
    local visible, cmp = cmp_is_visible()
    if visible and cmp.accept then
      cmp.accept()
      return true
    end
    return false
  end

  local function map_tab()
    if copilot_accept_if_visible() then
      return
    end
    if accept_cmp() then
      return
    end
    feed("<Tab>")
  end

  local function map_accept_on_ctrl_y()
    if accept_cmp() then
      return
    end
    feed("<C-y>")
  end

  local function map_select_next()
    local visible, cmp = cmp_is_visible()
    if visible and cmp.select_next then
      cmp.select_next()
    else
      feed("<Down>")
    end
  end

  local function map_select_prev()
    local visible, cmp = cmp_is_visible()
    if visible and cmp.select_prev then
      cmp.select_prev()
    else
      feed("<Up>")
    end
  end

  blink.setup({
    appearance = {
      use_nvim_cmp_as_default = true,
    },
    completion = {
      menu = {
        auto_show = true,
      },
      accept = {
        auto_brackets = {
          enabled = false,
        },
      },
    },
    keymap = {
      preset = "none",
    },
    sources = {
      default = { "copilot", "lsp", "snippets", "path", "buffer" },
      providers = {
        copilot = {
          name = "copilot",
          module = "blink-copilot",
          score_offset = 100,
          async = true,
        },
      },
    },
  })

  vim.keymap.set({ "i", "s" }, "<Tab>", map_tab, { desc = "Accept completion or Copilot suggestion" })
  vim.keymap.set({ "i", "s" }, "<CR>", function()
    return require("config.smart_enter").expr()
  end, {
    expr = true,
    replace_keycodes = false,
    desc = "Accept completion or smart newline",
  })
  vim.keymap.set({ "i", "s" }, "<C-y>", map_accept_on_ctrl_y, { desc = "Accept completion" })
  vim.keymap.set({ "i", "s" }, "<C-Space>", function()
    local ok, cmp = pcall(require, "blink.cmp")
    if ok and cmp.show then
      cmp.show()
    end
  end, { desc = "Manual completion" })
  vim.keymap.set({ "i", "s" }, "<Down>", map_select_next, { desc = "Next completion item or cursor down" })
  vim.keymap.set({ "i", "s" }, "<Up>", map_select_prev, { desc = "Prev completion item or cursor up" })
end

local function setup_copilot()
  local copilot = safe_require("copilot")
  if not copilot then
    return
  end

  copilot.setup({
    panel = { enabled = false },
    suggestion = {
      auto_trigger = true,
      debounce = 75,
      keymap = {
        accept = false,
        accept_word = false,
        accept_line = false,
        next = "<M-]>",
        prev = "<M-[>",
        dismiss = "<C-]>",
      },
    },
    filetypes = {
      markdown = true,
      gitcommit = true,
      help = true,
    },
  })

  vim.keymap.set("i", "<C-l>", function()
    local ok, suggestion = pcall(require, "copilot.suggestion")
    if ok and suggestion.is_visible() then
      suggestion.accept()
      return
    end
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-l>", true, false, true), "n", false)
  end, { desc = "Copilot accept suggestion" })
end

local function setup_editor()
  local refactoring = safe_require("refactoring")
  if refactoring then
    refactoring.setup({})
    vim.keymap.set("v", "<leader>re", function()
      refactoring.select_refactor()
    end, { desc = "Refactor (select)" })
  end

  local colorizer = safe_require("colorizer")
  if colorizer then
    colorizer.setup({
      filetypes = {
        "css",
        "scss",
        "sass",
        "html",
        "javascript",
        "javascriptreact",
        "typescript",
        "typescriptreact",
        "svelte",
        "vue",
        "astro",
      },
      user_default_options = {
        tailwind = true,
      },
    })
  end

  vim.keymap.set("n", "<leader>uu", "<cmd>UndotreeToggle<CR>", { desc = "Toggle undotree" })

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

  local surround = safe_require("nvim-surround")
  if surround then
    surround.setup({})
  end

  local wildfire = safe_require("wildfire")
  if wildfire then
    wildfire.setup({})
  end

  local mc = safe_require("multiple-cursors")
  if mc then
    mc.setup({})

    local set = vim.keymap.set

    local function with_virtual_cursors()
      local ok, vc = pcall(require, "multiple-cursors.virtual_cursors")
      if not ok then
        return nil
      end
      return vc
    end

    local common = require("multiple-cursors.common")

    local function ensure_lock_state(should_lock)
      local vc = with_virtual_cursors()
      if not vc or vc.get_num_virtual_cursors() == 0 then
        return
      end
      if vc.is_locked() ~= should_lock then
        vc.toggle_lock()
      end
    end

    local function exec(name, after)
      return function()
        vim.cmd(name)
        if after then
          after()
        end
      end
    end

    local function relock_if_normal()
      if vim.api.nvim_get_mode().mode:sub(1, 1) == "n" then
        ensure_lock_state(true)
      end
    end

    local function add_cursor_step(direction)
      local vc = with_virtual_cursors()
      if not vc then
        return
      end

      local mode = vim.api.nvim_get_mode().mode
      local head = mode:sub(1, 1)
      local is_visual = head == "v" or head == "V" or head == "\22" or head == "s" or head == "S" or head == "\19"

      if is_visual then
        local l1, c1, l2, c2 = common.get_normalised_visual_area()
        mc.init()
        vc.add_with_visual_area(l2, c2, c2, l1, c1, true)
        vim.cmd("normal! <Esc>")
        head = "n"
      else
        local pos = vim.fn.getcurpos()
        mc.add_cursor(pos[2], pos[3], pos[5])
      end

      if head == "n" then
        ensure_lock_state(true)
      end

      vim.cmd("normal! " .. (direction and direction < 0 and "b" or "w"))
    end

    local add_next_word = function()
      add_cursor_step(1)
    end

    local add_prev_word = function()
      add_cursor_step(-1)
    end

    set({ "n", "x" }, "<leader>mk", exec("MultipleCursorsAddUp", relock_if_normal), { desc = "Multi: add cursor above", silent = true })
    set({ "n", "x" }, "<leader>mj", exec("MultipleCursorsAddDown", relock_if_normal), { desc = "Multi: add cursor below", silent = true })
    set({ "n", "x" }, "<leader>mn", add_next_word, { desc = "Multi: add cursor then move forward", silent = true })
    set({ "n", "x" }, "<leader>mN", add_prev_word, { desc = "Multi: add cursor then move backward", silent = true })
    set({ "n", "x" }, "<leader>ms", exec("MultipleCursorsJumpNextMatch"), { desc = "Multi: skip next match", silent = true })
    set({ "n", "x" }, "<leader>mS", exec("MultipleCursorsJumpPrevMatch"), { desc = "Multi: skip previous match", silent = true })
    set({ "n", "x" }, "<leader>mA", exec("MultipleCursorsAddMatches", relock_if_normal), { desc = "Multi: add cursors to matches", silent = true })
    set({ "n", "x" }, "<leader>mm", exec("MultipleCursorsLock"), { desc = "Multi: toggle lock", silent = true })
    set({ "n", "x" }, "<leader>mc", function()
      mc.deinit(true)
    end, { desc = "Multi: clear cursors" })
    set({ "n", "i" }, "<C-LeftMouse>", exec("MultipleCursorsMouseAddDelete", relock_if_normal), { desc = "Multi: add/remove cursor", silent = true })
    set({ "n", "x" }, "<C-i>", add_next_word, { desc = "Multi: add cursor then move forward", silent = true })

    local unlock_modes = {
      i = true,
      v = true,
      V = true,
      R = true,
      s = true,
      S = true,
    }
    unlock_modes["\22"] = true
    unlock_modes["\19"] = true

    local group = vim.api.nvim_create_augroup("MultiCursorAutoLock", { clear = true })
    vim.api.nvim_create_autocmd("ModeChanged", {
      group = group,
      desc = "Auto-lock multiple cursors in normal mode",
      callback = function()
        local vc = with_virtual_cursors()
        if not vc or vc.get_num_virtual_cursors() == 0 then
          return
        end
        local head = vim.api.nvim_get_mode().mode:sub(1, 1)
        if head == "n" then
          ensure_lock_state(true)
        elseif unlock_modes[head] then
          ensure_lock_state(false)
        end
      end,
    })
  end
end

local function setup_yanky()
  local yanky = safe_require("yanky")
  if not yanky then
    return
  end

  yanky.setup({
    highlight = { timer = 150 },
  })

  local map = vim.keymap.set
  map({ "n", "x" }, "<leader>p", "<cmd>YankyRingHistory<CR>", { desc = "Open Yank History" })
  map({ "n", "x" }, "y", "<Plug>(YankyYank)", { desc = "Yank Text" })
  map({ "n", "x" }, "p", "<Plug>(YankyPutAfter)", { desc = "Put Text After Cursor" })
  map({ "n", "x" }, "P", "<Plug>(YankyPutBefore)", { desc = "Put Text Before Cursor" })
  map({ "n", "x" }, "gp", "<Plug>(YankyGPutAfter)", { desc = "Put Text After Selection" })
  map({ "n", "x" }, "gP", "<Plug>(YankyGPutBefore)", { desc = "Put Text Before Selection" })
  map("n", "[y", "<Plug>(YankyCycleForward)", { desc = "Cycle Forward Through Yank History" })
  map("n", "]y", "<Plug>(YankyCycleBackward)", { desc = "Cycle Backward Through Yank History" })
  map("n", "]p", "<Plug>(YankyPutIndentAfterLinewise)", { desc = "Put Indented After Cursor (Linewise)" })
  map("n", "[p", "<Plug>(YankyPutIndentBeforeLinewise)", { desc = "Put Indented Before Cursor (Linewise)" })
  map("n", "]P", "<Plug>(YankyPutIndentAfterLinewise)", { desc = "Put Indented After Cursor (Linewise)" })
  map("n", "[P", "<Plug>(YankyPutIndentBeforeLinewise)", { desc = "Put Indented Before Cursor (Linewise)" })
  map("n", ">p", "<Plug>(YankyPutIndentAfterShiftRight)", { desc = "Put and Indent Right" })
  map("n", "<p", "<Plug>(YankyPutIndentAfterShiftLeft)", { desc = "Put and Indent Left" })
  map("n", ">P", "<Plug>(YankyPutIndentBeforeShiftRight)", { desc = "Put Before and Indent Right" })
  map("n", "<P", "<Plug>(YankyPutIndentBeforeShiftLeft)", { desc = "Put Before and Indent Left" })
  map("n", "=p", "<Plug>(YankyPutAfterFilter)", { desc = "Put After Applying a Filter" })
  map("n", "=P", "<Plug>(YankyPutBeforeFilter)", { desc = "Put Before Applying a Filter" })
end

local function setup_conform()
  local conform = safe_require("conform")
  if not conform then
    return
  end

  local function ensure_condition(formatters, name, predicate)
    local cfg = formatters[name]
    if cfg == nil then
      cfg = {}
      formatters[name] = cfg
    elseif type(cfg) == "function" then
      cfg = { format = cfg }
      formatters[name] = cfg
    end

    local prev = cfg.condition
    cfg.condition = function(self, ctx)
      if prev and not prev(self, ctx) then
        return false
      end
      return predicate(ctx)
    end
  end

  local formatters = {}
  local formatters_by_ft = {}
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
    formatters_by_ft[ft] = web
  end

  local function within_size_limit(ctx)
    local name = vim.api.nvim_buf_get_name(ctx.buf)
    if name == "" then
      return true
    end
    local stat = (vim.uv or vim.loop).fs_stat(name)
    return not (stat and stat.size and stat.size > 200 * 1024)
  end

  for _, formatter in ipairs({ "prettierd", "prettier", "biome" }) do
    ensure_condition(formatters, formatter, within_size_limit)
  end

  conform.setup({
    formatters = formatters,
    formatters_by_ft = formatters_by_ft,
    notify_on_error = false,
  })
end

local function setup_telescope()
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

local function setup_goto_preview()
  local goto_preview = safe_require("goto-preview")
  if not goto_preview then
    return
  end

  goto_preview.setup({
    default_mappings = false,
    focus_on_open = true,
    dismiss_on_move = true,
    resizing_mappings = false,
    opacity = nil,
    height = 20,
    width = 80,
    border = { "+", "-", "+", "|", "+", "-", "+", "|" },
  })

  vim.keymap.set("n", "<A-d>", goto_preview.goto_preview_definition, { desc = "Preview definition" })
  vim.keymap.set("n", "<A-D>", goto_preview.goto_preview_type_definition, { desc = "Preview type definition" })
  vim.keymap.set("n", "<A-Esc>", goto_preview.close_all_win, { desc = "Close all previews" })
end

local function setup_markdown()
  local render_markdown = safe_require("render-markdown")
  if render_markdown then
    render_markdown.setup({
      file_types = { "markdown" },
      render_modes = { "nvim" },
      heading = { enabled = true },
      code = { enabled = true },
      bullet = { enabled = true },
      pipe_table = { enabled = true },
    })

    vim.keymap.set("n", "<leader>um", function()
      render_markdown.toggle()
    end, { desc = "Markdown: Toggle inline render" })
  end

  vim.g.mkdp_auto_close = 0
  vim.keymap.set("n", "<leader>mp", "<cmd>MarkdownPreviewToggle<CR>", { desc = "Markdown: Browser preview" })
end

local function setup_mason()
  local mason = safe_require("mason")
  if mason then
    mason.setup({})
  end

  local mason_tool_installer = safe_require("mason-tool-installer")
  if mason_tool_installer then
    mason_tool_installer.setup({
      ensure_installed = {
        "css-lsp",
        "gopls",
        "html-lsp",
        "json-lsp",
      },
      auto_update = false,
      run_on_start = true,
    })
  end
end

local function setup_lsp()
  vim.diagnostic.config({
    update_in_insert = true,
    severity_sort = true,
    underline = true,
    virtual_text = { spacing = 2, source = "if_many" },
  })

  local capabilities = vim.lsp.protocol.make_client_capabilities()
  local ok_blink, blink = pcall(require, "blink.cmp")
  if ok_blink and blink.get_lsp_capabilities then
    capabilities = blink.get_lsp_capabilities(capabilities)
  end

  local servers = {
    html = {},
    cssls = {},
    jsonls = {},
    eslint = {},
    ts_ls = {},
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
    svelte = {},
    vue_ls = {},
    astro = {},
    rust_analyzer = {
      settings = {
        ["rust-analyzer"] = {
          diagnostics = { enable = true },
        },
      },
    },
    jdtls = {},
    gopls = {},
    pyright = {},
    clangd = {},
  }

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

  for name, conf in pairs(servers) do
    local merged = vim.tbl_deep_extend("force", {
      capabilities = capabilities,
      flags = {
        debounce_text_changes = 100,
      },
    }, conf)
    vim.lsp.config(name, merged)
  end

  vim.lsp.enable(vim.tbl_keys(servers))

  if not vim.g.__live_diag_toggle_defined then
    vim.g.__live_diag_toggle_defined = true
    vim.api.nvim_create_user_command("ToggleDiagLive", function()
      local cfg = vim.diagnostic.config()
      local new = not cfg.update_in_insert
      vim.diagnostic.config({ update_in_insert = new })
      vim.notify("diagnostics update_in_insert = " .. tostring(new))
    end, { desc = "Toggle diagnostics updates in insert mode" })
  end
end

local function setup_treesitter()
  local treesitter = safe_require("nvim-treesitter")
  if not treesitter then
    return
  end

  local languages = {
      "c",
      "cpp",
      "java",
      "go",
      "python",
      "rust",
      "lua",
      "vim",
      "html",
      "css",
      "javascript",
      "typescript",
      "tsx",
      "json",
      "svelte",
      "markdown",
      "markdown_inline",
  }

  treesitter.setup({
    install_dir = vim.fn.stdpath("data") .. "/site",
  })

  treesitter.install(languages)

  local group = vim.api.nvim_create_augroup("TreesitterRuntimeSetup", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    group = group,
    pattern = {
      "c",
      "cpp",
      "java",
      "go",
      "python",
      "rust",
      "lua",
      "vim",
      "html",
      "css",
      "javascript",
      "typescript",
      "tsx",
      "json",
      "svelte",
      "markdown",
    },
    callback = function(args)
      pcall(vim.treesitter.start, args.buf)
      vim.bo[args.buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
    end,
  })
end

local function setup_code_runner()
  local code_runner = safe_require("code_runner")
  if not code_runner then
    return
  end

  code_runner.setup({
    filetype = {
      python = [[
        cd $dir
        if command -v uv >/dev/null 2>&1; then
          uv run python -u $fileName
        elif command -v poetry >/dev/null 2>&1 && [ -f pyproject.toml ]; then
          poetry run python -u $fileName
        elif command -v pipenv >/dev/null 2>&1 && [ -f Pipfile ]; then
          pipenv run python -u $fileName
        elif [ -x ".venv/bin/python" ]; then
          .venv/bin/python -u $fileName
        elif [ -n "$VIRTUAL_ENV" ] && [ -x "$VIRTUAL_ENV/bin/python" ]; then
          "$VIRTUAL_ENV/bin/python" -u $fileName
        else
          python3 -u $fileName
        fi
      ]],
      java = [[
        cd $dir
        if [ -f gradlew ] || [ -f build.gradle ] || [ -f build.gradle.kts ]; then
          if [ -f gradlew ]; then
            ./gradlew --quiet build && ./gradlew --quiet run
          else
            gradle --quiet build && gradle --quiet run
          fi
        else
          javac $fileName && java -cp $dir $fileNameWithoutExt
        fi
      ]],
      c = [[
        cd $dir
        if [ -f Makefile ] || [ -f makefile ]; then
          make run 2>/dev/null || make
          [ -x $dir/$fileNameWithoutExt ] && $dir/$fileNameWithoutExt
        else
          COMPILER=""
          if command -v cc >/dev/null 2>&1; then COMPILER=cc
          elif command -v gcc >/dev/null 2>&1; then COMPILER=gcc
          else COMPILER=gcc
          fi
          "$COMPILER" -std=c11 -O2 -Wall -Wextra $fileName -o $fileNameWithoutExt && $dir/$fileNameWithoutExt
        fi
      ]],
      cpp = [[
        cd $dir
        if [ -f Makefile ] || [ -f makefile ]; then
          make run 2>/dev/null || make
          [ -x $dir/$fileNameWithoutExt ] && $dir/$fileNameWithoutExt
        else
          CXX=""
          if command -v c++ >/dev/null 2>&1; then CXX=c++
          elif command -v g++ >/dev/null 2>&1; then CXX=g++
          else CXX=c++
          fi
          "$CXX" -std=c++17 -O2 -Wall -Wextra $fileName -o $fileNameWithoutExt && $dir/$fileNameWithoutExt
        fi
      ]],
      rust = [[
        root=""
        d=$dir
        while [ "$d" != "/" ]; do
          if [ -f "$d/Cargo.toml" ]; then root="$d"; break; fi
          d="$(dirname "$d")"
        done
        if [ -n "$root" ]; then
          cd "$root" && cargo run --quiet
        else
          cd $dir && rustc $fileName -O -o $fileNameWithoutExt && $dir/$fileNameWithoutExt
        fi
      ]],
      go = [[
        gomod="$(go env GOMOD 2>/dev/null)"
        if [ -n "$gomod" ] && [ -f "$gomod" ]; then
          cd "$(dirname "$gomod")" && go run .
        else
          cd $dir && go run $fileName
        fi
      ]],
    },
  })

  vim.keymap.set("n", "<F5>", "<cmd>RunCode<CR>", { noremap = true, silent = true, desc = "Run code" })
end

local function setup_neotest()
  local neotest = safe_require("neotest")
  if not neotest then
    return
  end

  local adapters = {}

  add_adapter(adapters, "go", function()
    local neotest_go = require("neotest-go")
    return neotest_go({
      experimental = { test_table = true },
      args = { "-count=1", "-race" },
    })
  end)

  local function detect_python()
    local venv = os.getenv("VIRTUAL_ENV")
    if venv and #venv > 0 then
      return venv .. "/bin/python"
    end

    local cwd = vim.fn.getcwd()
    if vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
      return cwd .. "/.venv/bin/python"
    end
    return "python3"
  end

  add_adapter(adapters, "python", function()
    local neotest_python = require("neotest-python")
    return neotest_python({
      dap = { justMyCode = false },
      runner = "pytest",
      python = detect_python,
      args = { "-q" },
    })
  end)

  add_adapter(adapters, "rust", function()
    local neotest_rust = require("neotest-rust")
    return neotest_rust({ args = { "--", "--nocapture" } })
  end)

  add_adapter(adapters, "plenary", function()
    return require("neotest-plenary")()
  end)

  local function has(path)
    return vim.fn.filereadable(vim.fn.getcwd() .. "/" .. path) == 1
  end

  add_adapter(adapters, "jest", function()
    local neotest_jest = require("neotest-jest")
    local function jest_cmd()
      if has("pnpm-lock.yaml") then
        return "pnpm test --"
      elseif has("yarn.lock") then
        return "yarn test --"
      elseif has("package-lock.json") then
        return "npm test --"
      elseif vim.fn.executable("node_modules/.bin/jest") == 1 then
        return "node node_modules/jest/bin/jest.js"
      else
        return "npx jest"
      end
    end

    return neotest_jest({
      jestCommand = jest_cmd(),
      jestConfigFile = function()
        for _, file in ipairs({ "jest.config.ts", "jest.config.js", "jest.config.cjs", "jest.config.mjs" }) do
          if has(file) then
            return file
          end
        end
      end,
      env = { CI = "1" },
    })
  end)

  add_adapter(adapters, "vitest", function()
    local neotest_vitest = require("neotest-vitest")
    local function vitest_cmd()
      if has("pnpm-lock.yaml") then
        return "pnpm vitest"
      elseif has("yarn.lock") then
        return "yarn vitest"
      elseif has("package-lock.json") then
        return "npm run vitest --"
      elseif vim.fn.executable("node_modules/.bin/vitest") == 1 then
        return "node node_modules/vitest/vitest.mjs"
      else
        return "npx vitest"
      end
    end

    return neotest_vitest({
      vitestCommand = vitest_cmd(),
      env = { CI = "1" },
    })
  end)

  add_adapter(adapters, "java", function()
    return require("neotest-java")
  end)

  add_adapter(adapters, "vim-test", function()
    local neotest_vim_test = require("neotest-vim-test")
    return neotest_vim_test({
      ignore_file_types = { "python", "go", "rust", "javascript", "typescript" },
    })
  end)

  neotest.setup({ adapters = adapters })

  vim.keymap.set("n", "<leader>tt", function()
    neotest.run.run()
  end, { desc = "Test nearest" })
  vim.keymap.set("n", "<leader>tf", function()
    neotest.run.run(vim.fn.expand("%"))
  end, { desc = "Test file" })
  vim.keymap.set("n", "<leader>ts", function()
    neotest.summary.toggle()
  end, { desc = "Test summary" })
  vim.keymap.set("n", "<leader>to", function()
    neotest.output.open({ enter = true })
  end, { desc = "Test output" })
  vim.keymap.set("n", "<leader>tS", function()
    neotest.run.stop()
  end, { desc = "Test stop" })
end

local function setup_leetcode()
  local leetcode = safe_require("leetcode")
  if not leetcode then
    return
  end

  leetcode.setup({
    lang = "rust",
    cn = {
      enabled = true,
      translator = true,
      translate_problems = true,
    },
    storage = {
      home = vim.fn.stdpath("data") .. "/leetcode",
      cache = vim.fn.stdpath("cache") .. "/leetcode",
    },
  })
end

function M.setup()
  setup_which_key()
  setup_gitsigns()
  setup_flash()
  setup_ui()
  setup_blink()
  setup_copilot()
  setup_editor()
  setup_yanky()
  setup_conform()
  setup_telescope()
  setup_goto_preview()
  setup_markdown()
  setup_mason()
  setup_lsp()
  setup_treesitter()
  setup_code_runner()
  setup_neotest()
  setup_leetcode()
end

M.setup()

return M
