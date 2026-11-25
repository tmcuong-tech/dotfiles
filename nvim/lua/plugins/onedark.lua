-- One Dark from joshdick/onedark.vim.
return {
  {
    "joshdick/onedark.vim",
    priority = 1000,
    lazy = false,
    init = function()
      -- Set options before the colorscheme is loaded, as required upstream.
      vim.g.onedark_hide_endofbuffer = 1
      vim.g.onedark_termcolors = 256
      vim.g.onedark_terminal_italics = 0
      vim.opt.termguicolors = true

      -- Preserve One Dark's foreground colors while making editor surfaces transparent.
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "onedark",
        callback = function()
          for _, group in ipairs({
            "Normal",
            "NormalNC",
            "NormalFloat",
            "FloatBorder",
            "SignColumn",
            "EndOfBuffer",
            "LineNr",
            "CursorLineNr",
          }) do
            local highlight = vim.api.nvim_get_hl(0, { name = group, link = false })
            highlight.bg = "NONE"
            vim.api.nvim_set_hl(0, group, highlight)
          end
        end,
      })
    end,
  },
}
