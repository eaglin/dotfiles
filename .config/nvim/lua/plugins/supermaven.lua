vim.pack.add({
  { src = 'https://github.com/supermaven-inc/supermaven-nvim' },
})

local supermaven = require('supermaven-nvim')
local binary_ok, binary = pcall(require, 'supermaven-nvim.binary.binary_handler')

-- The plugin has no public option for choosing the free tier up front. Its
-- binary emits an activation popup before the free-tier command can settle.
-- Handle only that initial prompt automatically; explicit Pro prompts still
-- use the plugin's original popup implementation.
if binary_ok and type(binary.open_popup) == 'function' then
  local open_popup = binary.open_popup

  binary.open_popup = function(self, message, include_free)
    if include_free then
      self:use_free_version()
      return
    end

    return open_popup(self, message, include_free)
  end
end

supermaven.setup({
  keymaps = {
    accept_suggestion = '<C-l>',
    clear_suggestion = '<C-]>',
    accept_word = '<C-j>',
  },
  log_level = 'off',
})
