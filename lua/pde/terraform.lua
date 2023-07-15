if not require("config").pde.terraform then
  return {}
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, {
        "terraform",
        "hcl",
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        terraformls = {},
      },
    },
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    opts = function(_, opts)
      local null_ls = require "null-ls"
      vim.list_extend(opts.sources, {
        null_ls.builtins.formatting.terraform_fmt,
        null_ls.builtins.diagnostics.terraform_validate,
      })
    end,
  },
}
