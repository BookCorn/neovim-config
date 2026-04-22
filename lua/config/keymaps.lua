local function close_tab_or_buffer()
  if #vim.api.nvim_list_tabpages() > 1 then
    vim.cmd("tabclose")
    return
  end

  local bufnr = vim.api.nvim_get_current_buf()
  local listed = vim.fn.getbufinfo({ buflisted = 1 })
  if #listed > 1 then
    vim.cmd("bnext")
  end

  vim.cmd("bdelete " .. bufnr)
end

local function delete_current_buffer()
  local bufnr = vim.api.nvim_get_current_buf()
  local listed = vim.fn.getbufinfo({ buflisted = 1 })
  if #listed > 1 then
    vim.cmd("bnext")
  end
  vim.cmd("bdelete " .. bufnr)
end

local function delete_other_buffers()
  local current = vim.api.nvim_get_current_buf()
  for _, buffer in ipairs(vim.fn.getbufinfo({ buflisted = 1 })) do
    if buffer.bufnr ~= current then
      pcall(vim.cmd, "bdelete " .. buffer.bufnr)
    end
  end
end

local function diagnostic_jump(next, severity)
  return function()
    vim.diagnostic.jump({
      count = (next and 1 or -1) * vim.v.count1,
      severity = severity and vim.diagnostic.severity[severity] or nil,
      float = true,
    })
  end
end

local map = vim.keymap.set
local lsp = vim.lsp.buf

local function telescope_builtin(name, opts)
  return function()
    local ok, builtin = pcall(require, "telescope.builtin")
    if not ok then
      vim.notify("telescope.nvim is not available", vim.log.levels.WARN)
      return
    end

    builtin[name](opts or {})
  end
end

map({ "n", "x" }, "j", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "<Down>", "v:count == 0 ? 'gj' : 'j'", { desc = "Down", expr = true, silent = true })
map({ "n", "x" }, "k", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })
map({ "n", "x" }, "<Up>", "v:count == 0 ? 'gk' : 'k'", { desc = "Up", expr = true, silent = true })

map("n", "<C-h>", "<C-w>h", { desc = "Go to Left Window", remap = true })
map("n", "<C-j>", "<C-w>j", { desc = "Go to Lower Window", remap = true })
map("n", "<C-k>", "<C-w>k", { desc = "Go to Upper Window", remap = true })
map("n", "<C-l>", "<C-w>l", { desc = "Go to Right Window", remap = true })

map("n", "<C-Up>", "<cmd>resize +2<CR>", { desc = "Increase Window Height" })
map("n", "<C-Down>", "<cmd>resize -2<CR>", { desc = "Decrease Window Height" })
map("n", "<C-Left>", "<cmd>vertical resize -2<CR>", { desc = "Decrease Window Width" })
map("n", "<C-Right>", "<cmd>vertical resize +2<CR>", { desc = "Increase Window Width" })

map("n", "<A-j>", "<cmd>execute 'move .+' . v:count1<CR>==", { desc = "Move Down" })
map("n", "<A-k>", "<cmd>execute 'move .-' . (v:count1 + 1)<CR>==", { desc = "Move Up" })
map("i", "<A-j>", "<Esc><cmd>m .+1<CR>==gi", { desc = "Move Down" })
map("i", "<A-k>", "<Esc><cmd>m .-2<CR>==gi", { desc = "Move Up" })
map("v", "<A-j>", ":<C-u>execute \"'<,'>move '>+\" . v:count1<CR>gv=gv", { desc = "Move Down" })
map("v", "<A-k>", ":<C-u>execute \"'<,'>move '<-\" . (v:count1 + 1)<CR>gv=gv", { desc = "Move Up" })

