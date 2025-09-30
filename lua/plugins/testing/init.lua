-- Control which neotest adapters are installed via `vim.g.neotest_adapters` (list or map).
local function tbl_contains(list, value)
  for _, item in ipairs(list) do
    if item == value then
      return true
    end
  end
  return false
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

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      {
        "nvim-neotest/neotest-go",
        enabled = function()
          return is_adapter_enabled("go")
        end,
      },
      {
        "nvim-neotest/neotest-python",
        enabled = function()
          return is_adapter_enabled("python")
        end,
      },
      {
        "rouge8/neotest-rust",
        enabled = function()
          return is_adapter_enabled("rust")
        end,
      },
      {
        "nvim-neotest/neotest-plenary",
        enabled = function()
          return is_adapter_enabled("plenary")
        end,
      },
      {
        "haydenmeade/neotest-jest",
        enabled = function()
          return is_adapter_enabled("jest")
        end,
      },
      {
        "marilari88/neotest-vitest",
        enabled = function()
          return is_adapter_enabled("vitest")
        end,
      },
      {
        "rcasia/neotest-java",
        enabled = function()
          return is_adapter_enabled("java")
        end,
      },
      {
        "nvim-neotest/neotest-vim-test",
        enabled = function()
          return is_adapter_enabled("vim-test")
        end,
      },
    },
    opts = function()
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
            for _, file in ipairs({
              "jest.config.ts",
              "jest.config.js",
              "jest.config.cjs",
              "jest.config.mjs",
            }) do
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

      return { adapters = adapters }
    end,
    config = function(_, opts)
      local neotest = require("neotest")
      neotest.setup(opts)

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
    end,
  },
}
