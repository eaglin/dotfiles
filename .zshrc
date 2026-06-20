export EDITOR='nvim'

export PATH="$HOME/.cargo/bin:$HOME/.jbang/bin:$PATH"

BREW_BIN="/opt/homebrew/bin"

# Homebrew
if [[ -x "$BREW_BIN/brew" ]]; then
  eval "$($BREW_BIN/brew shellenv)"
fi

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"

# Local secrets. Put exports like OPENAI_API_KEY here instead of in .zshrc.
[[ -f "$HOME/.zsh_secrets" ]] && source "$HOME/.zsh_secrets"

# Completion system
autoload -Uz compinit
compinit

zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
zstyle ':completion:*' menu no
zstyle ':fzf-tab:*' fzf-command fzf
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color=auto $realpath 2>/dev/null || ls $realpath 2>/dev/null'

# zsh-autocomplete is intentionally not loaded because it conflicts with
# zsh-autosuggestions/fzf-tab widget handling.
[[ -f "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]] && source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
[[ -f "$HOMEBREW_PREFIX/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh" ]] && source "$HOMEBREW_PREFIX/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh"

export FZF_DEFAULT_COMMAND="fd --hidden --strip-cwd-prefix --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type=d --hidden --strip-cwd-prefix --exclude .git"

# ls replacement — uncomment ONE block at a time and restart the shell.
# Icons need a Nerd Font installed in your terminal (e.g. MesloLGS NF).

# --- eza (active) ---
if command -v eza >/dev/null; then
  alias ls='eza --icons --group-directories-first'
  alias l='eza -l --icons --group-directories-first'
  alias ll='eza -l --icons --group-directories-first --header --git'
  alias la='eza -la --icons --group-directories-first --header --git'
  alias lt='eza --tree --level=2 --icons --group-directories-first'
  alias lta='eza --tree --level=2 --icons --group-directories-first -a'
fi

# --- lsd (commented — uncomment to swap) ---
# if command -v lsd >/dev/null; then
#   alias ls='lsd --icon=always --group-dirs=first'
#   alias l='lsd -l --icon=always --group-dirs=first'
#   alias ll='lsd -l --icon=always --group-dirs=first --header --git'
#   alias la='lsd -la --icon=always --group-dirs=first --header --git'
#   alias lt='lsd --tree --depth=2 --icon=always --group-dirs=first'
#   alias lta='lsd --tree --depth=2 --icon=always --group-dirs=first -a'
# fi

# aliases
alias fzfbat='fzf --preview="bat --theme=gruvbox-dark --color=always {}"'
alias fzfnvim='nvim $(fzf {}")'alias fzfnvim='fzf --preview="bat --theme=gruvbox-dark --color=always {}" --bind "enter:become(nvim {})"'

alias j!=jbang
alias cdc='cd ~/.config/'
alias kanata-start='sudo /Users/mvabal/.cargo/bin/kanata --cfg /Users/mvabal/.config/kanata/config.kbd'
alias kanata-restart='sudo pkill kanata 2>/dev/null; sudo /Users/mvabal/.cargo/bin/kanata --cfg /Users/mvabal/.config/kanata/config.kbd'

export CARAPACE_BRIDGES='zsh,fish,bash,inshellisense'
command -v carapace >/dev/null && source <(carapace _carapace)

set -o vi

if [[ -t 0 ]]; then
  command -v fzf >/dev/null && eval "$(fzf --zsh)"
  command -v atuin >/dev/null && eval "$(atuin init zsh --disable-up-arrow)"
fi

command -v zoxide >/dev/null && eval "$(zoxide init zsh)"
command -v starship >/dev/null && eval "$(starship init zsh)"

bindkey -M emacs '^Y' autosuggest-accept 2>/dev/null
bindkey -M viins '^Y' autosuggest-accept 2>/dev/null

[[ -f "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]] && source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# YouTube downloader function
ytdl() {
  if [ -z "$1" ]; then
    echo "Usage: ytdl <youtube-url>"
    return 1
  fi
  yt-dlp -f "bv*+ba/b" -S "lang:en" "$1" -o "%(title)s.%(ext)s"
}

# THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

# Load Angular CLI autocompletion.
command -v ng >/dev/null && source <(ng completion script)
