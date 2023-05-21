if not require("config").pde.java then
  return {}
end

local function get_jdtls()
  local mason_registry = require "mason-registry"
  local jdtls = mason_registry.get_package "jdtls"
  local jdtls_path = jdtls:get_install_path()
  local launcher = vim.fn.glob(jdtls_path .. "/plugins/org.eclipse.equinox.launcher_*.jar")
  local SYSTEM = "linux"
  if vim.fn.has "mac" == 1 then
    SYSTEM = "mac"
  end
  local config = jdtls_path .. "/config_" .. SYSTEM
  local lombok = jdtls_path .. "/lombok.jar"
  return launcher, config, lombok
end

local function get_bundles()
  local mason_registry = require "mason-registry"
  local java_debug = mason_registry.get_package "java-debug-adapter"
  local java_test = mason_registry.get_package "java-test"
  local java_debug_path = java_debug:get_install_path()
  local java_test_path = java_test:get_install_path()
  local bundles = {}
  vim.list_extend(bundles, vim.split(vim.fn.glob(java_debug_path .. "/extension/server/com.microsoft.java.debug.plugin-*.jar"), "\n"))
  vim.list_extend(bundles, vim.split(vim.fn.glob(java_test_path .. "/extension/server/*.jar"), "\n"))
  return bundles
end

local function get_workspace()
  local home = os.getenv "HOME"
  local workspace_path = home .. "/.local/share/nde/jdtls-workspace/"
  local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
  local workspace_dir = workspace_path .. project_name
  return workspace_dir
end

