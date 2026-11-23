-- Format on save is already enabled by LazyVim; declare the formatter per
-- language here so every supported language has a sensible default.
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
        c = { "clang_format" },
        cpp = { "clang_format" },
        python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
        rust = { "rustfmt" },
        -- assembly has no reliable formatter; leave it untouched.
      })

      opts.formatters = vim.tbl_deep_extend("force", opts.formatters or {}, {
        -- Respect a project .clang-format when present, otherwise use LLVM style.
        clang_format = { prepend_args = { "--style=file:LLVM" } },
      })
    end,
  },
}
