-- Parsers for every language supported by this IDE setup.
return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts.ensure_installed = opts.ensure_installed or {}
      vim.list_extend(opts.ensure_installed, {
        "c",
        "cpp",
        "python",
        "rust",
        "asm",
        "query", -- useful when editing treesitter queries / highlights
        "bash",
        "javascript",
        "json",
        "lua",
        "regex",
        "tsx",
        "typescript",
        "vim",
        -- Parsers used by render-markdown.nvim.
        "markdown",
        "markdown_inline",
        "html",
        "css",
        "yaml",
        "latex",
      })

      local seen = {}
      opts.ensure_installed = vim.tbl_filter(function(parser)
        if seen[parser] then
          return false
        end
        seen[parser] = true
        return true
      end, opts.ensure_installed)
    end,
  },
}
