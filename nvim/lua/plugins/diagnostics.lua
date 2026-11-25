-- Show inline messages only when the cursor is directly on a diagnostic.
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
        "<leader>uX",
        function()
          vim.cmd("TinyInlineDiag toggle")
        end,
        desc = "Toggle Inline Diagnostics",
      },
    },
    opts = {
      preset = "modern",
      options = {
        enable_on_insert = false,
        enable_on_select = false,
        show_diags_only_under_cursor = true,
        throttle = 0, -- update immediately as the cursor moves
        multilines = { enabled = true },
        show_source = { enabled = true, if_many = true },
        use_icons_from_diagnostic = true,
        overflow = { mode = "wrap" },
      },
    },
  },
}
