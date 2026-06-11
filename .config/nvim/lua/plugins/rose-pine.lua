-- rose-pine is the configured colorscheme.
-- https://github.com/rose-pine/neovim

local plugins = {
  {
    src = 'https://github.com/rose-pine/neovim',
    name = 'rose-pine',
  },
}

vim.pack.add(plugins)

require('rose-pine').setup {}
vim.cmd.colorscheme 'rose-pine-moon'
