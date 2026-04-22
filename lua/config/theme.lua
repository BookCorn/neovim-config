local M = {}

local LIGHT_THEME_PATTERNS = {
  "light",
  "day",
  "latte",
  "paper",
  "github light",
  "solarized light",
  "one light",
}

local THEMES = {
  dark = {
    background = "dark",
    colorscheme = "gruvbox",
    lualine = "gruvbox",
  },
  light = {
    background = "light",
    colorscheme = "catppuccin-latte",
    lualine = "auto",
  },
}

local function normalize(text)
  return (text or ""):lower()
end

local function apply_lualine_theme(name)
  local ok, lualine = pcall(require, "lualine")
  if not ok then
    return
  end

  lualine.setup({
    options = {
      theme = name,
      globalstatus = true,
    },
  })
end

local function is_light_terminal_theme(name)
  local value = normalize(name)
  for _, pattern in ipairs(LIGHT_THEME_PATTERNS) do
    if value:find(pattern, 1, true) then
      return true
    end
  end
  return false
end

local function detect_from_ghostty()
  if vim.env.TERM_PROGRAM ~= "ghostty" then
    return nil
  end

  local home = vim.env.HOME
  if not home or home == "" then
    return nil
  end

  local path = vim.fs.joinpath(home, "Library", "Application Support", "com.mitchellh.ghostty", "config")
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return nil
  end

  for _, line in ipairs(lines) do
    local trimmed = vim.trim(line)
    if trimmed ~= "" and not trimmed:match("^#") then
      local theme_name = trimmed:match("^theme%s*=%s*(.+)$")
      if theme_name then
        return is_light_terminal_theme(theme_name) and "light" or "dark"
      end
    end
  end

  return nil
end

local function apply_variant_highlights(variant)
  if variant == "light" then
    vim.api.nvim_set_hl(0, "Normal", { bg = "#eff1f5" })
    vim.api.nvim_set_hl(0, "NormalNC", { bg = "#eff1f5" })
    vim.api.nvim_set_hl(0, "SignColumn", { bg = "#eff1f5" })
    vim.api.nvim_set_hl(0, "EndOfBuffer", { bg = "#eff1f5" })
    return
  end

  vim.api.nvim_set_hl(0, "Normal", {})
  vim.api.nvim_set_hl(0, "NormalNC", {})
  vim.api.nvim_set_hl(0, "SignColumn", {})
  vim.api.nvim_set_hl(0, "EndOfBuffer", {})
end

function M.apply(variant)
  local theme = THEMES[variant]
  if not theme then
    return
  end

  vim.g.colors_name_preferred = variant
  vim.o.background = theme.background
  vim.cmd.colorscheme(theme.colorscheme)
  apply_variant_highlights(variant)
  apply_lualine_theme(theme.lualine)
end

function M.toggle()
  local next_variant = vim.g.colors_name_preferred == "light" and "dark" or "light"
  M.apply(next_variant)
end

function M.setup()
  M.apply(vim.g.colors_name_preferred or detect_from_ghostty() or "dark")
end

return M
