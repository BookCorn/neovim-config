# Neovim

This server-focused configuration uses Neovim 0.12's built-in `vim.pack` plugin manager.

The branch keeps a small plugin set for SSH and operations work: Git signs, quick movement,
Telescope search, external LSPs, formatting hooks, Treesitter, pairs, surround, undo history,
and yank history. Desktop-only, AI, browser preview, Mason, LeetCode, and large test-runner
plugins are intentionally omitted.

## Maintenance

- `:PackUpdate` updates plugins managed by `vim.pack`.
- Install language servers and formatters with the server's package manager or project tooling.
- `:TSInstallConfigured` installs configured Treesitter parsers. Use `:TSInstallConfigured!` in headless/bootstrap scripts to wait for completion.
