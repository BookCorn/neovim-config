# Neovim

This configuration uses Neovim 0.12's built-in `vim.pack` plugin manager.

## Maintenance

- `:PackUpdate` updates plugins managed by `vim.pack`.
- `:MasonToolsInstall` installs configured Mason tools such as `gopls`.
- `:TSInstallConfigured` installs configured Treesitter parsers. Use `:TSInstallConfigured!` in headless/bootstrap scripts to wait for completion.
- `:TSUpdateConfigured` updates configured Treesitter parsers. Use `:TSUpdateConfigured!` in headless/bootstrap scripts to wait for completion.
- `:MarkdownPreviewInstallDeps` installs the browser preview dependencies for `markdown-preview.nvim`.
