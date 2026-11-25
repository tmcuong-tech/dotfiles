--- Small helpers for building / running the current file without leaving Neovim.
--- Used by the keymaps in `config/keymaps.lua`.
---
--- The commands are generated per platform:
---   * Windows: MinGW gcc/g++, `.exe` output, statically linked C++ runtime so
---     DLLs from other programs on PATH (e.g. neovim-qt) cannot shadow it.
---   * Linux/macOS: the plain toolchain, no `.exe` suffix.
local M = {}

local platform = require("util.platform")

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "Build & Run" })
end

local function output_dir()
  local dir = vim.fs.joinpath(vim.fn.stdpath("cache"), "ide-build")
  vim.fn.mkdir(dir, "p")
  return dir
end

local function current_file()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" or vim.bo.buftype ~= "" then
    notify("Open a saved source file first", vim.log.levels.WARN)
    return nil
  end
  return file
end

--- Find the root of the Cargo project that contains `file`.
---@param file string?
---@return string?
function M.cargo_root(file)
  if not file then
    return nil
  end
  local cargo = vim.fs.find("Cargo.toml", { upward = true, path = vim.fn.fnamemodify(file, ":h") })[1]
  return cargo and vim.fn.fnamemodify(cargo, ":h") or nil
end

--- Run a command synchronously and return `ok, output`.
---@param cmd string[]
---@param cwd string?
---@return boolean ok, string output
local function system(cmd, cwd)
  local ok, obj = pcall(vim.system, cmd, { cwd = cwd, text = true })
  if not ok then
    return false, tostring(obj)
  end
  local res = obj:wait()
  local out = table.concat({ res.stdout or "", res.stderr or "" }, "\n"):gsub("^%s+", ""):gsub("%s+$", "")
  return res.code == 0, out
end

---@param steps { cmd: string[], cwd?: string }[]
---@return boolean
local function run_steps(steps)
  for _, step in ipairs(steps) do
    local ok, out = system(step.cmd, step.cwd)
    if not ok then
      notify(("Build failed:\n$ %s\n%s"):format(table.concat(step.cmd, " "), out), vim.log.levels.ERROR)
      return false
    end
  end
  return true
end

--- Build steps for a given filetype. Returns nil + reason when unsupported.
---@param file string
---@param ft string
---@param name string
---@param exe string
---@return { cmd: string[], cwd?: string }[]? steps, string? err
local function build_steps(file, ft, name, exe)
  if ft == "c" then
    local cmd = { "gcc", "-g", "-O0", "-Wall", "-Wextra", file, "-o", exe, "-lm" }
    if platform.is_windows then
      -- Avoid picking up libgcc_s_seh-1.dll from unrelated apps on PATH.
      table.insert(cmd, 2, "-static-libgcc")
    end
    return { { cmd = cmd } }
  elseif ft == "cpp" then
    local cmd = { "g++", "-g", "-O0", "-Wall", "-Wextra", file, "-o", exe }
    if platform.is_windows then
      -- MinGW programs crash when another libstdc++-6.dll is found first on
      -- PATH (common with neovim-qt, Perl, ...). Static linking keeps the
      -- produced binary self-contained and debuggable.
      table.insert(cmd, 2, "-static-libgcc")
      table.insert(cmd, 3, "-static-libstdc++")
    end
    return { { cmd = cmd } }
  elseif ft == "asm" then
    local syntax = platform.asm_syntax(file)
    if syntax == "nasm" then
      if vim.fn.executable("nasm") ~= 1 then
        return nil, "nasm is not installed (required for NASM syntax; install it with Mason or your package manager)"
      end
      local obj = vim.fs.joinpath(output_dir(), name .. ".o")
      local format = platform.is_windows and "win64" or (platform.is_macos and "macho64" or "elf64")
      local assemble = { "nasm", "-g", "-f", format, file, "-o", obj }
      local link = { "gcc", "-g", obj, "-o", exe }
      if not platform.is_windows then
        -- NASM objects are not position independent.
        table.insert(link, 2, "-no-pie")
      end
      return { { cmd = assemble }, { cmd = link } }
    end
    -- GAS (`.s`/`.S` and GAS-syntax `.asm`): let gcc drive assembler + linker.
    return { { cmd = { "gcc", "-g", file, "-o", exe } } }
  elseif ft == "python" then
    return { { cmd = { platform.python(), "-m", "py_compile", file } } }
  elseif ft == "rust" then
    local root = M.cargo_root(file)
    if root then
      return { { cmd = { "cargo", "build" }, cwd = root } }
    end
    return { { cmd = { "rustc", "-g", file, "-o", exe } } }
  end

  return nil, "No build command configured for filetype: " .. ft
end

---@return string? path to the produced executable (nil for project builds)
function M.build()
  local file = current_file()
  if not file then
    return nil
  end

  local ft = vim.bo.filetype
  local name = vim.fn.fnamemodify(file, ":t:r")
  local exe = platform.exe(vim.fs.joinpath(output_dir(), name))
  local is_cargo = ft == "rust" and M.cargo_root(file) ~= nil

  local steps, err = build_steps(file, ft, name, exe)
  if not steps then
    notify(err or "No build command configured", vim.log.levels.WARN)
    return nil
  end
  if not run_steps(steps) then
    return nil
  end

  if ft == "python" then
    notify("Syntax OK: " .. vim.fn.fnamemodify(file, ":t"))
    return nil
  end
  if is_cargo then
    notify("Build OK: cargo build")
    return nil
  end
  if vim.fn.filereadable(exe) == 0 then
    notify("Build finished but executable was not created: " .. exe, vim.log.levels.WARN)
    return nil
  end

  notify("Build OK: " .. exe)
  return exe
end

--- Run the current file in a terminal (builds C/C++/assembly first).
function M.run()
  local file = current_file()
  if not file then
    return
  end

  local ft = vim.bo.filetype
  local cargo = M.cargo_root(file)
  local cwd = cargo or vim.fn.getcwd()
  local cmd

  if ft == "python" then
    cmd = { platform.python(), file }
  elseif ft == "rust" and cargo then
    cmd = { "cargo", "run" }
  else
    local exe = M.build()
    if not exe then
      return
    end
    cmd = { exe }
  end

  if LazyVim.has("snacks.nvim") then
    Snacks.terminal(cmd, { cwd = cwd })
  else
    vim.cmd("split")
    vim.fn.termopen(cmd, { cwd = cwd })
    vim.cmd("startinsert")
  end
end

return M
