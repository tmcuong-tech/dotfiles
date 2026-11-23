--- Live assembly diagnostics.
---
--- `asm-lsp` only publishes diagnostics on `textDocument/didSave`, so errors do
--- not appear while typing. This module runs the assembler against the current
--- (unsaved) buffer contents in insert mode and publishes the result as normal
--- Neovim diagnostics, which tiny-inline-diagnostic then renders inline.
local M = {}

local ns = vim.api.nvim_create_namespace("asm-live")
local timer = vim.uv.new_timer()
local patterns = { "*.s", "*.S", "*.asm", "*.nasm" }

local function parse(output)
  local diags = {}
  for line in output:gmatch("[^\r\n]+") do
    local lnum, col, severity, message = line:match("(%d+):(%d+):%s*(%a+):%s*(.+)")
    if not lnum then
      lnum, severity, message = line:match("(%d+):%s*(%a+):%s*(.+)")
      col = 1
    end
    severity = severity and severity:lower() or ""
    if lnum and (severity == "error" or severity == "warning") then
      table.insert(diags, {
        lnum = tonumber(lnum) - 1,
        col = math.max(0, (tonumber(col) or 1) - 1),
        severity = severity == "error" and vim.diagnostic.severity.ERROR
          or vim.diagnostic.severity.WARN,
        message = message,
        source = "assembler",
      })
    end
  end
  return diags
end

local function check(bufnr)
  if not vim.api.nvim_buf_is_valid(bufnr) or vim.bo[bufnr].filetype ~= "asm" then
    return
  end

  local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  local file = vim.api.nvim_buf_get_name(bufnr)
  local ext = file:match("%.(%w+)$")
  local is_nasm = ext == "asm" or ext == "nasm"
  local output

  if is_nasm then
    if vim.fn.executable("nasm") ~= 1 then
      return
    end
    local tmp = vim.fn.tempname() .. ".asm"
    vim.fn.writefile(lines, tmp)
    output = vim.fn.system({ "nasm", "-f", "elf64", "-o", "/dev/null", tmp })
    vim.fn.delete(tmp)
  else
    if vim.fn.executable("gcc") ~= 1 then
      return
    end
    output = vim.fn.system({ "gcc", "-x", "assembler", "-fsyntax-only", "-" }, table.concat(lines, "\n") .. "\n")
  end

  vim.diagnostic.set(ns, bufnr, parse(output))
end

local function schedule(bufnr)
  timer:stop()
  timer:start(180, 0, vim.schedule_wrap(function()
    check(bufnr)
  end))
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
end

return M
