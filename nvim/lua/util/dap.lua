--- Debug adapter configurations shared by C/C++, Python, Rust and assembly.
--- Loaded once, right after nvim-dap itself is initialized by the dap.core extra.
local M = {}

local function add(list, config)
  if not vim.list_contains(vim.tbl_map(function(c)
    return c.name
  end, list or {}), config.name) then
    table.insert(list, config)
  end
end

function M.setup()
  local ok, dap = pcall(require, "dap")
  if not ok then
    return
  end

  -- GDB 14+ ships a native DAP mode (`gdb -i dap`).
  if not dap.adapters.gdb and vim.fn.executable("gdb") == 1 then
    dap.adapters.gdb = {
      type = "executable",
      command = "gdb",
      args = { "-i", "dap" },
    }
  end

  -- Mason installs a `debugpy-adapter` shim for Python.
  -- dap-python normally sets this up, but the shim is the most reliable
  -- option when debugpy comes from Mason rather than the current venv.
  if vim.fn.exepath("debugpy-adapter") ~= "" then
    dap.adapters.python = {
      type = "executable",
      command = "debugpy-adapter",
      args = {},
    }
  end

  local build = function()
    return require("util.build").build()
  end

  -- Native binaries: C, C++ and assembly (GAS/NASM).
  for _, ft in ipairs({ "c", "cpp", "asm" }) do
    dap.configurations[ft] = dap.configurations[ft] or {}

    add(dap.configurations[ft], {
      type = "gdb",
      request = "launch",
      name = "Build & Debug current file (gdb)",
      program = build,
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
    })

    if dap.adapters.codelldb then
      add(dap.configurations[ft], {
        type = "codelldb",
        request = "launch",
        name = "Launch binary (CodeLLDB)",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
        end,
        cwd = "${workspaceFolder}",
        console = "integratedTerminal",
      })
      add(dap.configurations[ft], {
        type = "codelldb",
        request = "attach",
        name = "Attach to process (CodeLLDB)",
        pid = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
      })
    end

    add(dap.configurations[ft], {
      type = "gdb",
      request = "attach",
      name = "Attach to process (gdb)",
      pid = require("dap.utils").pick_process,
    })
  end

  -- Python. `python` is the adapter registered by nvim-dap-python /
  -- mason-nvim-dap (and normalized above for the Mason debugpy shim).
  dap.configurations.python = dap.configurations.python or {}
  add(dap.configurations.python, {
    type = "python",
    request = "launch",
    name = "Launch current file (debugpy)",
    program = "${file}",
    cwd = "${workspaceFolder}",
    console = "integratedTerminal",
    justMyCode = false,
  })
  add(dap.configurations.python, {
    type = "python",
    request = "launch",
    name = "Debug pytest",
    module = "pytest",
    args = { "-q" },
    cwd = "${workspaceFolder}",
    console = "integratedTerminal",
    justMyCode = false,
  })

  -- Rust is handled by rustaceanvim (<leader>dr -> RustLsp debuggables),
  -- but a plain codelldb configuration is useful for stand-alone binaries.
  if dap.adapters.codelldb then
    dap.configurations.rust = dap.configurations.rust or {}
    add(dap.configurations.rust, {
      type = "codelldb",
      request = "launch",
      name = "Launch Rust binary (CodeLLDB)",
      program = function()
        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/target/debug/", "file")
      end,
      cwd = "${workspaceFolder}",
      console = "integratedTerminal",
    })
  end
end

return M
