return {
  -- ======= NVIM-TREESITTER =======
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      ensure_installed = { "c", "cpp", "java", "go", "python", "rust", "lua", "vim" },
      highlight = { enable = true, additional_vim_regex_highlighting = false },
      indent = { enable = true },
      auto_install = true,
    },
    event = { "BufReadPost", "BufNewFile" },
  },

  -- ======= NVIM-LSPCONFIG FOR JAVA/GO/PYTHON/RUST/C =======
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      servers = {
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
      },
    },
  },

  -- ======= 文件浏览 (nvim-tree) =======
  {
    "nvim-tree/nvim-tree.lua",
    event = "VeryLazy",
    config = function()
      require("nvim-tree").setup()
    end,
  },

  -- ======= 状态栏 (lualine) =======
  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    config = function()
      require("lualine").setup({
        options = { theme = "gruvbox" }, -- or 'auto' or any modern theme
      })
    end,
  },

  -- ======= 配色方案 (推荐 catppuccin / gruvbox) =======
  -- 提升美观和舒适度
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    config = function()
      vim.cmd.colorscheme("catppuccin-macchiato")
    end,
  },

  -- ======= Refactoring（重构工具） =======
  {
    "ThePrimeagen/refactoring.nvim",
    event = "VeryLazy",
    opts = {},
    keys = {
      {
        "<leader>re",
        function() require("refactoring").select_refactor() end,
        mode = { "v" },
        desc = "Refactor (select)",
      },
    },
  },

  -- ======= 颜色可视化 =======
  {
    "NvChad/nvim-colorizer.lua",
    event = { "BufReadPost", "BufNewFile" },
    opts = {},
  },

  -- ======= 测试框架（Neotest + 适配器） =======
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      -- 常用语言适配器（按需自动启用）
      "nvim-neotest/neotest-go",
      "nvim-neotest/neotest-python",
      "rouge8/neotest-rust",
      -- 扩展语言支持
      "nvim-neotest/neotest-plenary",      -- Lua (plenary/busted)
      "haydenmeade/neotest-jest",          -- JavaScript/TypeScript (Jest)
      "marilari88/neotest-vitest",         -- JavaScript/TypeScript (Vitest)
      "rcasia/neotest-java",               -- Java (Maven/Gradle)
      "nvim-neotest/neotest-vim-test",     -- 通过 vim-test 覆盖更多语言
    },
    config = function()
      local adapters = {}
      local function add(mod, conf)
        local ok, m = pcall(require, mod)
        if ok then table.insert(adapters, conf and m(conf) or m()) end
      end

      -- Go: 禁止缓存提高反馈，启用表格测试解析
      add("neotest-go", {
        experimental = { test_table = true },
        args = { "-count=1", "-race" },
      })

      -- Python: 强制使用 pytest，尽量使用项目虚拟环境的 python
      local function detect_python()
        local venv = os.getenv("VIRTUAL_ENV")
        if venv and #venv > 0 then return venv .. "/bin/python" end
        -- 项目本地 .venv 优先
        local cwd = vim.fn.getcwd()
        if vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
          return cwd .. "/.venv/bin/python"
        end
        return "python3"
      end
      add("neotest-python", {
        dap = { justMyCode = false },
        runner = "pytest",
        python = detect_python,
        args = { "-q" },
      })

      -- Rust: 展示测试输出，默认不截断
      add("neotest-rust", {
        args = { "--", "--nocapture" },
      })

      -- Lua (plenary): 按需启用
      add("neotest-plenary")

      -- JavaScript/TypeScript (Jest): 自动选择包管理器
      local function has(p)
        return vim.fn.filereadable(vim.fn.getcwd() .. "/" .. p) == 1
      end
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
      add("neotest-jest", {
        jestCommand = jest_cmd(),
        jestConfigFile = function()
          for _, f in ipairs({ "jest.config.ts", "jest.config.js", "jest.config.cjs", "jest.config.mjs" }) do
            if has(f) then return f end
          end
        end,
        env = { CI = "1" },
      })

      -- JavaScript/TypeScript (Vitest)
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
      add("neotest-vitest", {
        vitestCommand = vitest_cmd(),
        env = { CI = "1" },
      })

      -- Java (Maven/Gradle)
      add("neotest-java")

      -- 通过 vim-test 兜底更多语言（如 Ruby/Elixir/Make 等）
      add("neotest-vim-test", {
        ignore_file_types = { "python", "go", "rust", "javascript", "typescript" },
      })

      require("neotest").setup({ adapters = adapters })

      local neotest = require("neotest")
      vim.keymap.set("n", "<leader>tt", function() neotest.run.run() end, { desc = "Test nearest" })
      vim.keymap.set("n", "<leader>tf", function() neotest.run.run(vim.fn.expand("%")) end, { desc = "Test file" })
      vim.keymap.set("n", "<leader>ts", function() neotest.summary.toggle() end, { desc = "Test summary" })
      vim.keymap.set("n", "<leader>to", function() neotest.output.open({ enter = true }) end, { desc = "Test output" })
      vim.keymap.set("n", "<leader>tS", function() neotest.run.stop() end, { desc = "Test stop" })
    end,
  },

  -- ======= 撤销树（Undo-Tree） =======
  {
    "mbbill/undotree",
    cmd = { "UndotreeToggle", "UndotreeShow" },
    keys = {
      { "<leader>uu", "<cmd>UndotreeToggle<CR>", desc = "Toggle undotree" },
    },
  },
}
