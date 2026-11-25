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
        -- Extra parser used by render-markdown.nvim for LaTeX blocks
        -- (markdown, markdown_inline, html and yaml come from LazyVim).
        "latex",
      })
    end,
  },
}
