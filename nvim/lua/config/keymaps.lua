-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

-- Build / run the current file (C, C++, assembly, Rust, Python).
vim.keymap.set("n", "<leader>rb", function()
  require("util.build").build()
end, { desc = "Build Current File" })

vim.keymap.set("n", "<leader>rr", function()
  require("util.build").run()
end, { desc = "Run Current File" })

-- Quick access to the most common debug actions (the full <leader>d* set
-- comes from the dap.core extra).
vim.keymap.set("n", "<leader>rd", function()
  require("dap").continue()
end, { desc = "Debug: Continue / Start" })

vim.keymap.set("n", "<leader>rn", function()
  require("dap").step_over()
end, { desc = "Debug: Step Over" })
