local function gh(repo)
  return "https://github.com/" .. repo
end

local specs = {
  gh("folke/which-key.nvim"),
  gh("lewis6991/gitsigns.nvim"),
  gh("folke/flash.nvim"),
  gh("nvim-tree/nvim-web-devicons"),
  gh("nvim-tree/nvim-tree.lua"),
  gh("akinsho/bufferline.nvim"),
  gh("nvim-lualine/lualine.nvim"),
  { src = gh("catppuccin/nvim"), name = "catppuccin" },
  gh("ellisonleao/gruvbox.nvim"),
  gh("vyfor/cord.nvim"),
  { src = gh("saghen/blink.cmp"), version = "v1" },
  gh("rafamadriz/friendly-snippets"),
  gh("zbirenbaum/copilot.lua"),
  gh("fang2hou/blink-copilot"),
  gh("CRAG666/code_runner.nvim"),
  gh("stevearc/conform.nvim"),
  gh("nvim-telescope/telescope.nvim"),
  gh("rmagatti/goto-preview"),
  gh("neovim/nvim-lspconfig"),
  gh("mason-org/mason.nvim"),
  gh("WhoIsSethDaniel/mason-tool-installer.nvim"),
  gh("MeanderingProgrammer/render-markdown.nvim"),
  gh("iamcco/markdown-preview.nvim"),
  gh("nvim-treesitter/nvim-treesitter"),
  gh("ThePrimeagen/refactoring.nvim"),
  gh("lewis6991/async.nvim"),
  gh("NvChad/nvim-colorizer.lua"),
  gh("mbbill/undotree"),
  gh("nvim-mini/mini.pairs"),
  gh("kylechui/nvim-surround"),
  gh("sustech-data/wildfire.nvim"),
  { src = gh("brenton-leighton/multiple-cursors.nvim"), version = "main" },
  gh("gbprod/yanky.nvim"),
  gh("kawre/leetcode.nvim"),
  gh("nvim-lua/plenary.nvim"),
  gh("MunifTanjim/nui.nvim"),
  gh("nvim-neotest/neotest"),
  gh("nvim-neotest/nvim-nio"),
  gh("antoinemadec/FixCursorHold.nvim"),
  gh("nvim-neotest/neotest-go"),
  gh("nvim-neotest/neotest-python"),
  gh("rouge8/neotest-rust"),
  gh("nvim-neotest/neotest-plenary"),
  gh("haydenmeade/neotest-jest"),
  gh("marilari88/neotest-vitest"),
  gh("rcasia/neotest-java"),
  gh("nvim-neotest/neotest-vim-test"),
}

vim.pack.add(specs, {
  load = function() end,
})

local markdown_preview_app = vim.fs.joinpath(
  vim.fn.stdpath("data"),
  "site",
  "pack",
  "core",
  "opt",
  "markdown-preview.nvim",
  "app"
)

local function ensure_markdown_preview_deps()
  if vim.fn.isdirectory(markdown_preview_app) == 0 then
    return
  end
  if vim.fn.isdirectory(vim.fs.joinpath(markdown_preview_app, "node_modules")) == 1 then
    return
  end
  if vim.g.__mkdp_install_started then
    return
  end
  if vim.fn.executable("npm") ~= 1 then
    vim.schedule(function()
      vim.notify("markdown-preview.nvim needs npm to install browser preview dependencies.", vim.log.levels.WARN)
    end)
    return
  end

  vim.g.__mkdp_install_started = true
  vim.schedule(function()
    vim.notify("Installing markdown-preview.nvim dependencies with npm...", vim.log.levels.INFO)
  end)

  vim.system({ "npm", "install" }, { cwd = markdown_preview_app }, function(result)
    vim.schedule(function()
      if result.code == 0 then
        vim.notify("markdown-preview.nvim dependencies installed.", vim.log.levels.INFO)
      else
        vim.notify(result.stderr ~= "" and result.stderr or "npm install failed for markdown-preview.nvim", vim.log.levels.ERROR)
      end
    end)
  end)
end

if vim.fn.exists(":MarkdownPreviewInstallDeps") == 0 then
  vim.api.nvim_create_user_command("MarkdownPreviewInstallDeps", ensure_markdown_preview_deps, {
    desc = "Install markdown-preview.nvim browser preview dependencies",
  })
end

if vim.fn.exists(":PackUpdate") == 0 then
  vim.api.nvim_create_user_command("PackUpdate", function()
    vim.pack.update()
  end, { desc = "Update plugins managed by vim.pack" })
end
