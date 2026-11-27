-- Completion is handled by blink.cmp (a LazyVim default extra in this version).
-- This file only turns on the IDE extras: automatic signature help and a
-- manual trigger for the completion menu.
return {
  {
    "saghen/blink.cmp",
    opts = {
      completion = {
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        ghost_text = { enabled = true },
      },
      signature = { enabled = true },
      sources = {
        default = { "lazydev", "lsp", "path", "snippets", "buffer" },
        providers = {
          lazydev = {
            name = "LazyDev",
            module = "lazydev.integrations.blink",
            score_offset = 100,
          },
        },
      },
      keymap = {
        preset = "enter",
        ["<C-Space>"] = { "show", "fallback" },
        ["<C-y>"] = { "select_and_accept" },
      },
    },
  },
}
