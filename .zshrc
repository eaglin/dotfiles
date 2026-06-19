
# opencode
export PATH="$HOME/.opencode/bin:$PATH"

# IntelliJ IDEA command-line launcher
export PATH="/Applications/IntelliJ IDEA.app/Contents/MacOS:$PATH"
# Set up fzf key bindings and fuzzy completion
source <(fzf --zsh)
eval "$(starship init zsh)"
eval "$(zoxide init zsh)"
# source /opt/homebrew/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
    source "$HOMEBREW_PREFIX/opt/fzf-tab/share/fzf-tab/fzf-tab.zsh"


if command -v eza >/dev/null; then
  alias ls='eza --icons --group-directories-first'
  alias l='eza -l --icons --group-directories-first'
  alias ll='eza -l --icons --group-directories-first --header --git'
  alias la='eza -la --icons --group-directories-first --header --git'
  alias lt='eza --tree --level=2 --icons --group-directories-first'
  alias lta='eza --tree --level=2 --icons --group-directories-first -a'
fi

alias fzfbat='fzf --preview="bat --theme=gruvbox-dark --color=always {}"'
alias fzfnvim='nvim $(fzf --preview="bat --theme=gruvbox-dark  --color=always {}")'

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

#compdef opencode
###-begin-opencode-completions-###
#
# yargs command completion script
#
# Installation: opencode completion >> ~/.zshrc
#    or opencode completion >> ~/.zprofile on OSX.
#
_opencode_yargs_completions()
{
  local reply
  local si=$IFS
  IFS=$'
' reply=($(COMP_CWORD="$((CURRENT-1))" COMP_LINE="$BUFFER" COMP_POINT="$CURSOR" opencode --get-yargs-completions "${words[@]}"))
  IFS=$si
  if [[ ${#reply} -gt 0 ]]; then
    _describe 'values' reply
  else
    _default
  fi
}
if [[ "'${zsh_eval_context[-1]}" == "loadautofunc" ]]; then
  _opencode_yargs_completions "$@"
else
  compdef _opencode_yargs_completions opencode
fi
###-end-opencode-completions-###
