-- blink.cmp provides autocompletion.
-- https://github.com/Saghen/blink.cmp

local plugins = {
  { src = 'https://github.com/Saghen/blink.cmp', version = vim.version.range '1.*' },
}

vim.pack.add(plugins)

require('blink.cmp').setup {
  keymap = {
    preset = 'default',
  },

  appearance = {
    nerd_font_variant = 'mono',
  },

  completion = {
    documentation = { auto_show = false, auto_show_delay_ms = 500 },
  },

  sources = {
    default = { 'lsp', 'path', 'snippets' },
  },

  snippets = { preset = 'luasnip' },

  fuzzy = { implementation = 'rust' },

  signature = { enabled = true },
}
