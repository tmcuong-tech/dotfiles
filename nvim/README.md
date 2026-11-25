# 💤 LazyVim + IDE setup

A starter template for [LazyVim](https://github.com/LazyVim/LazyVim).
Refer to the [documentation](https://lazyvim.github.io/installation) to get started.

## Minimum requirements

- **Neovim 0.12.0 or newer**, built with LuaJIT.
- **Git 2.19 or newer.**

These are the minimum versions for this configuration. See [First-time setup](#first-time-setup)
for language tools and other optional dependencies.

## IDE features

| Feature | Implementation | Config file |
| --- | --- | --- |
| Startup dashboard | Alpha (LazyVim `ui.alpha` extra) | `lazyvim.json`, `lua/plugins/alpha.lua` |
| LSP (C/C++, Python, Rust, Assembly) | `nvim-lspconfig` + LazyVim language extras | `lua/plugins/lsp.lua` |
| Diagnostics while typing (insert mode) | `update_in_insert = true` + `tiny-inline-diagnostic.nvim` | `lua/plugins/diagnostics.lua` |
| Completion / signatures / snippets | `blink.cmp` (LSP, paths, snippets, buffer; auto docs and ghost text) | `lua/plugins/completion.lua` |
| Debugging | `nvim-dap`, `nvim-dap-ui`, `gdb`, `codelldb`, `debugpy` | `lua/plugins/dap.lua`, `lua/util/dap.lua` |
| Formatting | `conform.nvim` (clang-format, ruff, rustfmt, stylua, shfmt, prettier) | `lua/plugins/formatting.lua` |
| Linting | clangd (clang-tidy), ruff LSP, rust-analyzer | `lua/plugins/linting.lua` |
| Parsers / filetypes | `nvim-treesitter` + assembly filetype detection | `lua/plugins/treesitter.lua`, `lua/config/options.lua` |
| Assembly live errors | `gcc` / `nasm` check on the unsaved buffer | `lua/util/asm.lua`, `lua/config/autocmds.lua` |
| Tool installation | Mason plus Cargo or a matching release binary for `asm-lsp` | `lua/plugins/mason.lua` |
| Markdown preview | `render-markdown.nvim` (full-buffer) | `lua/plugins/render-markdown.lua` |
| Git commands / UI | `vim-fugitive`, `lazygit.nvim` (plus LazyVim's Git UI) | `lua/plugins/fugitive.lua`, `lua/plugins/lazygit.lua` |
| Alternate debugger | Vimspector with CodeLLDB and debugpy | `lua/plugins/vimspector.lua` |

Each file under `lua/plugins/` returns lazy.nvim plugin specs. Add a file there
to extend the setup. Specs for the same plugin are merged; dependencies,
priorities, and load events determine when plugins load, not filenames.
LazyVim extras are recorded in `lazyvim.json` so LazyVim can load them in its
supported dependency order on every machine.

## First-time setup

### Prerequisites (Windows and Linux)

- Node.js is needed by Mason's `pyright` and `prettier` packages.
- `curl`, `tar`, a C compiler, and `tree-sitter` CLI 0.26.1 or newer. Install
  the CLI from the OS package manager (not npm); the locked Treesitter main
  branch uses it to install parsers.
- For the build/run mappings: GCC-compatible `gcc` and `g++`; for Rust:
  `rustc`, `cargo`, and the `rustfmt` component; for Python: `python` or
  `python3`. NASM is only needed for NASM-syntax files. On Windows, use MinGW
  GCC or another GCC toolchain that provides both `gcc` and `g++`.

1. Open Neovim and run `:Lazy sync` — installs plugins and the treesitter
   parsers listed in `lua/plugins/treesitter.lua`.
2. Run `:Mason`, then press `I` to install the tools listed in
   `lua/plugins/mason.lua` (`clangd`, `clang-format`, `pyright`, `ruff`,
   `rust-analyzer`, `debugpy`, `codelldb`, `stylua`, `prettier`, `shfmt`).
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
   OS and CPU architecture. The Cargo `bin/` directory (`$CARGO_HOME/bin` when
   set, otherwise `~/.cargo/bin`), `~/.local/bin`, and Mason's `bin/` are added
   to PATH in `init.lua` on each OS.
5. `asm-lsp` only publishes diagnostics on save. Live insert-mode assembly
   errors are produced by `lua/util/asm.lua` (GAS via `gcc`, NASM via `nasm`).
   For NASM projects, add a `.asm-lsp.toml` with `[opts] compiler = "nasm"` so
   `asm-lsp` does not apply its default GCC/GAS diagnostics to NASM syntax.
6. Run `:checkhealth` and `:Lazy health` to verify the installation.
7. Git integrations need `git` on PATH; the LazyGit UI also needs the `lazygit` executable. Install Vimspector's separate adapters with `:VimspectorInstall` (configured for `CodeLLDB` and `debugpy`).

## Colorschemes

Gruvbox is the startup theme. Tokyo Night is installed with transparent editor,
sidebar, and floating-window backgrounds. One Dark is installed from
[`joshdick/onedark.vim`](https://github.com/joshdick/onedark.vim) with transparent
editor, sidebar, and floating-window backgrounds, true color enabled,
end-of-buffer markers hidden, and terminal italics disabled. Switch
themes for the current session with `:colorscheme gruvbox`,
`:colorscheme tokyonight`, or `:colorscheme onedark`. To make another theme the
startup theme, change the `colorscheme` value in `lua/plugins/gruvbox.lua`.

## Markdown preview

`render-markdown.nvim` loads automatically for Markdown files and renders the
whole buffer, including long tables. The configuration enables the visual
components shown in the upstream examples: colored headings, code blocks,
bullets, checkboxes, quotes and callouts, links, tables, and LaTeX formulas.
Image links receive an icon; the plugin does not display the image itself.
Icons look best with a Nerd Font configured in the terminal.

| Command / key | Action |
| --- | --- |
| `:RenderMarkdown buf_toggle` | Toggle rendering for the current buffer |
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

## Keymap guide

`<leader>` is **Space**. The table includes mappings configured by this setup
and the debugger mappings provided by its enabled LazyVim extra. Unless noted,
use the mappings in Normal mode.

| Key | Mode | Action |
| --- | --- | --- |
| `<Tab>` / `<S-Tab>` | Normal | Go to the next / previous buffer |
| `<C-Space>` | Insert | Open the completion menu |
| `<C-y>` | Insert | Accept the selected completion |
| `<CR>` | Insert | Confirm a completion using Blink's `enter` preset |
| `<leader>rb` | Normal | Build or syntax-check the current file (C, C++, Assembly, Rust, Python) |
| `<leader>rr` | Normal | Run the current file in a terminal |
| `<leader>rd` | Normal | Start or continue debugging |
| `<leader>rn` | Normal | Step over in the debugger |
| `<leader>db` | Normal | Toggle breakpoint |
| `<leader>dB` | Normal | Set a conditional breakpoint |
| `<leader>dc` | Normal | Run or continue debugging; choose a configuration if prompted |
| `<leader>da` | Normal | Run or continue with arguments |
| `<leader>dC` | Normal | Run to cursor |
| `<leader>dg` | Normal | Move execution to a line without running it |
| `<leader>di` / `<leader>do` / `<leader>dO` | Normal | Step into / step out / step over |
| `<leader>dj` / `<leader>dk` | Normal | Move down / up the call stack |
| `<leader>dl` | Normal | Run the last debug configuration |
| `<leader>dP` | Normal | Pause debugging |
| `<leader>dr` | Normal | Toggle the DAP REPL; in Rust buffers, open Rust debuggables |
| `<leader>ds` | Normal | Show the debug session |
| `<leader>dt` | Normal | Terminate debugging |
| `<leader>dw` | Normal | Show debugger widgets |
| `<leader>du` | Normal | Toggle the DAP UI |
| `<leader>de` | Normal / Visual | Evaluate expression under cursor / selected text |
| `<leader>ch` | Normal | Switch between C/C++ source and header |
| `<leader>uX` | Normal | Toggle inline diagnostics |
| `<leader>mr` | Normal | Toggle Markdown rendering in the current buffer |
| `<leader>gg` / `<leader>gG` | Normal | Open LazyGit at the Git root / current directory |
| `<leader>lg` | Normal | Open LazyGit through `lazygit.nvim` |
| `<leader>Gs` / `<leader>Gc` / `<leader>Gp` / `<leader>Gu` | Normal | Fugitive status / commit / push / pull |
| `<leader>mt` | Normal | Toggle the merge-conflict tool |
| `<leader>vc` / `<leader>vs` / `<leader>vr` | Normal | Vimspector continue / stop / restart |
| `<leader>vb` / `<leader>vB` | Normal | Vimspector toggle / conditional breakpoint |
| `<leader>vn` / `<leader>vi` / `<leader>vo` | Normal | Vimspector step over / into / out |
| `<leader>ve` | Normal / Visual | Evaluate value under cursor / selected text in Vimspector |
| `<F5>` / `<F3>` / `<F4>` | Normal | Vimspector continue / stop / restart (`HUMAN` mappings) |

Completion suggestions include LSP results, paths, snippets, and words from the
current buffer. Documentation opens automatically, with ghost-text previews and
signature help enabled. Formatting runs on save for configured filetypes.

The standard LazyVim mappings are also available and can vary by filetype and
installed extra. Press `<leader>` and wait for the WhichKey menu to browse the
available actions; `:map` lists active mappings. The Markdown preview commands
`:RenderMarkdown toggle`, `:RenderMarkdown preview`, and `:RenderMarkdownFull`
are also available; `<leader>mr` toggles rendering for the current buffer.

When multiple debug configurations are available, `<leader>dc` prompts you to
choose one (for example, *Build & Debug current file (gdb)* or *Launch binary
(CodeLLDB)*).