return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "java" })
    end,
  },
  {
    "williamboman/mason.nvim",
    opts = function(_, opts)
      vim.list_extend(opts.ensure_installed, { "jdtls", "java-debug-adapter", "java-test", "google-java-format" })
    end,
  },
  {
    "jose-elias-alvarez/null-ls.nvim",
    opts = function(_, opts)
      local nls = require "null-ls"
      table.insert(opts.sources, nls.builtins.formatting.google_java_format)
    end,
  },
  {
    "mfussenegger/nvim-jdtls",
    dependencies = { "mfussenegger/nvim-dap", "neovim/nvim-lspconfig" },
    event = "VeryLazy",
    config = function()
      -- Autocmd
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "java" },
        callback = function()
          local jdtls = require "jdtls"

          -- LSP capabilities
          local capabilities = require("base.lsp.utils").capabilities()
          local extendedClientCapabilities = jdtls.extendedClientCapabilities
          extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

          local launcher, os_config, lombok = get_jdtls()
          local workspace_dir = get_workspace()
          local bundles = get_bundles()

          local on_attach = function(client, bufnr)
            vim.lsp.codelens.refresh()
            require("jdtls").setup_dap { hotcodereplace = "auto" }
            require("jdtls.dap").setup_dap_main_class_configs()
            require("jdtls.setup").add_commands()

            local map = function(mode, lhs, rhs, desc)
              if desc then
                desc = desc
              end
              vim.keymap.set(mode, lhs, rhs, { silent = true, desc = desc, buffer = bufnr, noremap = true })
            end
            -- local mappings = {
            --   C = {
            --     name = "Java",
            --     o = { "<Cmd>lua require'jdtls'.organize_imports()<CR>", "Organize Imports" },
            --     v = { "<Cmd>lua require('jdtls').extract_variable()<CR>", "Extract Variable" },
            --     c = { "<Cmd>lua require('jdtls').extract_constant()<CR>", "Extract Constant" },
            --     t = { "<Cmd>lua require'jdtls'.test_nearest_method()<CR>", "Test Method" },
            --     T = { "<Cmd>lua require'jdtls'.test_class()<CR>", "Test Class" },
            --     u = { "<Cmd>JdtUpdateConfig<CR>", "Update Config" },
            --   },
            -- }

            -- local vmappings = {
            --   C = {
            --     name = "Java",
            --     v = { "<Esc><Cmd>lua require('jdtls').extract_variable(true)<CR>", "Extract Variable" },
            --     c = { "<Esc><Cmd>lua require('jdtls').extract_constant(true)<CR>", "Extract Constant" },
            --     m = { "<Esc><Cmd>lua require('jdtls').extract_method(true)<CR>", "Extract Method" },
            --   },
            -- }

            -- vim.api.nvim_create_autocmd({ "BufWritePost" }, {
            --   pattern = { "*.java" },
            --   callback = function()
            --     local _, _ = pcall(vim.lsp.codelens.refresh)
            --   end,
            -- })

            vim.api.nvim_create_autocmd("BufWritePost", {
              pattern = { "*.java" },
              buffer = bufnr,
              callback = function()
                client.request_sync("java/buildWorkspace", false, 5000, bufnr)
              end,
            })

            -- vim.keymap.set('n', "<A-o>", jdtls.organize_imports, opts)
            -- vim.keymap.set('n', "<leader>df", jdtls.test_class, opts)
            -- vim.keymap.set('n', "<leader>dn", jdtls.test_nearest_method, opts)
            -- vim.keymap.set('n', "crv", jdtls.extract_variable, opts)
            -- vim.keymap.set('v', 'crm', [[<ESC><CMD>lua require('jdtls').extract_method(true)<CR>]], opts)
            -- vim.keymap.set('n', "crc", jdtls.extract_constant, opts)
            -- local create_command = vim.api.nvim_buf_create_user_command
            -- create_command(bufnr, 'W', require('me.lsp.ext').remove_unused_imports, {
            --   nargs = 0,
            -- })
          end

          local config = {
            cmd = {
              "java",
              "-Declipse.application=org.eclipse.jdt.ls.core.id1",
              "-Dosgi.bundles.defaultStartLevel=4",
              "-Declipse.product=org.eclipse.jdt.ls.core.product",
              "-Dlog.protocol=true",
              "-Dlog.level=ALL",
              "-Xms1g",
              "--add-modules=ALL-SYSTEM",
              "--add-opens",
              "java.base/java.util=ALL-UNNAMED",
              "--add-opens",
              "java.base/java.lang=ALL-UNNAMED",
              "-javaagent:" .. lombok,
              "-jar",
              launcher,
              "-configuration",
              os_config,
              "-data",
              workspace_dir,
            },
            root_dir = require("jdtls.setup").find_root { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle" },
            capabilities = capabilities,
            on_attach = on_attach,

            settings = {
              java = {
                autobuild = { enabled = false },
                signatureHelp = { enabled = true },
                contentProvider = { preferred = "fernflower" },
                saveActions = {
                  organizeImports = true,
                },
                completion = {
                  favoriteStaticMembers = {
                    "io.crate.testing.Asserts.assertThat",
                    "org.assertj.core.api.Assertions.assertThat",
                    "org.assertj.core.api.Assertions.assertThatThrownBy",
                    "org.assertj.core.api.Assertions.assertThatExceptionOfType",
                    "org.assertj.core.api.Assertions.catchThrowable",
                    "org.hamcrest.MatcherAssert.assertThat",
                    "org.hamcrest.Matchers.*",
                    "org.hamcrest.CoreMatchers.*",
                    "org.junit.jupiter.api.Assertions.*",
                    "java.util.Objects.requireNonNull",
                    "java.util.Objects.requireNonNullElse",
                    "org.mockito.Mockito.*",
                  },
                  filteredTypes = {
                    "com.sun.*",
                    "io.micrometer.shaded.*",
                    "java.awt.*",
                    "jdk.*",
                    "sun.*",
                  },
                },
                sources = {
                  organizeImports = {
                    starThreshold = 9999,
                    staticStarThreshold = 9999,
                  },
                },
                codeGeneration = {
                  toString = {
                    template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                  },
                  hashCodeEquals = {
                    useJava7Objects = true,
                  },
                  useBlocks = true,
                },
                eclipse = {
                  downloadSources = true,
                },
                configuration = {
                  updateBuildConfiguration = "interactive",
                  -- NOTE: Add the available runtimes here
                  -- https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
                  -- runtimes = {
                  --   {
                  --     name = "JavaSE-18",
                  --     path = "~/.sdkman/candidates/java/18.0.2-sem",
                  --   },
                  -- },
                },
                maven = {
                  downloadSources = true,
                },
                implementationsCodeLens = {
                  enabled = true,
                },
                referencesCodeLens = {
                  enabled = true,
                },
                references = {
                  includeDecompiledSources = true,
                },
                inlayHints = {
                  parameterNames = {
                    enabled = "all", -- literals, all, none
                  },
                },
                format = {
                  enabled = false,
                },
                -- NOTE: We can set the formatter to use different styles
                -- format = {
                --   enabled = true,
                --   settings = {
                --     url = vim.fn.stdpath "config" .. "/lang-servers/intellij-java-google-style.xml",
                --     profile = "GoogleStyle",
                --   },
                -- },
              },
            },
            init_options = {
              bundles = bundles,
              extendedClientCapabilities = extendedClientCapabilities,
            },
          }
          require("jdtls").start_or_attach(config)
        end,
      })
    end,
  },
}
