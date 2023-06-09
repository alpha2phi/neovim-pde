if not require("config").pde.jupyter then
  return {}
end

local CELL_MARKER_COLOR = "#C5C5C5"
local CELL_MARKER = "^# %%%%"

vim.api.nvim_set_hl(0, "cell_marker_hl", { bg = CELL_MARKER_COLOR })
vim.fn.sign_define("cell_marker_sign", { linehl = "cell_marker_hl" })

local function highlight_cell_markers()
  local bufnr = vim.api.nvim_get_current_buf()
  local sign_name = "cell_marker_sign"
  local sign_text = "%%"

  vim.fn.sign_unplace("cell_marker_sign", { buffer = bufnr })
  local total_lines = vim.api.nvim_buf_line_count(bufnr)
  for line = 1, total_lines do
    local line_content = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
    if line_content:find(CELL_MARKER) then
      vim.fn.sign_place(line, "cell_marker_sign", sign_name, bufnr, {
        lnum = line,
        priority = 10,
        text = sign_text,
      })
    end
  end
end

local function execute_cell()
  local bufnr = vim.api.nvim_get_current_buf()
  local current_row = vim.api.nvim_win_get_cursor(0)[1]
  local current_col = vim.api.nvim_win_get_cursor(0)[2]

  local start_line = nil
  local end_line = nil

  for line = current_row, 1, -1 do
    local line_content = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
    if line_content:find(CELL_MARKER) then
      start_line = line
      break
    end
  end

  for line = current_row, vim.api.nvim_buf_line_count(bufnr) do
    local line_content = vim.api.nvim_buf_get_lines(bufnr, line - 1, line, false)[1]
    if line_content:find(CELL_MARKER) then
      end_line = line
      break
    end
  end

  vim.print(current_row, start_line, end_line)
  local rows_to_select = end_line - start_line - 3
  vim.api.nvim_win_set_cursor(0, { start_line + 1, 0 })
  vim.cmd("normal!V " .. rows_to_select .. "j")
  require("iron.core").visual_send()
  vim.api.nvim_win_set_cursor(0, { current_row, current_col })
end

return {
  {
    "goerz/jupytext.vim",
    build = "pip install jupytext",
    event = "VeryLazy",
    dependencies = { "neovim/nvim-lspconfig" },
    opts = {},
    config = function()
      -- The destination format: 'ipynb', 'markdown' or 'script', or a file extension: 'md', 'Rmd', 'jl', 'py', 'R', ..., 'auto' (script
      -- extension matching the notebook language), or a combination of an extension and a format name, e.g. md:markdown, md:pandoc,
      -- md:myst or py:percent, py:light, py:nomarker, py:hydrogen, py:sphinx. The default format for scripts is the 'light' format,
      -- which uses few cell markers (none when possible). Alternatively, a format compatible with many editors is the 'percent' format,
      -- which uses '# %%' as cell markers. The main formats (markdown, light, percent) preserve notebooks and text documents in a
      -- roundtrip. Use the --test and and --test-strict commands to test the roundtrip on your files. Read more about the available
      -- formats at https://jupytext.readthedocs.io/en/latest/formats.html (default: None)
      vim.g.jupytext_fmt = "py:percent"

      -- Autocmd to set cell markers
      vim.api.nvim_create_autocmd({ "BufEnter", "BufWriteCmd" }, {
        group = vim.api.nvim_create_augroup("au_toggle_cell_marker", { clear = true }),
        pattern = { "*.py", "*.ipynb" },
        callback = function()
          vim.schedule(highlight_cell_markers)
        end,
      })
    end,
  },
  {
    "Vigemus/iron.nvim",
    event = "VeryLazy",
    opts = function()
      return {
        config = {
          -- Whether a repl should be discarded or not
          scratch_repl = true,
          -- Your repl definitions come here

          repl_definition = {
            python = require("iron.fts.python").ipython,
          },
          -- How the repl window will be displayed
          -- See below for more information
          repl_open_cmd = require("iron.view").right "50%",
        },
        -- If the highliht is on, you can change how it looks
        -- For the available options, check nvim_set_hl
        highlight = {
          italic = true,
        },
        ignore_blank_lines = true, -- ignore blank lines when sending visual select lines
      }
    end,
    -- stylua: ignore
    keys = {
      { "<leader>xe", execute_cell, desc = "Execute Cell" },
      { "<leader>xs", function() require("iron.core").run_motion("send_motion") end, desc = "Send Motion" },
      { "<leader>xs", function() require("iron.core").visual_send() end, mode = {"v"}, desc = "Send" },
      { "<leader>xl", function() require("iron.core").send_line() end, desc = "Send Line" },
      { "<leader>xt", function() require("iron.core").send_until_cursor() end, desc = "Send Until Cursor" },
      { "<leader>xf", function() require("iron.core").send_file() end, desc = "Send File" },
      { "<leader>xh", function() require("iron.marks").clear_hl() end, mode = {"v"}, desc = "Clear Highlight" },
      { "<leader>x<cr>", function() require("iron.core").send(nil, string.char(13)) end, desc = "ENTER" },
      { "<leader>xi", function() require("iron.core").send(nil, string.char(03)) end, desc = "Interrupt" },
      { "<leader>xq", function() require("iron.core").close_repl() end, desc = "Close REPL" },
      { "<leader>xc", function() require("iron.core").send(nil, string.char(12)) end, desc = "Clear" },
      { "<leader>xms", function() require("iron.core").send_mark() end, desc = "Send Mark" },
      { "<leader>xmm", function() require("iron.core").run_motion("mark_motion") end, desc = "Mark Motion" },
      { "<leader>xmv", function() require("iron.core").mark_visual() end, mode = {"v"}, desc = "Mark Visual" },
      { "<leader>xmr", function() require("iron.marks").drop_last() end, desc = "Remove Mark" },
      { "<leader>xR", "<cmd>IronRepl<cr>", desc = "REPL" },
      { "<leader>xS", "<cmd>IronRestart<cr>", desc = "Restart" },
      { "<leader>xF", "<cmd>IronFocus<cr>", desc = "Focus" },
      { "<leader>xH", "<cmd>IronHide<cr>", desc = "Hide" },
    },
    config = function(_, opts)
      local iron = require "iron.core"
      iron.setup(opts)
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      defaults = {
        ["<leader>x"] = { name = "+REPL" },
        ["<leader>xm"] = { name = "+Mark" },
      },
    },
  },
}
