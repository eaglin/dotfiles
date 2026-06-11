-- which-key.nvim shows pending keybinds.
-- https://github.com/folke/which-key.nvim

local plugins = {
  'https://github.com/folke/which-key.nvim',
}

vim.pack.add(plugins)

require('which-key').setup {
  delay = 0,
  icons = { mappings = vim.g.have_nerd_font },
  spec = {
    { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
    { '<leader>t', group = '[T]oggle' },
    { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } },
    { 'gr', group = 'LSP Actions', mode = { 'n' } },
  },
}
