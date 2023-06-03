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
        omnisharp = {},
      },
      setup = {
        omnisharp = function()
          local lsp_utils = require "base.lsp.utils"
          lsp_utils.on_attach(function(client, bufnr)
            local function toSnakeCase(str)
              return string.gsub(str, "%s*[- ]%s*", "_")
            end
            if client.name == "omnisharp" then
              local tokenModifiers = client.server_capabilities.semanticTokensProvider.legend.tokenModifiers
              for i, v in ipairs(tokenModifiers) do
                tokenModifiers[i] = toSnakeCase(v)
              end
              local tokenTypes = client.server_capabilities.semanticTokensProvider.legend.tokenTypes
              for i, v in ipairs(tokenTypes) do
                tokenTypes[i] = toSnakeCase(v)
              end
            end
          end)
        end,
      },
    },
  },
  -- {
  --   "mfussenegger/nvim-dap",
  --   dependencies = {
  --     "mfussenegger/nvim-dap-python",
  --     config = function()
  --       require("dap-python").setup() -- Use default python
  --     end,
  --   },
  -- },
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
