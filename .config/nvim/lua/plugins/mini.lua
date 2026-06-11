-- mini.nvim is a collection of small independent plugins/modules.
-- https://github.com/nvim-mini/mini.nvim

local plugins = {
  'https://github.com/nvim-mini/mini.nvim',
}

vim.pack.add(plugins)

require('mini.ai').setup {
  mappings = {
    around_next = 'aa',
    inside_next = 'ii',
  },
  n_lines = 500,
}

require('mini.surround').setup()
require('mini.files').setup()

local statusline = require 'mini.statusline'
statusline.setup { use_icons = vim.g.have_nerd_font }

---@diagnostic disable-next-line: duplicate-set-field
statusline.section_location = function() return '%2l:%-2v' end
