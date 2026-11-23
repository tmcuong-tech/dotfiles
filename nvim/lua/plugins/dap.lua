-- Debugging setup. The dap.core extra provides nvim-dap, nvim-dap-ui and the
-- standard <leader>d* keymaps; this file adds the language adapters/configs
-- from `util/dap.lua` as soon as nvim-dap is loaded.
return {
  {
    "mfussenegger/nvim-dap",
    optional = true,
    init = function()
      LazyVim.on_load("nvim-dap", function()
        require("util.dap").setup()
      end)
    end,
  },
}
