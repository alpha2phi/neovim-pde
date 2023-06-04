if not require("config").pde.solidty then
  return {}
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "solidity" })
    end,
  },
  -- {
  --   "williamboman/mason.nvim",
  --   opts = function(_, opts)
  --     vim.list_extend(opts.ensure_installed, { "netcoredbg" })
  --   end,
  -- },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        solc = {},
      },
    },
  },
  -- {
  --   "mfussenegger/nvim-dap",
  --   opts = {
  --     setup = {
  --       netcoredbg = function(_, _)
  --         local dap = require "dap"

  --         local function get_debugger()
  --           local mason_registry = require "mason-registry"
  --           local debugger = mason_registry.get_package "netcoredbg"
  --           return debugger:get_install_path() .. "/netcoredbg"
  --         end

  --         dap.configurations.cs = {
  --           {
  --             type = "coreclr",
  --             name = "launch - netcoredbg",
  --             request = "launch",
  --             program = function()
  --               return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/bin/Debug/", "file")
  --             end,
  --           },
  --         }
  --         dap.adapters.coreclr = {
  --           type = "executable",
  --           command = get_debugger(),
  --           args = { "--interpreter=vscode" },
  --         }
  --         dap.adapters.netcoredbg = {
  --           type = "executable",
  --           command = get_debugger(),
  --           args = { "--interpreter=vscode" },
  --         }
  --       end,
  --     },
  --   },
  -- },
  -- {
  --   "nvim-neotest/neotest",
  --   dependencies = {
  --     "Issafalcon/neotest-dotnet",
  --   },
  --   opts = function(_, opts)
  --     vim.list_extend(opts.adapters, {
  --       require "neotest-dotnet",
  --     })
  --   end,
  -- },
}
