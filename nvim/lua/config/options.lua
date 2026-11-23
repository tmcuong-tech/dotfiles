-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here

-- LSP / diagnostics feel more like an IDE when these are fairly low.
vim.opt.updatetime = 200
vim.opt.redrawtime = 3000
vim.opt.signcolumn = "yes"

-- Keep the language servers used by the extras predictable.
-- These must be set *before* the plugin specs are loaded.
vim.g.lazyvim_python_lsp = "pyright"
vim.g.lazyvim_python_ruff = "ruff"
vim.g.lazyvim_rust_diagnostics = "rust-analyzer"

-- Neovim does not detect assembly files out of the box.
-- `.s` / `.S` are GAS on Linux, `.asm`/`.nasm` are NASM style; asm-lsp
-- understands both and nvim-treesitter uses the `asm` parser for them.
vim.filetype.add({
  extension = {
    s = "asm",
    S = "asm",
    asm = "asm",
    nasm = "asm",
  },
})
