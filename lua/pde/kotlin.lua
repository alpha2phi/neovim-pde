if not require("config").pde.kotlin then
  return {}
end

local function get_debug_adapter()
  local mason_registry = require "mason-registry"
  local debug_adapter = mason_registry.get_package "kotlin-debug-adapter"
  return debug_adapter:get_install_path() .. "/adapter/bin/kotlin-debug-adapter"
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "kotlin" })
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "kotlin-debug-adapter" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        kotlin_language_server = {},
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    opts = {
      setup = {
        kotlin_debug_adapter = function()
          local dap = require "dap"

          -- Adapter configuration
          dap.adapters.kotlin = {
            type = "executable",
            command = get_debug_adapter(),
            args = { "--interpreter=vscode" },
          }

          -- Configuration
          dap.configurations.kotlin = {
            {
              type = "kotlin",
              name = "launch - kotlin",
              request = "launch",
              projectRoot = vim.fn.getcwd() .. "/app",
              mainClass = function()
                return vim.fn.input("Path to main class > ", "", "file")
                -- return vim.fn.input("Path to main class > ", "myapp.sample.app.AppKt", "file")
              end,
            },
            {
              type = "kotlin",
              name = "attach - kotlin",
              request = "attach",
              projectRoot = vim.fn.getcwd() .. "/app",
              hostName = "localhost",
              port = 5005,
              timeout = 1000,
            },
          }
        end,
      },
    },
  },
}
