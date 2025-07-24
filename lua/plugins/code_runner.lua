-- 文件：lua/plugins/code_runner.lua
return {
  "CRAG666/code_runner.nvim",
  config = function()
    require("code_runner").setup({
      filetype = {
        python = "python3 -u",
        java = [[
          cd $dir
          if [ -f gradlew ] || [ -f build.gradle ] || [ -f build.gradle.kts ]; then
            if [ -f gradlew ]; then
              ./gradlew build --quiet && ./gradlew run --quiet
            else
              gradle build && gradle run
            fi
          else
            javac $fileName && java $fileNameWithoutExt
          fi
        ]],
        c = [[
          cd $dir
          if [ -f Makefile ] || [ -f makefile ]; then
            make
          else
            gcc $fileName -o $fileNameWithoutExt && $dir/$fileNameWithoutExt
          fi
        ]],
        rust = [[
          cd $dir/..
          if [ -f Cargo.toml ]; then
            cargo run
          else
            rustc $fileName -o $fileNameWithoutExt && $dir/$fileNameWithoutExt
          fi
        ]],
        go = [[
          cd $dir
          if [ -f go.mod ]; then
            go run .
          else
            go run $fileName
          fi
        ]],
      },
    })
    vim.keymap.set("n", "<F5>", ":RunCode<CR>", { noremap = true, silent = true })
  end,
}
