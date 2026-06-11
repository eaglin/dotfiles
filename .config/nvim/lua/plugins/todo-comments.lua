-- todo-comments.nvim highlights todo, notes, etc in comments.
-- https://github.com/folke/todo-comments.nvim

local plugins = {
  'https://github.com/folke/todo-comments.nvim',
}

vim.pack.add(plugins)

require('todo-comments').setup { signs = false }
