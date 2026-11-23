-- One place to declare the external tools this IDE needs.
-- Install them with `:Mason` (or `:Lazy sync`, which triggers ensure_installed).
return {
  {
    "mason-org/mason.nvim",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        -- Language servers
        "clangd",
        "pyright",
        "ruff", -- also used as the Python formatter and linter
        -- asm-lsp is installed manually from its GitHub release: Mason builds
        -- it from source and that fails against OpenSSL 4. See README.md.
        "rust-analyzer", -- required by rustaceanvim
        -- Formatters / debuggers
        "clang-format",
        "debugpy", -- provides `debugpy-adapter` for nvim-dap-python
        "codelldb", -- C/C++/Rust debugging
        -- Editor helpers
        "stylua",
      })
    end,
  },

  -- Debug adapters installed by Mason. The Python handler is intentionally
  -- empty so it does not fight with nvim-dap-python from the Python extra.
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = {
      ensure_installed = { "codelldb", "debugpy" },
      handlers = {
        python = function() end,
      },
    },
  },
}
