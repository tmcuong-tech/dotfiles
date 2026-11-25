-- Keep Vimspector's keymaps in their own <leader>v namespace so they do not
-- collide with LazyVim's nvim-dap <leader>d mappings.
return {
  {
    "puremourning/vimspector",
    init = function()
      vim.g.vimspector_enable_mappings = "HUMAN"
      vim.g.vimspector_install_gadgets = { "CodeLLDB", "debugpy" }
      local platform = require("util.platform")
      local output =
        vim.fs.joinpath(vim.fn.stdpath("cache"), "ide-build", "${fileBasenameNoExtension}" .. platform.exe_suffix)
      vim.g.vimspector_configurations = {
        ["Build output (CodeLLDB)"] = {
          adapter = "CodeLLDB",
          filetypes = { "c", "cpp", "asm" },
          configuration = {
            request = "launch",
            program = output,
            args = { "*${args}" },
            cwd = "${workspaceRoot}",
          },
        },
        ["Rust executable (CodeLLDB)"] = {
          adapter = "CodeLLDB",
          filetypes = { "rust" },
          configuration = {
            request = "launch",
            program = "${Executable}",
            cwd = "${workspaceRoot}",
            sourceLanguages = { "rust" },
          },
        },
        ["Python file (debugpy)"] = {
          adapter = "debugpy",
          filetypes = { "python" },
          configuration = {
            request = "launch",
            type = "python",
            program = "${file}",
            args = { "*${args}" },
            cwd = "${fileDirname}",
          },
        },
      }
    end,
    keys = {
      { "<leader>vc", "<Plug>VimspectorContinue", desc = "Vimspector: Continue / Start", remap = true },
      { "<leader>vs", "<Plug>VimspectorStop", desc = "Vimspector: Stop", remap = true },
      { "<leader>vr", "<Plug>VimspectorRestart", desc = "Vimspector: Restart", remap = true },
      { "<leader>vb", "<Plug>VimspectorToggleBreakpoint", desc = "Vimspector: Toggle Breakpoint", remap = true },
      {
        "<leader>vB",
        "<Plug>VimspectorToggleConditionalBreakpoint",
        desc = "Vimspector: Conditional Breakpoint",
        remap = true,
      },
      { "<leader>vn", "<Plug>VimspectorStepOver", desc = "Vimspector: Step Over", remap = true },
      { "<leader>vi", "<Plug>VimspectorStepInto", desc = "Vimspector: Step Into", remap = true },
      { "<leader>vo", "<Plug>VimspectorStepOut", desc = "Vimspector: Step Out", remap = true },
      { "<leader>ve", "<Plug>VimspectorBalloonEval", desc = "Vimspector: Evaluate", remap = true },
      {
        "<leader>ve",
        "<Plug>VimspectorBalloonEval",
        mode = "x",
        desc = "Vimspector: Evaluate Selection",
        remap = true,
      },
    },
  },
}
