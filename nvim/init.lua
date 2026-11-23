-- Make tool binaries visible to Neovim/:checkhealth even when the shell PATH
-- does not include them: Mason tools plus manually installed helpers.
for _, bin in ipairs({ vim.fn.stdpath("data") .. "/mason/bin", vim.fn.expand("~/.local/bin") }) do
  if vim.fn.isdirectory(bin) == 1 and not vim.env.PATH:find(bin, 1, true) then
    vim.env.PATH = bin .. ":" .. vim.env.PATH
  end
end

-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
