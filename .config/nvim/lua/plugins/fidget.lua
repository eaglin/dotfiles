-- fidget.nvim shows useful LSP status updates.
-- https://github.com/j-hui/fidget.nvim

local plugins = {
  'https://github.com/j-hui/fidget.nvim',
}

vim.pack.add(plugins)

require('fidget').setup {}
