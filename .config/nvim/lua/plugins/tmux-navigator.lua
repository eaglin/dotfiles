-- vim-tmux-navigator
-- Lets you navigate between vim splits and tmux panes seamlessly with C-h/j/k/l
-- https://github.com/christoomey/vim-tmux-navigator
--
-- tmux config (already set in ~/.tmux.conf):
--   set -g @plugin 'christoomey/vim-tmux-navigator'
--   set -g @vim_navigator_mapping_left  "C-Left C-h"
--   set -g @vim_navigator_mapping_right "C-Right C-l"
--   set -g @vim_navigator_mapping_up    "C-k"
--   set -g @vim_navigator_mapping_down  "C-j"
--   set -g @vim_navigator_mapping_prev  ""

local plugins = {
  'https://github.com/christoomey/vim-tmux-navigator',
}

vim.pack.add(plugins)