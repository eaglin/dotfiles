-- conform.nvim provides formatting.
-- https://github.com/stevearc/conform.nvim

local plugins = {
  'https://github.com/stevearc/conform.nvim',
}

vim.pack.add(plugins)

require('conform').setup {
  notify_on_error = false,
  format_on_save = function(bufnr)
    local enabled_filetypes = {
      -- lua = true,
      -- python = true,
    }

    if enabled_filetypes[vim.bo[bufnr].filetype] then return { timeout_ms = 500 } end

    return nil
  end,
  default_format_opts = {
    lsp_format = 'fallback',
  },
  formatters_by_ft = {
    -- rust = { 'rustfmt' },
    -- python = { 'isort', 'black' },
    -- javascript = { 'prettierd', 'prettier', stop_after_first = true },
  },
}

vim.keymap.set({ 'n', 'v' }, '<leader>f', function() require('conform').format { async = true } end, { desc = '[F]ormat buffer' })