map("n", "<S-h>", "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev Buffer" })
map("n", "<S-l>", "<cmd>BufferLineCycleNext<CR>", { desc = "Next Buffer" })
map("n", "[b", "<cmd>BufferLineCyclePrev<CR>", { desc = "Prev Buffer" })
map("n", "]b", "<cmd>BufferLineCycleNext<CR>", { desc = "Next Buffer" })
map("n", "[B", "<cmd>BufferLineMovePrev<CR>", { desc = "Move Buffer Prev" })
map("n", "]B", "<cmd>BufferLineMoveNext<CR>", { desc = "Move Buffer Next" })
map("n", "<leader>bb", "<cmd>e #<CR>", { desc = "Switch to Other Buffer" })
map("n", "<leader>`", "<cmd>e #<CR>", { desc = "Switch to Other Buffer" })
map("n", "<leader>bd", delete_current_buffer, { desc = "Delete Buffer" })
map("n", "<leader>bo", delete_other_buffers, { desc = "Delete Other Buffers" })
map("n", "<leader>bp", "<cmd>BufferLineTogglePin<CR>", { desc = "Toggle Pin" })
map("n", "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<CR>", { desc = "Delete Non-Pinned Buffers" })
map("n", "<leader>br", "<cmd>BufferLineCloseRight<CR>", { desc = "Delete Buffers to the Right" })
map("n", "<leader>bl", "<cmd>BufferLineCloseLeft<CR>", { desc = "Delete Buffers to the Left" })
map("n", "<leader><tab>d", close_tab_or_buffer, { desc = "Close tab or buffer" })
map("n", "<C-x>", close_tab_or_buffer, { desc = "Close tab or buffer" })

map({ "i", "n", "s" }, "<Esc>", function()
  vim.cmd("noh")
  return "<Esc>"
end, { expr = true, desc = "Escape and Clear hlsearch" })

map("n", "n", "'Nn'[v:searchforward].'zv'", { expr = true, desc = "Next Search Result" })
map("x", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("o", "n", "'Nn'[v:searchforward]", { expr = true, desc = "Next Search Result" })
map("n", "N", "'nN'[v:searchforward].'zv'", { expr = true, desc = "Prev Search Result" })
map("x", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })
map("o", "N", "'nN'[v:searchforward]", { expr = true, desc = "Prev Search Result" })

map("i", ",", ",<C-g>u")
map("i", ".", ".<C-g>u")
map("i", ";", ";<C-g>u")

map({ "i", "x", "n", "s" }, "<C-s>", "<cmd>w<CR><Esc>", { desc = "Save File" })
map("x", "<", "<gv")
map("x", ">", ">gv")

map("n", "<leader>e", "<cmd>NvimTreeToggle<CR>", { desc = "Toggle file explorer" })
map("n", "<leader>fn", "<cmd>enew<CR>", { desc = "New File" })
map("n", "<leader>qq", "<cmd>qa<CR>", { desc = "Quit All" })
map("n", "<leader>sf", telescope_builtin("find_files"), { desc = "Search Files" })
map("n", "<leader>sg", telescope_builtin("live_grep"), { desc = "Search by Grep" })
map("n", "<leader>sb", telescope_builtin("buffers"), { desc = "Search Buffers" })
map("n", "<leader>sh", telescope_builtin("help_tags"), { desc = "Search Help" })
map("n", "<leader>ut", function()
  require("config.theme").toggle()
end, { desc = "Toggle Light/Dark Theme" })
map("n", "<leader>sk", function()
  telescope_builtin("keymaps", {
    layout_strategy = "horizontal",
    layout_config = {
      preview_width = 0.58,
      width = 0.92,
      height = 0.88,
    },
    sorting_strategy = "ascending",
    previewer = true,
    show_plug = false,
  })()
end, { desc = "Search Keymaps" })

map({ "n", "x" }, "<leader>cf", function()
  local ok, conform = pcall(require, "conform")
  if ok then
    conform.format({ async = true, lsp_format = "fallback" })
  end
end, { desc = "Format" })

