return {
  -- Git commands and diffs (:Git, :G, :Gdiffsplit, etc.).
  {
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gdiffsplit" },
    -- Keep direct Fugitive commands under a separate capital-G group. LazyVim
    -- already uses several <leader>g* maps for Git status, history, and stash.
    keys = {
      { "<leader>Gs", "<cmd>Git<cr>", desc = "Fugitive: Status" },
      { "<leader>Gc", "<cmd>Git commit<cr>", desc = "Fugitive: Commit" },
      { "<leader>Gp", "<cmd>Git push<cr>", desc = "Fugitive: Push" },
      { "<leader>Gu", "<cmd>Git pull<cr>", desc = "Fugitive: Pull" },
    },
  },

  -- Resolve conflict markers with the preferred local revision and mr layout.
  {
    "samoshkin/vim-mergetool",
    init = function()
      vim.g.mergetool_layout = "mr"
      vim.g.mergetool_prefer_revision = "local"
    end,
    keys = {
      {
        "<leader>mt",
        "<Plug>(MergetoolToggle)",
        desc = "Toggle Mergetool",
        remap = true,
      },
    },
  },

  -- LazyVim already uses gitsigns.nvim; customize its signs instead of
  -- enabling vim-gitgutter alongside it.
  {
    "lewis6991/gitsigns.nvim",
    opts = function(_, opts)
      local signs = {
        add = { text = "✚" },
        change = { text = "✹" },
        delete = { text = "✖" },
      }
      opts.signs = vim.tbl_deep_extend("force", opts.signs or {}, signs)
      opts.signs_staged = vim.tbl_deep_extend("force", opts.signs_staged or {}, signs)

      -- Gitsigns previews are floating windows by default. Keep the standard
      -- minimal floating preview configuration explicitly enabled.
      opts.preview_config = vim.tbl_deep_extend("force", opts.preview_config or {}, {
        style = "minimal",
        relative = "cursor",
        row = 0,
        col = 1,
      })
    end,
  },
}
