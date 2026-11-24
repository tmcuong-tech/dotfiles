--- Debug adapter configurations shared by C/C++, Python, Rust and assembly.
--- Loaded once, right after nvim-dap itself (and the extras) are initialized.
local M = {}

local platform = require("util.platform")

---@param list table[]?
---@param config table
local function add(list, config)
  local names = vim.tbl_map(function(c)
    return c.name
  end, list or {})
  if not vim.list_contains(names, config.name) then
    table.insert(list, config)
  end
end

--- GDB only speaks DAP from version 14 onwards (`gdb -i dap`).
---@return boolean
function M.gdb_supports_dap()
  if vim.fn.executable("gdb") ~= 1 then
    return false
  end
  local out = vim.fn.system({ "gdb", "--version" })
  local major = tonumber(out:match("GDB%)%s*(%d+)%."))
  return major ~= nil and major >= 14
end

--- Python interpreter used to run the debuggee. Prefer nvim-dap-python's
--- resolver so the active virtualenv (venv-selector) is honored.
---@return string
local function python()
  local ok, dap_python = pcall(require, "dap-python")
  if ok then
    local pok, resolved = pcall(dap_python.resolve_python)
    if pok and type(resolved) == "string" and resolved ~= "" then
      return resolved
    end
  end
  return platform.python()
end

--- Default `target/debug/<crate>` path for Rust projects, used as the input
--- suggestion for the stand-alone CodeLLDB configuration.
---@return string
local function rust_binary_default()
  local root = require("util.build").cargo_root(vim.api.nvim_buf_get_name(0)) or vim.fn.getcwd()
  local crate
  local cargo_toml = vim.fs.joinpath(root, "Cargo.toml")
  if vim.fn.filereadable(cargo_toml) == 1 then
    local lines = vim.fn.readfile(cargo_toml)
    for _, line in ipairs(lines) do
      crate = crate or line:match("^%s*name%s*=%s*[\"']([^\"']+)[\"']")
    end
  end
  crate = crate or vim.fn.fnamemodify(root, ":t")
  return platform.exe(vim.fs.joinpath(root, "target", "debug", crate))
end

function M.setup()
  local ok, dap = pcall(require, "dap")
  if not ok then
    return
  end

  local build = function()
    return require("util.build").build()
  end

  local has_gdb = M.gdb_supports_dap()

  if has_gdb and not dap.adapters.gdb then
    dap.adapters.gdb = {
      type = "executable",
      command = "gdb",
      args = { "-i", "dap" },
    }
  end

  -- Python: the Python extra installs nvim-dap-python, which registers a
  -- function adapter that understands virtualenvs and attaches. Only provide
  -- a fallback when that plugin is somehow missing.
  if not dap.adapters.python then
    dap.adapters.python = {
      type = "executable",
      command = platform.python(),
      args = { "-m", "debugpy.adapter" },
    }
  end

  -- Native binaries: C, C++ and assembly (GAS/NASM).
  for _, ft in ipairs({ "c", "cpp", "asm" }) do
    dap.configurations[ft] = dap.configurations[ft] or {}

    if has_gdb then
      add(dap.configurations[ft], {
        type = "gdb",
        request = "launch",
        name = "Build & Debug current file (gdb)",
        program = build,
        cwd = "${workspaceFolder}",
      })
      add(dap.configurations[ft], {
        type = "gdb",
        request = "attach",
        name = "Attach to process (gdb)",
        pid = require("dap.utils").pick_process,
      })
    end

    if dap.adapters.codelldb then
      add(dap.configurations[ft], {
        type = "codelldb",
        request = "launch",
        name = "Build & Debug current file (CodeLLDB)",
        program = build,
        cwd = "${workspaceFolder}",
      })
      add(dap.configurations[ft], {
        type = "codelldb",
        request = "launch",
        name = "Launch binary (CodeLLDB)",
        program = function()
          return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. platform.exe_suffix, "file")
        end,
        cwd = "${workspaceFolder}",
      })
      add(dap.configurations[ft], {
        type = "codelldb",
        request = "attach",
        name = "Attach to process (CodeLLDB)",
        pid = require("dap.utils").pick_process,
        cwd = "${workspaceFolder}",
      })
    end
  end

  -- Python configurations. `console = "integratedTerminal"` is a VSCode
  -- concept and makes debugpy wait for a terminal that nvim-dap never opens;
  -- leave it unset so output goes through nvim-dap(-ui).
  dap.configurations.python = dap.configurations.python or {}
  add(dap.configurations.python, {
    type = "python",
    request = "launch",
    name = "Build & Debug current file (debugpy)",
    program = "${file}",
    python = python,
    cwd = "${workspaceFolder}",
    justMyCode = false,
  })
  add(dap.configurations.python, {
    type = "python",
    request = "launch",
    name = "Debug pytest",
    module = "pytest",
    args = { "-q" },
    python = python,
    cwd = "${workspaceFolder}",
    justMyCode = false,
  })

  -- Rust is primarily handled by rustaceanvim (<leader>dr -> RustLsp
  -- debuggables), but a plain CodeLLDB configuration is useful for
  -- stand-alone binaries.
  if dap.adapters.codelldb then
    dap.configurations.rust = dap.configurations.rust or {}
    add(dap.configurations.rust, {
      type = "codelldb",
      request = "launch",
      name = "Launch Rust binary (CodeLLDB)",
      program = function()
        return vim.fn.input("Path to executable: ", rust_binary_default(), "file")
      end,
      cwd = "${workspaceFolder}",
    })
  end
end

return M
