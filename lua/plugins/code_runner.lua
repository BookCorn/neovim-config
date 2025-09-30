-- 文件：lua/plugins/code_runner.lua
return {
  "CRAG666/code_runner.nvim",
  config = function()
    require("code_runner").setup({
      filetype = {
        -- Python: prefer Poetry/Pipenv/.venv, fallback to python3
        python = [[
          cd "$dir"
          if command -v poetry >/dev/null 2>&1 && [ -f "pyproject.toml" ]; then
            poetry run python -u "$fileName"
          elif command -v pipenv >/dev/null 2>&1 && [ -f "Pipfile" ]; then
            pipenv run python -u "$fileName"
          elif [ -x ".venv/bin/python" ]; then
            .venv/bin/python -u "$fileName"
          elif [ -n "$VIRTUAL_ENV" ] && [ -x "$VIRTUAL_ENV/bin/python" ]; then
            "$VIRTUAL_ENV/bin/python" -u "$fileName"
          else
            python3 -u "$fileName"
          fi
        ]],

        -- Java: Gradle(run) when present, fallback to single-file javac/java
        java = [[
          cd "$dir"
          if [ -f gradlew ] || [ -f build.gradle ] || [ -f build.gradle.kts ]; then
            if [ -f gradlew ]; then
              ./gradlew --quiet build && ./gradlew --quiet run
            else
              gradle --quiet build && gradle --quiet run
            fi
          else
            javac "$fileName" && java -cp "$dir" "$fileNameWithoutExt"
          fi
        ]],

        -- C: Makefile if present; else compile with warnings and run
        c = [[
          cd "$dir"
          if [ -f Makefile ] || [ -f makefile ]; then
            make run 2>/dev/null || make
            [ -x "$dir/$fileNameWithoutExt" ] && "$dir/$fileNameWithoutExt"
          else
            COMPILER=""
            if command -v cc >/dev/null 2>&1; then COMPILER=cc
            elif command -v gcc >/dev/null 2>&1; then COMPILER=gcc
            else COMPILER=gcc
            fi
            "$COMPILER" -std=c11 -O2 -Wall -Wextra "$fileName" -o "$fileNameWithoutExt" && "$dir/$fileNameWithoutExt"
          fi
        ]],

        -- C++: similar to C, with C++17
        cpp = [[
          cd "$dir"
          if [ -f Makefile ] || [ -f makefile ]; then
            make run 2>/dev/null || make
            [ -x "$dir/$fileNameWithoutExt" ] && "$dir/$fileNameWithoutExt"
          else
            CXX=""
            if command -v c++ >/dev/null 2>&1; then CXX=c++
            elif command -v g++ >/dev/null 2>&1; then CXX=g++
            else CXX=c++
            fi
            "$CXX" -std=c++17 -O2 -Wall -Wextra "$fileName" -o "$fileNameWithoutExt" && "$dir/$fileNameWithoutExt"
          fi
        ]],

        -- Rust: find nearest Cargo.toml upwards; else rustc single file
        rust = [[
          root=""
          d="$dir"
          while [ "$d" != "/" ]; do
            if [ -f "$d/Cargo.toml" ]; then root="$d"; break; fi
            d="$(dirname "$d")"
          done
          if [ -n "$root" ]; then
            cd "$root" && cargo run --quiet
          else
            cd "$dir" && rustc "$fileName" -O -o "$fileNameWithoutExt" && "$dir/$fileNameWithoutExt"
          fi
        ]],

        -- Go: if in module, run from module root; else run current file
        go = [[
          gomod="$(go env GOMOD 2>/dev/null)"
          if [ -n "$gomod" ] && [ -f "$gomod" ]; then
            cd "$(dirname "$gomod")" && go run .
          else
            cd "$dir" && go run "$fileName"
          fi
        ]],
      },
    })
    vim.keymap.set("n", "<F5>", ":RunCode<CR>", { noremap = true, silent = true })
  end,
}
