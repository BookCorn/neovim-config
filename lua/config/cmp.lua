-- ~/.config/nvim/lua/config/cmp.lua
local cmp = require("cmp")

cmp.setup({
  -- 其它你原有的配置 …
  mapping = vim.tbl_extend("force", cmp.mapping.preset.insert(), {
    -- Tab：有补全菜单就下一个，否则正常跳格
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback() -- 跳格/缩进
      end
    end, { "i", "s" }),

    -- Shift-Tab：有补全菜单就上一个，否则正常退格
    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { "i", "s" }),

    -- 禁用 Enter 确认（或改成你想要的行为）
    ["<CR>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        -- 如果你还想保留回车确认最后选中项，可以改成：
        -- cmp.confirm({ select = true })
        -- 这里直接 fallback，让它像普通回车那样换行
        fallback()
      else
        fallback()
      end
    end, { "i", "s" }),
  }),
})
