-- guess-indent.nvim detects indentation automatically.
-- https://github.com/NMAC427/guess-indent.nvim

local plugins = {
  'https://github.com/NMAC427/guess-indent.nvim',
}

vim.pack.add(plugins)

require('guess-indent').setup {}
