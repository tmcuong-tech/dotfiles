-- Make tool binaries visible to Neovim/:checkhealth even when the shell PATH
-- does not include them: Mason tools plus manually installed helpers.
--
-- NOTE: PATH is separated by ";" on Windows and ":" on Unix. The old version
-- of this file always used ":", which merged every entry after the first into
-- a single invalid path on Windows and made Mason-installed tools (stylua,
-- codelldb, asm-lsp, ...) undiscoverable.
local platform = require("util.platform")

for _, bin in ipairs({
  vim.fs.joinpath(vim.fn.stdpath("data"), "mason", "bin"),
  vim.fn.expand("~/.local/bin"),
}) do
  platform.add_to_path(bin)
end

-- Pick the installed GNU Rust toolchain when the default MSVC toolchain has no
-- linker (see util/platform.lua).
platform.setup_rust_toolchain()

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
