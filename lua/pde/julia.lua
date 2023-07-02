if not require("config").pde.julia then
  return {}
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "julia" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        julials = {},
      },
    },
  },
}
