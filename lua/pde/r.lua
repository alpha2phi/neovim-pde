if not require("config").pde.r then
  return {}
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "r" })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        r_language_server = {
          flags = { debounce_text_changes = 150 },
        },
      },
    },
  },
}
