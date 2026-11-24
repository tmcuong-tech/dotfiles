--- Live assembly diagnostics.
---
--- `asm-lsp` only publishes diagnostics on `textDocument/didSave`, so errors do
--- not appear while typing. This module runs the assembler against the current
--- (unsaved) buffer contents in insert mode and publishes the result as normal
--- Neovim diagnostics, which tiny-inline-diagnostic then renders inline.
local M = {}

local platform = require("util.platform")

local ns = vim.api.nvim_create_namespace("asm-live")
local timer = (vim.uv or vim.loop).new_timer()
local patterns = { "*.s", "*.S", "*.asm", "*.nasm" }

--- Parse GNU as / NASM output into Neovim diagnostics.
--- Handles both `file:line:col: Error: msg` and `file:line: error: msg`.
---@param output string
---@return vim.Diagnostic[]
local function parse(output)
  local diags = {}
  for line in output:gmatch("[^\r\n]+") do
    -- Paths on Windows contain a drive letter (`C:\...`), so anchor the match
    -- on the last `:<number>:` pair rather than the first colon in the line.
    local lnum, col, severity, message = line:match("(%d+):(%d+):%s*(%a+):%s*(.+)")
    if not lnum then
      lnum, severity, message = line:match("(%d+):%s*(%a+):%s*(.+)")
      col = 1
    end
    severity = severity and severity:lower() or ""
    if lnum and (severity == "error" or severity == "warning") then
      table.insert(diags, {
        lnum = math.max(0, tonumber(lnum) - 1),
        col = math.max(0, (tonumber(col) or 1) - 1),
        severity = severity == "error" and vim.diagnostic.severity.ERROR or vim.diagnostic.severity.WARN,
        message = message,
        source = "assembler",
      })
    end
  end
  return diags
end

--- Check a buffer's (possibly unsaved) contents and publish diagnostics.
---@param bufnr integer
---@return vim.Diagnostic[] diags
function M.check_buffer(bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= "asm" then
    return {}
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local file = vim.api.nvim_buf_get_name(bufnr)
  local syntax = platform.asm_syntax(file, lines)
  local output

  -- Assemblers need a real file on disk: `nasm -o NUL` is Windows-only and
  -- `/dev/null` does not exist there, so use a temp file in every case.
  local tmp = vim.fn.tempname() .. (syntax == "nasm" and ".asm" or ".s")
  vim.fn.writefile(lines, tmp)

  if syntax == "nasm" then
    if vim.fn.executable("nasm") ~= 1 then
      vim.fn.delete(tmp)
      return {}
    end
    local format = platform.is_windows and "win64" or "elf64"
    output = vim.fn.system({ "nasm", "-f", format, "-o", platform.devnull(), tmp })
  else
    if vim.fn.executable("gcc") ~= 1 then
      vim.fn.delete(tmp)
      return {}
    end
    output = vim.fn.system({ "gcc", "-x", "assembler", "-fsyntax-only", tmp })
  end
  vim.fn.delete(tmp)

  local diags = parse(output)
  vim.diagnostic.set(ns, bufnr, diags)
  return diags
end

local function schedule(bufnr)
  timer:stop()
  timer:start(
    180,
    0,
    vim.schedule_wrap(function()
      M.check_buffer(bufnr)
    end)
  )
end

function M.setup()
  local group = vim.api.nvim_create_augroup("asm-live-diagnostics", { clear = true })

  vim.api.nvim_create_autocmd({ "InsertEnter", "TextChangedI" }, {
    group = group,
    pattern = patterns,
    callback = function(event)
      schedule(event.buf)
    end,
    desc = "Check assembly syntax while typing",
  })

  -- Once saved, let asm-lsp own the diagnostics shown in normal mode.
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = patterns,
    callback = function(event)
      vim.diagnostic.set(ns, event.buf, {})
    end,
  })

  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    pattern = patterns,
    callback = function(event)
      timer:stop()
      if vim.api.nvim_buf_is_valid(event.buf) then
        vim.diagnostic.set(ns, event.buf, {})
      end
    end,
  })

  vim.api.nvim_create_autocmd("VimLeavePre", {
    group = group,
    callback = function()
      timer:stop()
      if not timer:is_closing() then
        timer:close()
      end
    end,
  })
end

return M
