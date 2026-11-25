-- Format on save is already enabled by LazyVim; declare the formatter per
-- language here so every supported language has a sensible default.
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      opts.formatters_by_ft = vim.tbl_deep_extend("force", opts.formatters_by_ft or {}, {
        c = { "clang_format" },
        cpp = { "clang_format" },
        lua = { "stylua" },
        python = { "ruff_fix", "ruff_organize_imports", "ruff_format" },
        rust = { "rustfmt" },
        sh = { "shfmt" },
        javascript = { "prettier" },
        javascriptreact = { "prettier" },
        typescript = { "prettier" },
        typescriptreact = { "prettier" },
        json = { "prettier" },
        jsonc = { "prettier" },
        html = { "prettier" },
        css = { "prettier" },
        scss = { "prettier" },
        yaml = { "prettier" },
        markdown = { "prettier" },
        -- Assembly, Vimscript, query, regex, and LaTeX have no formatter
        -- configured for this setup.
      })

      opts.formatters = vim.tbl_deep_extend("force", opts.formatters or {}, {
        -- Respect a project .clang-format when present, otherwise fall back to LLVM.
        clang_format = {
          prepend_args = { "--style=file", "--fallback-style=LLVM" },
        },
      })
    end,
  },
}
