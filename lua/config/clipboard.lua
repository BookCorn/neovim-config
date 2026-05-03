local M = {}

local internal = {
  ["+"] = { lines = {}, regtype = "v" },
  ["*"] = { lines = {}, regtype = "v" },
}

local function executable(name)
  return vim.fn.executable(name) == 1
end

local function internal_copy(register)
  return function(lines, regtype)
    internal[register] = {
      lines = vim.deepcopy(lines),
      regtype = regtype,
    }
  end
end

local function osc52_sequence(clipboard, contents)
  return string.format("\027]52;%s;%s\027\\", clipboard, contents)
end

local function osc52_copy(register)
  local clipboard = register == "+" and "c" or "p"

  return function(lines, regtype)
    internal_copy(register)(lines, regtype)
    vim.api.nvim_ui_send(osc52_sequence(clipboard, vim.base64.encode(table.concat(lines, "\n"))))
  end
end

local function internal_paste(register)
  return function()
    local value = internal[register]
    return vim.deepcopy(value.lines), value.regtype
  end
end

local function internal_provider()
  return {
    name = "internal",
    copy = {
      ["+"] = internal_copy("+"),
      ["*"] = internal_copy("*"),
    },
    paste = {
      ["+"] = internal_paste("+"),
      ["*"] = internal_paste("*"),
    },
    cache_enabled = 0,
  }
end

local function osc52_copy_provider()
  return {
    name = "osc52-copy",
    copy = {
      ["+"] = osc52_copy("+"),
      ["*"] = osc52_copy("*"),
    },
    paste = {
      ["+"] = internal_paste("+"),
      ["*"] = internal_paste("*"),
    },
    cache_enabled = 0,
  }
end

function M.setup()
  local termfeatures = vim.g.termfeatures or {}
  termfeatures.osc52 = false
  vim.g.termfeatures = termfeatures

  if executable("pbcopy") and executable("pbpaste") then
    vim.g.clipboard = {
      name = "macOS",
      copy = {
        ["+"] = { "pbcopy" },
        ["*"] = { "pbcopy" },
      },
      paste = {
        ["+"] = { "pbpaste" },
        ["*"] = { "pbpaste" },
      },
      cache_enabled = 0,
    }
    return
  end

  if vim.env.WAYLAND_DISPLAY and executable("wl-copy") and executable("wl-paste") then
    vim.g.clipboard = {
      name = "wayland",
      copy = {
        ["+"] = { "wl-copy", "--type", "text/plain" },
        ["*"] = { "wl-copy", "--primary", "--type", "text/plain" },
      },
      paste = {
        ["+"] = { "wl-paste", "--no-newline" },
        ["*"] = { "wl-paste", "--primary", "--no-newline" },
      },
      cache_enabled = 0,
    }
    return
  end

  if executable("xclip") then
    vim.g.clipboard = {
      name = "xclip",
      copy = {
        ["+"] = { "xclip", "-selection", "clipboard" },
        ["*"] = { "xclip", "-selection", "primary" },
      },
      paste = {
        ["+"] = { "xclip", "-selection", "clipboard", "-o" },
        ["*"] = { "xclip", "-selection", "primary", "-o" },
      },
      cache_enabled = 0,
    }
    return
  end

  if executable("xsel") then
    vim.g.clipboard = {
      name = "xsel",
      copy = {
        ["+"] = { "xsel", "--clipboard", "--input" },
        ["*"] = { "xsel", "--primary", "--input" },
      },
      paste = {
        ["+"] = { "xsel", "--clipboard", "--output" },
        ["*"] = { "xsel", "--primary", "--output" },
      },
      cache_enabled = 0,
    }
    return
  end

  if vim.g.clipboard_osc52 == false then
    vim.g.clipboard = internal_provider()
    return
  end

  vim.g.clipboard = osc52_copy_provider()
end

return M
