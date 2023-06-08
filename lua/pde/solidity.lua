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
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        -- solc = {},
        -- solang = {},
        solidity_ls_nomicfoundation = {},
      },
    },
  },
}
