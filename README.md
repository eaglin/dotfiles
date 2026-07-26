# Dotfiles

Personal macOS dotfiles.

## Layout

This repository mirrors paths relative to `$HOME`:

- `.zshrc`
- `.yabairc`
- `.skhdrc`
- `.config/starship.toml`
- `.config/nvim/`
- `.config/tmux/`
- `.config/sketchybar/`
- `.config/kanata/`
- `.config/.aerospace.toml`

## Tmux Plugins

`~/.config/tmux/plugins/` is not versioned. Install TPM if it is missing:

```sh
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

Then open tmux and press `prefix + I` to install the configured plugins.
