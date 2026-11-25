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
      })

      -- LazyVim extras also add some of these tools. Keep one install request
      -- per Mason package so overlapping extras do not start duplicate jobs.
      local seen = {}
      opts.ensure_installed = vim.tbl_filter(function(package)
        if seen[package] then
          return false
        end
        seen[package] = true
        return true
      end, opts.ensure_installed)
    end,
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
