-- Markdown preview/renderer.
-- Official lazy.nvim recipe: https://github.com/MeanderingProgrammer/render-markdown.nvim#lazy.nvim
--
-- This spec is PINNED to the commit below because it overrides the internal
-- `render-markdown.lib.env.range` to render the whole buffer. Upstream only
-- renders the visible window by design. Read "Updating" in README.md before
-- changing the commit.
local RM_COMMIT = "a67f826164c38c836fc6060f32b275c4c43317a7"
local FILETYPES = { "markdown", "norg", "rmd", "org", "codecompanion" }

return {
  {
    "MeanderingProgrammer/render-markdown.nvim",
    commit = RM_COMMIT,
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-mini/mini.icons",
    },
    -- Load automatically when opening a supported file, not only on keypress.
    ft = FILETYPES,
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {
      -- Official preset that follows LazyVim's markdown conventions.
      preset = "lazy",
    },
    config = function(_, opts)
      -- A custom config() replaces lazy.nvim's automatic setup call.
      require("render-markdown").setup(opts)

      -- render-markdown renders only the visible window by design. Expand its
      -- range to the whole buffer so opening a file previews all lines, not
      -- just the table currently on screen. Guarded so a future plugin change
      -- degrades to upstream behavior instead of throwing an error.
      local ok, env = pcall(require, "render-markdown.lib.env")
      local patched = ok and type(env.range) == "function"
      if patched then
        env.range = function(buf, _win, _offset)
          if not vim.api.nvim_buf_is_valid(buf) then
            return { 0, 0 }
          end
          return { 0, vim.api.nvim_buf_line_count(buf) }
        end
      end

      local function render_full(buf)
        if not patched or not vim.api.nvim_buf_is_valid(buf) then
          return false
        end
        local win = vim.fn.bufwinid(buf)
        if win == -1 then
          return false
        end
        return pcall(require("render-markdown").render, { buf = buf, win = win, force = true })
      end

      local warn_patch = function()
        vim.notify_once(
          "render-markdown: full-buffer patch unavailable; using upstream visible-window rendering. Run :checkhealth render-markdown.",
          vim.log.levels.WARN
        )
      end

      -- Render synchronously on FileType. Do not defer: a pending callback
      -- from an older module instance breaks on :Lazy reload / plugin update.
      local group = vim.api.nvim_create_augroup("RenderMarkdownFullBuffer", { clear = true })
      vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(args)
          if not vim.tbl_contains(FILETYPES, vim.bo[args.buf].filetype) then
            return
          end
          if not render_full(args.buf) then
            warn_patch()
          end
        end,
      })

      if vim.fn.exists(":RenderMarkdownFull") == 1 then
        vim.api.nvim_del_user_command("RenderMarkdownFull")
      end
      vim.api.nvim_create_user_command("RenderMarkdownFull", function()
        if render_full(vim.api.nvim_get_current_buf()) then
          vim.notify("render-markdown: full buffer rendered", vim.log.levels.INFO)
        else
          warn_patch()
        end
      end, { desc = "Force full-buffer Markdown render" })

      -- FileType already fired for the buffer that triggered lazy loading.
      if vim.tbl_contains(FILETYPES, vim.bo[vim.api.nvim_get_current_buf()].filetype) then
        if not render_full(vim.api.nvim_get_current_buf()) then
          warn_patch()
        end
      end
    end,
    keys = {
      { "<leader>mr", "<CMD>RenderMarkdown buf_toggle<CR>", desc = "Render Markdown: Toggle Buffer" },
    },
  },
}
