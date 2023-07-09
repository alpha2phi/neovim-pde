if not require("config").pde.flutter then
  return {}
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "dart" })
    end,
  },
  {
    "akinsho/flutter-tools.nvim",
    opts = function()
      return {
        debugger = {
          enabled = true,
          run_via_dap = false,
        },
        outline = { auto_open = false },
        decorations = {
          statusline = { device = true, app_version = true },
        },
        widget_guides = { enabled = true, debug = true },
        dev_log = { enabled = false, open_cmd = "tabedit" },
        lsp = {
          color = {
            enabled = true,
            background = true,
            virtual_text = false,
          },
          settings = {
            showTodos = true,
            renameFilesWithClasses = "prompt",
          },
          -- TODO:
          on_attach = require("config.lsp").on_attach,
          capabilities = require("config.lsp").capabilities,
        },
      }
    end,
    config = function(_, opts)
      require("flutter-tools").setup(opts)
    end,
  },
}
