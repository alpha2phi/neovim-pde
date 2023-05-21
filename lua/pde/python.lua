if not require("config").pde.python then
  return {}
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "python" })
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    opts = function(_, opts)
      local nls = require "null-ls"
      table.insert(opts.sources, nls.builtins.formatting.black)
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "debugpy", "black", "ruff" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        ruff_lsp = {
          init_options = {
            settings = {
              args = { "--max-line-length=180" },
            },
          },
        },
        pyright = {
          settings = {
            python = {
              analysis = {
                autoImportCompletions = true,
                typeCheckingMode = "off",
                autoSearchPaths = true,
                useLibraryCodeForTypes = true,
                diagnosticMode = "workspace", -- "openFilesOnly",
              },
            },
          },
        },
      },
      setup = {
        pyright = function(_, _)
          local lsp_utils = require "base.lsp.utils"
          lsp_utils.on_attach(function(client, bufnr)
            local map = function(mode, lhs, rhs, desc)
              if desc then
                desc = desc
              end
              vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc, buffer = bufnr, noremap = true })
            end
            -- stylua: ignore
            if client.name == "pyright" then
              map("n", "<leader>lo", "<cmd>PyrightOrganizeImports<cr>",  "Organize Imports" )
              map("n", "<leader>lC", function() require("dap-python").test_class() end,  "Debug Class" )
              map("n", "<leader>lM", function() require("dap-python").test_method() end,  "Debug Method" )
              map("v", "<leader>lE", function() require("dap-python").debug_selection() end, "Debug Selection" )
            end
          end)
        end,
      },
    },
  },
  {
    "mfussenegger/nvim-dap",
    dependencies = {
      "mfussenegger/nvim-dap-python",
      config = function()
        require("dap-python").setup() -- Use default python
      end,
    },
  },
}
