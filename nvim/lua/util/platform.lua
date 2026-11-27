--- Cross-platform helpers.
---
--- Everything in this config that touches the OS (PATH, executables, temp
--- files, Rust toolchains) goes through this module so the same config works
--- on Linux, macOS and Windows without conditionals scattered everywhere.
local M = {}

local uv = vim.uv or vim.loop
local sysname = uv.os_uname().sysname

M.is_windows = sysname == "Windows_NT"
M.is_macos = sysname == "Darwin"
M.is_linux = sysname == "Linux"

--- PATH separator used by the OS (";" on Windows, ":" everywhere else).
M.path_sep = M.is_windows and ";" or ":"

--- Suffix for native executables (".exe" on Windows, "" elsewhere).
M.exe_suffix = M.is_windows and ".exe" or ""

---@param path string?
---@return string?
--- Ensure Windows executables end in `.exe`.
function M.exe(path)
  if not path or path == "" then
    return path
  end
  if M.is_windows and not path:lower():match("%.exe$") then
    return path .. ".exe"
  end
  return path
end

--- Path of the null device for tools that only need a discardable output.
---@return string
function M.devnull()
  return M.is_windows and "NUL" or "/dev/null"
end

--- Normalize a directory path for comparisons.
---@param path string
---@return string
local function normalize(path)
  path = vim.fn.fnamemodify(path, ":p"):gsub("[/\\]+$", "")
  if M.is_windows then
    path = path:gsub("/", "\\"):lower()
  end
  return path
end

--- Prepend a directory to PATH if it exists and is not already present.
---@param dir string
---@return boolean added
function M.add_to_path(dir)
  if type(dir) ~= "string" or dir == "" then
    return false
  end
  if vim.fn.isdirectory(dir) == 0 then
    return false
  end

  local wanted = normalize(dir)
  local current = vim.env.PATH or ""
  for entry in current:gmatch("[^" .. M.path_sep .. "]+") do
    if normalize(entry) == wanted then
      return false
    end
  end

  vim.env.PATH = vim.fn.fnamemodify(dir, ":p"):gsub("[/\\]+$", "") .. M.path_sep .. current
  return true
end

--- Return a usable Python 3 interpreter.
--- Windows installs usually expose `python`/`py`, while Unix uses `python3`.
---@return string
function M.python()
  local candidates = {}
  if type(vim.g.python3_host_prog) == "string" and vim.g.python3_host_prog ~= "" then
    table.insert(candidates, vim.g.python3_host_prog)
  end
  if M.is_windows then
    vim.list_extend(candidates, { "python", "python3", "py" })
  else
    vim.list_extend(candidates, { "python3", "python" })
  end
  for _, candidate in ipairs(candidates) do
    if vim.fn.executable(candidate) == 1 then
      return candidate
    end
  end
  return M.is_windows and "python" or "python3"
end

--- Guess whether an assembly buffer is NASM or GAS.
---
--- The file extension alone is not reliable: `.asm`/`.nasm` are *usually*
--- NASM, but people also write GAS syntax in `.asm` files (and the syntax
--- check must not use the wrong assembler). Look at the directives first and
--- only fall back to the extension when the buffer is ambiguous.
---@param path string
---@param lines string[]?
---@return "nasm"|"gas"
function M.asm_syntax(path, lines)
  path = path or ""
  lines = lines or (vim.fn.filereadable(path) == 1 and vim.fn.readfile(path) or {})

  local ext = (path:match("%.([%w]+)$") or ""):lower()
  local default_nasm = ext == "asm" or ext == "nasm"
  local gas, nasm = 0, 0
  local nasm_directives = {
    bits = true,
    default = true,
    extern = true,
    global = true,
    section = true,
  }

  for _, line in ipairs(lines) do
    -- Strip comments/most string noise before matching.
    local code = line:gsub("[;#].*$", "")
    if code:match("%%%%?[%a_][%w_]*") or code:match("%$[%w_%-]") then
      gas = gas + 1
    end
    if code:match("^%s*%.[%a_]") then
      gas = gas + 1
    end
    local directive = code:match("^%s*([%a_]+)")
    if (directive and nasm_directives[directive:lower()]) or code:match("^%s*%%[%a_]+") then
      nasm = nasm + 1
    end
  end

  if gas == nasm then
    return default_nasm and "nasm" or "gas"
  end
  return gas > nasm and "gas" or "nasm"
end

--- Does this process have a usable MSVC environment for Rust?
--- Visual Studio may be installed while Neovim was launched outside a
--- Developer shell; in that case the compiler/linker are not available.
---@return boolean
local function has_msvc_environment()
  return vim.fn.executable("cl.exe") == 1 and vim.fn.executable("link.exe") == 1
end

--- On Windows the default Rust toolchain is often `*-pc-windows-msvc`, but it
--- cannot link unless Neovim inherited a Developer-shell environment. If that
--- environment is absent, select an installed GNU toolchain instead.
---
--- Override with: `vim.g.ide_auto_rust_toolchain = false`
--- or by setting RUSTUP_TOOLCHAIN yourself.
function M.setup_rust_toolchain()
  if not M.is_windows or vim.g.ide_auto_rust_toolchain == false then
    return
  end
  if type(vim.env.RUSTUP_TOOLCHAIN) == "string" and vim.env.RUSTUP_TOOLCHAIN ~= "" then
    return
  end
  if vim.fn.executable("rustup") ~= 1 then
    return
  end

  local active = vim.fn.system({ "rustup", "show", "active-toolchain" })
  if active:find("windows%-gnu") then
    return
  end
  if has_msvc_environment() then
    return
  end

  local list = vim.fn.system({ "rustup", "toolchain", "list" })
  local gnu = list:match("([%w%.%-_]+%-pc%-windows%-gnu)")
  if gnu then
    vim.env.RUSTUP_TOOLCHAIN = gnu
    vim.g.ide_rust_toolchain = gnu
  end
end

return M
