--- Small helpers for building / running the current file without leaving Neovim.
--- Used by the keymaps in `config/keymaps.lua`.
local M = {}

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "Build & Run" })
end

local function output_dir()
  local dir = vim.fn.stdpath("cache") .. "/ide-build"
  vim.fn.mkdir(dir, "p")
  return dir
end

local function current_file()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" or vim.bo.buftype ~= "" then
    notify("Open a saved source file first", vim.log.levels.WARN)
    return
  end
  return file
end

local function cargo_root(file)
  if not file then
    return
  end
  local cargo = vim.fs.find("Cargo.toml", { upward = true, path = vim.fn.fnamemodify(file, ":h") })[1]
  return cargo and vim.fn.fnamemodify(cargo, ":h")
end

---@return string? path to the produced executable (nil for project builds)
function M.build()
  local file = current_file()
  if not file then
    return
  end

  local ft = vim.bo.filetype
  local name = vim.fn.fnamemodify(file, ":t:r")
  local exe = output_dir() .. "/" .. name
  local cargo = cargo_root(file)
  local cmd

  if ft == "c" then
    cmd = { "gcc", "-g", "-O0", "-Wall", "-Wextra", file, "-o", exe, "-lm" }
  elseif ft == "cpp" then
    cmd = { "g++", "-g", "-O0", "-Wall", "-Wextra", file, "-o", exe }
  elseif ft == "asm" then
    -- GAS sources are assembled and linked with gcc so libc is available.
    cmd = { "gcc", "-g", file, "-o", exe }
  elseif ft == "rust" then
    cmd = cargo and { "cargo", "build" } or { "rustc", "-g", file, "-o", exe }
  elseif ft == "python" then
    cmd = { vim.g.python3_host_prog or "python3", "-m", "py_compile", file }
  else
    notify("No build command configured for filetype: " .. ft, vim.log.levels.WARN)
    return
  end

  local out = vim.fn.system(cmd)
  if vim.v.shell_error ~= 0 then
    notify("Build failed:\n" .. out, vim.log.levels.ERROR)
    return
  end

  notify("Build OK: " .. (cmd[1] == "cargo" and "cargo build" or exe))
  if ft == "c" or ft == "cpp" or ft == "asm" or (ft == "rust" and not cargo) then
    return exe
  end
end

--- Run the current file in a terminal (builds C/C++/assembly first).
function M.run()
  local file = current_file()
  if not file then
    return
  end

  local ft = vim.bo.filetype
  local cargo = cargo_root(file)
  local cmd

  if ft == "python" then
    cmd = (vim.g.python3_host_prog or "python3") .. " " .. vim.fn.shellescape(file)
  elseif ft == "rust" and cargo then
    cmd = "cargo run"
  end

  if not cmd then
    local exe = M.build()
    if not exe then
      return
    end
    cmd = vim.fn.shellescape(exe)
  end

  local cwd = cargo or vim.fn.getcwd()
  if LazyVim.has("snacks.nvim") then
    Snacks.terminal(cmd, { cwd = cwd })
  else
    vim.cmd("split | terminal cd " .. vim.fn.shellescape(cwd) .. " && " .. cmd)
  end
end

return M
