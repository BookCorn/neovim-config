-- 文件：lua/plugins/code_runner.lua
return {
  "CRAG666/code_runner.nvim",
  config = function()
    require("code_runner").setup({
      filetype = {
        python = "python3 -u",
        java = "cd $dir && javac $fileName && java $fileNameWithoutExt",
        c = "cd $dir && gcc $fileName -o $fileNameWithoutExt && $dir/$fileNameWithoutExt",
        rust = [[
          # 切到项目根：如果有 Cargo.toml 就 cargo run，否则 rustc 单文件
          cd $dir/.. &&
          if [ -f Cargo.toml ]; then
            cargo run
          else
            rustc $fileName -o $fileNameWithoutExt &&
            $dir/$fileNameWithoutExt
          fi
        ]],
        go = "cd $dir && go run $fileName",
      },
    })
    vim.keymap.set("n", "<F5>", ":RunCode<CR>", { noremap = true, silent = true })
  end,
}
