-- LSP servers and global diagnostic behaviour.
-- Server-specific setup for C/C++/Python/Rust mostly comes from the extras;
-- this file fills the gaps (assembly, diagnostic timing, code lens, ...).
return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      diagnostics = {
        -- Refresh diagnostics while typing, not only on InsertLeave.
        update_in_insert = true,
        -- tiny-inline-diagnostic.nvim renders the messages (see diagnostics.lua).
        virtual_text = false,
        virtual_lines = false,
        severity_sort = true,
      },
      inlay_hints = { enabled = true },
      codelens = { enabled = true },

      servers = {
        -- asm-lsp supports NASM/GAS/GO assembly. Filetypes are registered in
        -- config/options.lua so .s/.S/.asm buffers get an LSP as well.
        asm_lsp = {
          -- The binary is installed manually (see README.md), so enable the
          -- server directly instead of waiting for Mason to provide it.
          mason = false,
          filetypes = { "asm", "vmasm" },
          root_markers = { ".asm-lsp.toml", "Makefile", ".git" },
        },

        clangd = {
          -- clangd 23 needs an explicit value; the LazyVim default flag
          -- without a value is rejected on startup.
          cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders=1",
            "--fallback-style=llvm",
          },
        },

        pyright = {
          settings = {
            python = {
              analysis = {
                typeCheckingMode = "basic",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "openFilesOnly",
              },
            },
          },
        },

        -- rustaceanvim owns rust-analyzer; do not set it up twice.
        rust_analyzer = { enabled = false },
      },
    },
  },
}
