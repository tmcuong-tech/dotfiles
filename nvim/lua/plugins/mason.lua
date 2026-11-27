-- Mason provides the package manager UI and registry integration.
return {
  {
    "mason-org/mason.nvim",
  },

  -- mason.nvim itself does not install packages from an ensure_installed list.
  -- This plugin owns the list and installs missing tools after startup.
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    dependencies = { "mason-org/mason.nvim" },
    opts = {
      ensure_installed = {
        -- Language servers
        "clangd",
        "pyright",
        "ruff", -- also used as the Python formatter and linter
        -- Install asm-lsp separately with Cargo or a matching release binary;
        -- see README.md for the cross-platform setup.
        "rust-analyzer", -- required by rustaceanvim
        -- Formatters / debuggers
        "clang-format",
        "prettier",
        "shfmt",
        "debugpy", -- provides `debugpy-adapter` for nvim-dap-python
        "codelldb", -- C/C++/Rust debugging
        -- Editor helpers
        "stylua",
      },
      auto_update = false,
      run_on_start = true,
      start_delay = 3000,
    },
  },

  -- Debug adapters installed by Mason. The Python handler is intentionally
  -- empty so it does not fight with nvim-dap-python from the Python extra.
  {
    "jay-babu/mason-nvim-dap.nvim",
    optional = true,
    opts = {
      handlers = {
        python = function() end,
      },
    },
  },
}
