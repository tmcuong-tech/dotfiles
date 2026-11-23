# 💤 LazyVim + IDE setup

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## IDE features

| Feature | Implementation | Config file |
| --- | --- | --- |
| LSP (C/C++, Python, Rust, Assembly) | `nvim-lspconfig` + LazyVim language extras | `lua/plugins/lsp.lua` |
| Diagnostics while typing (insert mode) | `update_in_insert = true` + `tiny-inline-diagnostic.nvim` | `lua/plugins/diagnostics.lua` |
| Completion / signatures / snippets | `blink.cmp` | `lua/plugins/completion.lua` |
| Debugging | `nvim-dap`, `nvim-dap-ui`, `gdb`, `codelldb`, `debugpy` | `lua/plugins/dap.lua`, `lua/util/dap.lua` |
| Formatting | `conform.nvim` (clang-format, ruff, rustfmt) | `lua/plugins/formatting.lua` |
| Linting | clangd (clang-tidy), ruff LSP, rust-analyzer | `lua/plugins/linting.lua` |
| Parsers / filetypes | `nvim-treesitter` + assembly filetype detection | `lua/plugins/treesitter.lua`, `lua/config/options.lua` |
| Assembly live errors | `gcc` / `nasm` check on the unsaved buffer | `lua/util/asm.lua`, `lua/config/autocmds.lua` |
| Tool installation | `mason.nvim` + manual `asm-lsp` binary | `lua/plugins/mason.lua` |

Every file under `lua/plugins/` is a standalone lazy.nvim spec. Add a new file
there to extend the setup without touching the others. lazy.nvim loads them in
alphabetical order, so use that if one spec needs to override another.

## First-time setup

1. Open Neovim and run `:Lazy sync` — installs plugins and the treesitter
   parsers listed in `lua/plugins/treesitter.lua`.
2. Run `:Mason`, then press `I` to install the tools listed in
   `lua/plugins/mason.lua` (`clangd`, `clang-format`, `pyright`, `ruff`,
   `rust-analyzer`, `debugpy`, `codelldb`, `stylua`).
3. `asm-lsp` is installed manually because Mason's source build fails with
   OpenSSL 4 on this machine:

   ```sh
   curl -fsSL https://github.com/bergercookie/asm-lsp/releases/download/v0.10.1/asm-lsp-x86_64-unknown-linux-gnu.tar.gz \
     | tar -xz -C ~/.local/bin
   ```

   `~/.local/bin` and Mason's `bin/` are added to `$PATH` in `init.lua`.
4. `asm-lsp` only publishes diagnostics on save. Live insert-mode assembly
   errors are produced by `lua/util/asm.lua` (GAS via `gcc`, NASM via `nasm`).
   For NASM projects, add a `.asm-lsp.toml` with `[opts] compiler = "nasm"` so
   `asm-lsp` does not apply its default GCC/GAS diagnostics to NASM syntax.
5. Run `:checkhealth` and `:Lazy health` to verify the installation.

## Keymaps (in addition to the LazyVim defaults)

| Key | Action |
| --- | --- |
| `<leader>rb` | Build current file |
| `<leader>rr` | Run current file in a terminal |
| `<leader>rd` | Start / continue debugging |
| `<leader>rn` | Debug: step over |
| `<leader>db` | Toggle breakpoint |
| `<leader>dc` | Start / continue debugging |
| `<leader>di` / `<leader>do` / `<leader>dO` | Step into / out / over |
| `<leader>du` | Toggle the DAP UI |
| `<leader>de` | Evaluate expression under cursor |
| `<leader>dr` | REPL (Rust buffers: RustLsp debuggables) |
| `<leader>ch` | Switch C/C++ source ↔ header |
| `<leader>uI` | Toggle inline diagnostics |

Debug configurations are chosen with `<leader>dc` when more than one is
available (for example *Build & Debug current file (gdb)* vs *Launch binary
(CodeLLDB)*).
