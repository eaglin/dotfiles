# Dotfiles

Personal macOS dotfiles.

## Layout

This repository mirrors paths relative to `$HOME`:

- `.zshrc`
- `.yabairc`
- `.skhdrc`
- `.local/bin/`
- `.config/starship.toml`
- `.config/nvim/`
- `.config/tmux/`
- `.config/sketchybar/`
- `.config/kanata/`
- `.config/herdr/config.toml`
- `.config/.aerospace.toml`
- `.pi/agent/` — configuración portable de Pi (sin credenciales, sesiones ni estado generado)

## Tmux Plugins

`~/.config/tmux/plugins/` is not versioned. Install TPM if it is missing:

```sh
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

Then open tmux and press `prefix + I` to install the configured plugins.

## Pi

The tracked Pi configuration includes settings, keybindings, agents, extensions, theme, and custom skills. Credentials and runtime state are intentionally excluded; authenticate Pi separately after installing the dotfiles.
