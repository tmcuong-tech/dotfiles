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
| Markdown preview | `render-markdown.nvim` (full-buffer) | `lua/plugins/render-markdown.lua` |

Every file under `lua/plugins/` is a standalone lazy.nvim spec. Add a new file
there to extend the setup without touching the others. lazy.nvim loads them in
alphabetical order, so use that if one spec needs to override another.

## First-time setup

1. Open Neovim and run `:Lazy sync` — installs plugins and the treesitter
   parsers listed in `lua/plugins/treesitter.lua`.
2. Run `:Mason`, then press `I` to install the tools listed in
   `lua/plugins/mason.lua` (`clangd`, `clang-format`, `pyright`, `ruff`,
   `rust-analyzer`, `debugpy`, `codelldb`, `stylua`).
3. LaTeX formula rendering needs a converter. For a portable baseline on
   Windows and Linux, install the `latex2text` fallback with
   `uv tool install pylatexenc`. The config adds `~/.local/bin` and Mason's
   `bin/` directory to PATH using the platform's correct path separator. For
   the stacked fractions and roots shown in the examples, install the optional
   `utftex` executable from [libtexprintf](https://github.com/bartp5/libtexprintf)
   and place it in `~/.local/bin` (or another directory on PATH); its binaries
   must match the machine's OS and CPU architecture. On Windows the config sets
   `PYTHONIOENCODING=utf-8` for `latex2text` so Unicode math symbols work in
   the console. Check converter detection with `:checkhealth render-markdown`.
4. `asm-lsp` is not installed by Mason. On Windows and Linux, install it with
   `cargo install asm-lsp`, or download a release binary matching the machine's
   OS and CPU architecture. `~/.cargo/bin`, `~/.local/bin`, and Mason's `bin/`
   are added to PATH in `init.lua` on each OS.
5. `asm-lsp` only publishes diagnostics on save. Live insert-mode assembly
   errors are produced by `lua/util/asm.lua` (GAS via `gcc`, NASM via `nasm`).
   For NASM projects, add a `.asm-lsp.toml` with `[opts] compiler = "nasm"` so
   `asm-lsp` does not apply its default GCC/GAS diagnostics to NASM syntax.
6. Run `:checkhealth` and `:Lazy health` to verify the installation.

## Markdown preview

`render-markdown.nvim` loads automatically for Markdown files and renders the
whole buffer, including long tables. The configuration enables the visual
components shown in the upstream examples: colored headings, code blocks,
bullets, checkboxes, quotes and callouts, links, tables, and LaTeX formulas.
Image links receive an icon; the plugin does not display the image itself.
Icons look best with a Nerd Font configured in the terminal.

| Command / key | Action |
| --- | --- |
| `<leader>mr` or `:RenderMarkdown buf_toggle` | Toggle rendering for the current buffer |
| `:RenderMarkdown toggle` | Toggle rendering globally |
| `:RenderMarkdown preview` | Open a rendered preview window |
| `:RenderMarkdownFull` | Force a full-buffer render (useful after an update) |

### Updating

The plugin is **pinned** to commit `a67f826164c38c836fc6060f32b275c4c43317a7`
in `lua/plugins/render-markdown.lua`. This is deliberate: full-buffer rendering
overrides `render-markdown.lib.env.range`, an internal module. A normal
`:Lazy update` will leave this plugin at the tested commit, so updating other
plugins cannot break it.

To upgrade the renderer intentionally:

1. Remove the `commit = ...` line in `lua/plugins/render-markdown.lua`.
2. Run `:Lazy update render-markdown.nvim`.
3. Run `:checkhealth render-markdown` and `:RenderMarkdownFull` on a large
   `.md` file; confirm tables render from top to bottom.
4. Put the tested commit back (or update it to the newly verified commit).

`:Lazy reload render-markdown.nvim` was verified to reapply the full-buffer
render without stale-context errors (the FileType render is synchronous).

If a future release changes that internal module, the override is guarded with
`pcall` and the config warns instead of erroring, falling back to upstream's
visible-window rendering. After any update, run `:checkhealth render-markdown`.

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
| `<leader>mr` | Toggle Markdown rendering for the current buffer |

Debug configurations are chosen with `<leader>dc` when more than one is
available (for example *Build & Debug current file (gdb)* vs *Launch binary
(CodeLLDB)*).
