-- LazyVim's Rust extra selects liblldb with `io.popen("uname")`, which
-- assumes a Unix shell and chooses the wrong library path on Windows.
-- Keep its server options, but select the CodeLLDB library by OS here.
return {
  {
    "mrcjkb/rustaceanvim",
    config = function(_, opts)
      if LazyVim.has("mason.nvim") then
        local platform = require("util.platform")
        local codelldb = vim.fn.exepath("codelldb")

        if codelldb ~= "" then
          local lib_ext = platform.is_windows and ".dll" or (platform.is_linux and ".so" or ".dylib")
          local lib_dir = platform.is_windows and "bin" or "lib"
          local mason = vim.env.MASON or vim.fs.joinpath(vim.fn.stdpath("data"), "mason")
          local library = vim.fs.joinpath(mason, "opt", "lldb", lib_dir, "liblldb" .. lib_ext)

          if vim.fn.filereadable(library) == 1 then
            opts.dap = {
              adapter = require("rustaceanvim.config").get_codelldb_adapter(codelldb, library),
            }
          end
        end
      end

      vim.g.rustaceanvim = vim.tbl_deep_extend("keep", vim.g.rustaceanvim or {}, opts or {})

      if vim.fn.executable("rust-analyzer") == 0 then
        LazyVim.error("**rust-analyzer** not found in PATH, please install it.", { title = "rustaceanvim" })
      end
    end,
  },
}
