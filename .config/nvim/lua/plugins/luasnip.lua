-- LuaSnip provides snippet expansion.
-- https://github.com/L3MON4D3/LuaSnip

local plugins = {
  { src = 'https://github.com/L3MON4D3/LuaSnip', version = vim.version.range '2.*' },
}

vim.pack.add(plugins)

require('luasnip').setup {}

-- friendly-snippets contains a variety of premade snippets.
-- vim.pack.add { 'https://github.com/rafamadriz/friendly-snippets' }
-- require('luasnip.loaders.from_vscode').lazy_load()
