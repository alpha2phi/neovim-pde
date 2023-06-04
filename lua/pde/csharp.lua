if not require("config").pde.csharp then
  return {}
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "c_sharp" })
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "netcoredbg" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md#omnisharp
        omnisharp = {
          organize_imports_on_format = true,
          enable_import_completion = true,
        },
      },
      setup = {
        omnisharp = function()
          local lsp_utils = require "base.lsp.utils"
          lsp_utils.on_attach(function(client, bufnr)
            if client.name == "omnisharp" then
              local map = function(mode, lhs, rhs, desc)
                if desc then
                  desc = desc
                end
                vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc, buffer = bufnr, noremap = true })
              end

              -- https://github.com/OmniSharp/omnisharp-roslyn/issues/2483
              local function toSnakeCase(str)
                return string.gsub(str, "%s*[- ]%s*", "_")
              end

              local tokenModifiers = client.server_capabilities.semanticTokensProvider.legend.tokenModifiers
              for i, v in ipairs(tokenModifiers) do
                tokenModifiers[i] = toSnakeCase(v)
              end
              local tokenTypes = client.server_capabilities.semanticTokensProvider.legend.tokenTypes
              for i, v in ipairs(tokenTypes) do
                tokenTypes[i] = toSnakeCase(v)
              end

              -- C# keymappings
              -- stylua: ignore
              map("n","<leader>td","<cmd>w|lua require('neotest').run.run({vim.fn.expand('%'), strategy = require('neotest-dotnet.strategies.netcoredbg'), is_custom_dotnet_debug = true})<cr>", "Debug File")

              -- stylua: ignore
              map("n","<leader>tL","<cmd>w|lua require('neotest').run.run_last({strategy = require('neotest-dotnet.strategies.netcoredbg'), is_custom_dotnet_debug = true})<cr>", "Debug Last")

              -- stylua: ignore
              map("n","<leader>tN","<cmd>w|lua require('neotest').run.run({strategy = require('neotest-dotnet.strategies.netcoredbg'), is_custom_dotnet_debug = true})<cr>", "Debug Nearest")
            end
          end)
        end,
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    opts = {
      setup = {
        netcoredbg = function(_, _)
          local dap = require "dap"

          local function get_debugger()
            local mason_registry = require "mason-registry"
            local debugger = mason_registry.get_package "netcoredbg"
            return debugger:get_install_path() .. "/netcoredbg"
          end

          dap.configurations.cs = {
            {
              type = "coreclr",
              name = "launch - netcoredbg",
              request = "launch",
              program = function()
                return vim.fn.input("Path to dll", vim.fn.getcwd() .. "/bin/Debug/", "file")
              end,
            },
          }
          dap.adapters.coreclr = {
            type = "executable",
            command = get_debugger(),
            args = { "--interpreter=vscode" },
          }
          dap.adapters.netcoredbg = {
            type = "executable",
            command = get_debugger(),
            args = { "--interpreter=vscode" },
          }
        end,
      },
    },
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "Issafalcon/neotest-dotnet",
    },
    opts = function(_, opts)
      vim.list_extend(opts.adapters, {
        require "neotest-dotnet",
      })
    end,
  },
}
