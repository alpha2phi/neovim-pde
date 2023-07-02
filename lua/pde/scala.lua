if not require("config").pde.scala then
  return {}
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "scala" })
    end,
  },
  {
    "scalameta/nvim-metals",
    dependencies = { "nvim-lua/plenary.nvim" },
    ft = { "scala" },
    opts = {},
    config = function(_, opts)
      local nvim_metals_group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter" }, {
        pattern = { "*.scala", "*.sbt", "*.sc" },
        callback = function()
          local metals_config = require("metals").bare_config()
          metals_config.on_attach = function(client, bufnr)
            require("metals").setup_dap()
          end
          metals_config.init_options.statusBarProvider = "on"
          metals_config.settings = {
            showImplicitArguments = false,
            showInferredType = true,
            excludedPackages = {},
          }
          require("metals").initialize_or_attach(metals_config)
        end,
        group = nvim_metals_group,
      })
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "stevanmilic/neotest-scala",
    },
    opts = function(_, opts)
      vim.list_extend(opts.adapters, {
        require "neotest-scala",
      })
    end,
  },
}
