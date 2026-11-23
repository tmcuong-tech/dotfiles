-- Linting is mostly covered by the language servers in this setup:
--   clangd (--clang-tidy) -> C/C++
--   ruff LSP             -> Python (enabled by the Python extra)
--   rust-analyzer/clippy -> Rust
-- Keep this file as the single place to add external linters later, e.g.:
--   opts.linters_by_ft = { python = { "flake8" } }
return {
  {
    "mfussenegger/nvim-lint",
    opts = function(_, opts)
      opts.linters_by_ft = opts.linters_by_ft or {}
    end,
  },
}
