-- Pretty inline diagnostics that stay visible while typing in insert mode.
-- Neovim's built-in virtual text is disabled in lsp.lua to avoid duplicates.
return {
  {
    "rachartier/tiny-inline-diagnostic.nvim",
    -- Load at startup: the plugin attaches buffers on `LspAttach`. If it only
    -- loaded on VeryLazy, buffers whose LSP attached earlier never got inline
    -- diagnostics.
    lazy = false,
    priority = 1000,
    keys = {
      {
        "<leader>uI",
        function()
          vim.cmd("TinyInlineDiag toggle")
        end,
        desc = "Toggle Inline Diagnostics",
      },
    },
    opts = {
      preset = "modern",
      options = {
        enable_on_insert = true,
        enable_on_select = true, -- keep messages while a completion menu is open
        throttle = 0, -- recommended by the plugin when enabled in insert mode
        multilines = { enabled = true },
        show_source = { enabled = true, if_many = true },
        use_icons_from_diagnostic = true,
        overflow = { mode = "wrap" },
      },
    },
  },
}
