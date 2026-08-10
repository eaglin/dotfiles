vim.pack.add({
  { src = 'https://github.com/folke/noice.nvim' },
  { src = 'https://github.com/MunifTanjim/nui.nvim' },
})

require('noice').setup({
  cmdline = {
    enabled = true,
    view = 'cmdline_popup',
  },
  messages = {
    enabled = true,
    view = 'mini',
    view_error = 'mini',
    view_warn = 'mini',
    view_history = 'messages',
    view_search = 'virtualtext',
  },
  popupmenu = {
    enabled = true,
    backend = 'nui',
  },
  notify = {
    enabled = false,
  },
  lsp = {
    progress = {
      enabled = false,
    },
  },
})

vim.keymap.set('n', '<leader>sn', '<cmd>Noice<CR>', { desc = 'Noice History' })
vim.keymap.set('n', '<leader>sN', '<cmd>Noice last<CR>', { desc = 'Noice Last Message' })
