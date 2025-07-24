-- 覆写 nvim-cmp 在 LazyVim 里的默认按键
return {
  "hrsh7th/nvim-cmp",
  -- Priority 越大越晚执行，这样能覆盖 LazyVim 自带的 mapping
  priority = 1001,
  opts = function(_, opts)
    local cmp = require("cmp")
    local luasnip = require("luasnip")

    -- 判断光标前是否有非空格，用于决定 Tab 是跳补全还是缩进
    local has_words_before = function()
      local line, col = unpack(vim.api.nvim_win_get_cursor(0))
      return col ~= 0 and vim.api.nvim_buf_get_text(0, line - 1, col - 1, line - 1, col, {})[1]:match("%S")
    end

    -- 在原有 mapping 基础上覆盖 / 新增
    opts.mapping = vim.tbl_extend("force", opts.mapping or {}, {
      ----------------------------------------------------------------------------
      -- ① Tab：补全菜单可见 -> confirm；否则(有 snippet) -> 跳 snippet；否则 -> 缩进
      ----------------------------------------------------------------------------
      ["<Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          -- 选中条目直接 confirm，相当于 IDEA 的 Tab
          cmp.confirm({ select = true })
        elseif luasnip and luasnip.expand_or_jumpable() then
          luasnip.expand_or_jump()
        elseif has_words_before() then
          cmp.complete() -- 触发补全（可选，想和 IDEA 一样 Tab 时不触发可删掉）
        else
          fallback() -- 普通 Tab 缩进
        end
      end, { "i", "s" }),

      --------------------------------------------------------------------------
      -- ② Shift-Tab：补全菜单可见 -> 上一个；否则(有 snippet) -> 上一个 snippet
      --------------------------------------------------------------------------
      ["<S-Tab>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.select_prev_item()
        elseif luasnip and luasnip.jumpable(-1) then
          luasnip.jump(-1)
        else
          fallback()
        end
      end, { "i", "s" }),

      ----------------------------------------------------------------------------
      -- ③ Enter：永远只是换行（补全菜单仍然会保持，但不会 confirm）
      ----------------------------------------------------------------------------
      ["<CR>"] = cmp.mapping(function(fallback)
        if cmp.visible() then
          cmp.abort() -- 取消可见补全菜单
        end
        fallback() -- 执行 Neovim 默认 Enter → 换行 & autopairs
      end, { "i", "s" }),
    })
  end,
}
