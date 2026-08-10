export EDITOR='nvim'

export PATH="$HOME/.cargo/bin:$HOME/.jbang/bin:$PATH"
export PATH="/Applications/IntelliJ IDEA.app/Contents/MacOS:$PATH"


# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"

# Android SDK
export ANDROID_HOME="$HOME/Library/Android/sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$ANDROID_HOME/emulator:$ANDROID_HOME/platform-tools:$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"

# Local secrets. Put exports like OPENAI_API_KEY here instead of in .zshrc.
[[ -f "$HOME/.zsh_secrets" ]] && source "$HOME/.zsh_secrets"

set -o vi

# source "$HOMEBREW_PREFIX/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh"

source <(fzf --zsh)
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"

source "$HOMEBREW_PREFIX/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh"
source "$HOMEBREW_PREFIX/share/zsh-autosuggestions/zsh-autosuggestions.zsh"



# --- eza (active) ---
if command -v eza >/dev/null; then
  alias ls='eza --icons --group-directories-first'
  alias l='eza -l --icons --group-directories-first'
  alias ll='eza -l --icons --group-directories-first --header --git'
  alias la='eza -la --icons --group-directories-first --header --git'
  alias lt='eza --tree --level=2 --icons --group-directories-first'
  alias lta='eza --tree --level=2 --icons --group-directories-first -a'
fi


# aliases
alias fzfbat='fzf --preview="bat --theme=gruvbox-dark --color=always {}"'
alias fzfnvim='nvim $(fzf {}")'alias fzfnvim='fzf --preview="bat --theme=gruvbox-dark --color=always {}" --bind "enter:become(nvim {})"'

alias j!=jbang
alias cdc='cd ~/.config/'
alias kanata-start='sudo /Users/mvabal/.cargo/bin/kanata --cfg /Users/mvabal/.config/kanata/config.kbd'
alias kanata-restart='sudo pkill kanata 2>/dev/null; sudo /Users/mvabal/.cargo/bin/kanata --cfg /Users/mvabal/.config/kanata/config.kbd'

bindkey -M emacs '^Y' autosuggest-accept 2>/dev/null
bindkey -M viins '^Y' autosuggest-accept 2>/dev/null

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
# command -v ng >/dev/null && source <(ng completion script)

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
# NOTE: don't use escape sequences (like '%F{red}%d%f') here, fzf-tab will ignore them
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# force zsh not to show completion menu, which allows fzf-tab to capture the unambiguous prefix
zstyle ':completion:*' menu no
# preview directory's content with eza when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always $realpath'
# custom fzf flags
# NOTE: fzf-tab does not follow FZF_DEFAULT_OPTS by default
zstyle ':fzf-tab:*' fzf-flags --color=fg:1,fg+:2 --bind=tab:accept
# To make fzf-tab follow FZF_DEFAULT_OPTS.
# NOTE: This may lead to unexpected behavior since some flags break this plugin. See Aloxaf/fzf-tab#455.
zstyle ':fzf-tab:*' use-fzf-default-opts yes
# switch group using `<` and `>`
zstyle ':fzf-tab:*' switch-group '<' '>'

source "$HOMEBREW_PREFIX/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"

# Alias: invocar herdr (multiplexor tipo tmux) como hr
alias hr="herdr"
