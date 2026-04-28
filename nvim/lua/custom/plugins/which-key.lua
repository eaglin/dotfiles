return { -- Useful plugin to show you pending keybinds.
  'folke/which-key.nvim',
  event = 'VimEnter',
  ---@module 'which-key'
  ---@type wk.Opts
  ---@diagnostic disable-next-line: missing-fields
  opts = {
    -- delay between pressing a key and opening which-key (milliseconds)
    delay = 0,
    icons = { mappings = vim.g.have_nerd_font },

    -- Document existing key chains
    spec = {
      { '<leader>s', group = '[S]earch', mode = { 'n', 'v' } },
      { '<leader>t', group = '[T]oggle' },
      { '<leader>h', group = 'Git [H]unk', mode = { 'n', 'v' } }, -- Enable gitsigns recommended keymaps first
      { '<leader>a', group = 'Add to Harpoon' },
      { '<leader>1', group = 'Harpoon File 1' },
      { '<leader>2', group = 'Harpoon File 2' },
      { '<leader>3', group = 'Harpoon File 3' },
      { '<leader>4', group = 'Harpoon File 4' },
      { 'gr', group = 'LSP Actions', mode = { 'n' } },
    },
  },
  keys = {
    {
      -- Keybinding to show which-key popup
      '<leader>?',
      function()
        require('which-key').show { global = false } -- Show the which-key popup for local keybindings
      end,
    },
    {
      -- Define a group for Obsidian-related commands
      '<leader>o',
      group = 'Obsidian',
    },
  },
}
