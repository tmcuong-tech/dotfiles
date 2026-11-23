-- LazyVim extras used as the base of this IDE setup.
-- Importing them here keeps the list explicit and easy to extend.
return {
  -- nvim-dap + nvim-dap-ui + virtual text + mason-nvim-dap
  { import = "lazyvim.plugins.extras.dap.core" },

  -- C/C++: clangd, clangd_extensions and a CodeLLDB configuration
  { import = "lazyvim.plugins.extras.lang.clangd" },

  -- Python: pyright + ruff, venv-selector and nvim-dap-python
  { import = "lazyvim.plugins.extras.lang.python" },

  -- Rust: rustaceanvim (rust-analyzer + debuggables) and crates.nvim
  { import = "lazyvim.plugins.extras.lang.rust" },
}