map("n", "<leader>xl", function()
  local winid = vim.fn.getloclist(0, { winid = 0 }).winid
  vim.cmd(winid ~= 0 and "lclose" or "lopen")
end, { desc = "Location List" })
map("n", "<leader>xq", function()
  local winid = vim.fn.getqflist({ winid = 0 }).winid
  vim.cmd(winid ~= 0 and "cclose" or "copen")
end, { desc = "Quickfix List" })
map("n", "[q", vim.cmd.cprev, { desc = "Previous Quickfix" })
map("n", "]q", vim.cmd.cnext, { desc = "Next Quickfix" })

map("n", "<leader>cd", vim.diagnostic.open_float, { desc = "Line Diagnostics" })
map("n", "]d", diagnostic_jump(true), { desc = "Next Diagnostic" })
map("n", "[d", diagnostic_jump(false), { desc = "Prev Diagnostic" })
map("n", "]e", diagnostic_jump(true, "ERROR"), { desc = "Next Error" })
map("n", "[e", diagnostic_jump(false, "ERROR"), { desc = "Prev Error" })
map("n", "]w", diagnostic_jump(true, "WARN"), { desc = "Next Warning" })
map("n", "[w", diagnostic_jump(false, "WARN"), { desc = "Prev Warning" })

map("n", "<leader>?", function()
  local ok, which_key = pcall(require, "which-key")
  if ok then
    which_key.show({ global = false })
  end
end, { desc = "Buffer Keymaps (which-key)" })
map("n", "<C-w><space>", function()
  local ok, which_key = pcall(require, "which-key")
  if ok then
    which_key.show({ keys = "<C-w>", loop = true })
  end
end, { desc = "Window Hydra Mode (which-key)" })

map("n", "<A-b>", function()
  if lsp.definition then
    lsp.definition()
  end
end, { desc = "LSP: Go to definition" })
map("n", "gd", function()
  if lsp.definition then
    lsp.definition()
  end
end, { desc = "LSP: Go to definition" })
map("n", "gD", function()
  if lsp.declaration then
    lsp.declaration()
  end
end, { desc = "LSP: Go to declaration" })
map("n", "<A-r>", function()
  if lsp.references then
    lsp.references()
  end
end, { desc = "LSP: Find references" })
map("n", "gR", function()
  if lsp.references then
    lsp.references()
  end
end, { desc = "LSP: Find references" })
map("n", "<A-i>", function()
  if lsp.implementation then
    lsp.implementation()
  end
end, { desc = "LSP: Go to implementation" })
map("n", "gi", function()
  if lsp.implementation then
    lsp.implementation()
  end
end, { desc = "LSP: Go to implementation" })
map("n", "<A-t>", function()
  if lsp.type_definition then
    lsp.type_definition()
  end
end, { desc = "LSP: Go to type definition" })
map("n", "gy", function()
  if lsp.type_definition then
    lsp.type_definition()
  end
end, { desc = "LSP: Go to type definition" })
map({ "n", "v" }, "K", function()
  if lsp.hover then
    lsp.hover()
  end
end, { desc = "LSP: Hover documentation" })
map({ "i", "n", "v" }, "<A-p>", function()
  if lsp.signature_help then
    lsp.signature_help()
  end
end, { desc = "LSP: Signature help" })

map("n", "<leader>-", "<C-w>s", { desc = "Split Window Below", remap = true })
map("n", "<leader>|", "<C-w>v", { desc = "Split Window Right", remap = true })
map("n", "<leader>wd", "<C-w>c", { desc = "Delete Window", remap = true })

map("n", "<leader><tab><tab>", "<cmd>tabnew<CR>", { desc = "New Tab" })
map("n", "<leader><tab>]", "<cmd>tabnext<CR>", { desc = "Next Tab" })
map("n", "<leader><tab>[", "<cmd>tabprevious<CR>", { desc = "Previous Tab" })
map("n", "<leader><tab>o", "<cmd>tabonly<CR>", { desc = "Close Other Tabs" })
