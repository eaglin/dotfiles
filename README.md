# Dotfiles

Personal macOS dotfiles managed with GNU Stow.

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

## Apply With Stow

From the parent directory:

```sh
cd ~/personal
stow -t "$HOME" dotfiles
```

If files already exist in `$HOME`, Stow will report conflicts. After confirming the repo copy is current, either move those files aside first or use Stow adoption intentionally:

```sh
cd ~/personal
stow --adopt -t "$HOME" dotfiles
git -C ~/personal/dotfiles diff
```

Review the diff after `--adopt`; it moves existing files into the package before linking them.

## Tmux Plugins

`~/.config/tmux/plugins/` is not versioned. Install TPM after stowing if it is missing:

```sh
git clone https://github.com/tmux-plugins/tpm ~/.config/tmux/plugins/tpm
```

Then open tmux and press `prefix + I` to install the configured plugins.
