#!/usr/bin/env bash
#
# install.sh — instala TODAS las dependencias que necesitan tus dotfiles.
# Pensado para ejecutarse en un macOS fresco (Apple Silicon) antes de hacer
#   cd ~/personal && stow -t "$HOME" dotfiles
#
# Uso:
#   ./install.sh            # instala todo
#   ./install.sh --check    # solo lista qué falta sin instalar nada
#
# Idempotente: salta lo que ya está instalado. Requiere sudo para yabai/skhd
# y para el cargo de kanata (se pedirá cuando toque).
#
set -euo pipefail

# ─────────────────────────── helpers ────────────────────────────────────────
CHECK_ONLY=false
[[ "${1:-}" == "--check" ]] && CHECK_ONLY=true

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  sed -n '2,12p' "$0"; exit 0
fi

log()  { printf '\033[1;34m▸ %s\033[0m\n' "$*"; }
ok()   { printf '\033[1;32m✓ %s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m! %s\033[0m\n' "$*" >&2; }
die()  { printf '\033[1;31m✗ %s\033[0m\n' "$*" >&2; exit 1; }

have() { command -v "$1" >/dev/null 2>&1; }
have_cask() { brew list --cask 2>/dev/null | grep -qx "$1"; }

run() {
  if $CHECK_ONLY; then
    printf '  would run: %s\n' "$*"
  else
    "$@" || die "fallo: $*"
  fi
}

brew_install() {
  for pkg in "$@"; do
    if brew list --formula 2>/dev/null | grep -qx "$pkg" || have "$pkg"; then
      [[ -z "${VERBOSE:-}" ]] || ok "ya instalado: $pkg"
    else
      log "brew install $pkg"
      run brew install "$pkg"
    fi
  done
}

brew_cask_install() {
  for cask in "$@"; do
    if have_cask "$cask" || have "$cask"; then
      [[ -z "${VERBOSE:-}" ]] || ok "ya instalado: $cask (cask)"
    else
      log "brew install --cask $cask"
      run brew install --cask "$cask"
    fi
  done
}

tap() { brew tap | grep -qx "$1" || run brew tap "$1"; }

# ─────────────────────────── 0. Homebrew ────────────────────────────────────
if have brew; then
  ok "Homebrew presente"
else
  log "Instalando Homebrew"
  run /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  eval "$(/opt/homebrew/bin/brew shellenv zsh)" 2>/dev/null || true
fi
eval "$(brew --prefix)/bin/brew shellenv zsh" 2>/dev/null || true

# ─────────────────────────── 1. Shell & prompt ──────────────────────────────
log "[1/8] Shell, prompt y CLI modernas"
brew_install starship zoxide atuin carapace eza bat fd ripgrep gh jq yt-dlp

# fzf — viene por brew (no por el binario del repo de junegunn)
brew_install fzf
brew_install fzf-tab 2>/dev/null || true   # si el tap no existe, lo instalamos abajo
# zsh plugins: se instalan por brew como kegs separados
brew_install zsh-autosuggestions zsh-syntax-highlighting

# ─────────────────────────── 2. Nerd Font ───────────────────────────────────
log "[2/8] Fuentes Nerd (sketchybar/icons y nvim)"
brew_cask_install font-hack-nerd-font font-jetbrains-mono-nerd-font

# ─────────────────────────── 3. Neovim + lenguaje deps ──────────────────────
log "[3/8] Neovim y toolchain para LSP/Mason"
brew_install neovim node python@3 go rust delve stylua
# Java (SDKMAN lo gestiona, pero jdtls necesita un JDK en PATH; cask es lo más simple)
brew_cask_install temurin

# SDKMAN (gestor de versiones Java)
if [[ ! -d "$HOME/.sdkman" ]]; then
  log "Instalando SDKMAN"
  run curl -fsSL "https://get.sdkman.io" \| run bash
else
  ok "SDKMAN presente"
fi

# NVM (gestor de versiones Node)
if [[ ! -d "$HOME/.nvm" ]]; then
  log "Instalando NVM"
  run git clone https://github.com/nvm-sh/nvm.git "$HOME/.nvm"
  run git -C "$HOME/.nvm" checkout "$(git -C "$HOME/.nvm" describe --tags --abbrev=0)"
else
  ok "NVM presente"
fi

# jbang (para Java tooling moderno — alias j!=jbang en .zshrc)
brew_install jbang

# ─────────────────────────── 4. Tmux ────────────────────────────────────────
log "[4/8] Tmux + TPM (plugin manager)"
brew_install tmux
TPM_DIR="$HOME/.config/tmux/plugins/tpm"
if [[ ! -d "$TPM_DIR" ]]; then
  log "Clonando TPM"
  run git clone https://github.com/tmux-plugins/tpm "$TPM_DIR"
else
  ok "TPM presente"
fi
# TPM instala el resto de plugins la primera vez que abres tmux y pulsas prefix + I.

# ─────────────────────────── 5. Window manager: yabai + skhd ─────────────────
log "[5/8] Window manager (yabai + skhd)"
brew_install jq skhd
brew_cask_install yabai
# sketchybar (barra de estado)
brew_cask_install sketchybar

# yabai necesita SIP parcialmente deshabilitado para espacio de trabajo y foco
# completo. NO lo deshabilitamos automáticamente: instrucciones al final.

# ─────────────────────────── 6. Kanata (remapeo de teclado) ──────────────────
log "[6/8] Kanata (remapeo de teclado a nivel kernel)"
# La config usa una build de Rust desde ~/.cargo/bin/kanata (ver alias kanata-start).
# Compilamos con cargo en lugar de usar cask para tener el bin en la ruta esperada.
if have cargo; then
  ok "cargo presente"
else
  brew_install rustup-init
  run rustup-init -y --no-modify-path --profile minimal
  source "$HOME/.cargo/env" 2>/dev/null || true
fi
if [[ ! -x "$HOME/.cargo/bin/kanata" ]]; then
  log "Compilando kanata (lleva un par de minutos)"
  run cargo install kanata --features cmd
else
  ok "kanata presente en ~/.cargo/bin/kanata"
fi

# ─────────────────────────── 7. Karabiner-Elements ───────────────────────────
log "[7/8] Karabiner-Elements"
brew_cask_install karabiner-elements

# ─────────────────────────── 8. opencode ────────────────────────────────────
log "[8/8] opencode (CLI de coding agent)"
if have opencode; then
  ok "opencode presente"
else
  log "Instalando opencode en ~/.opencode/bin"
  if $CHECK_ONLY; then
    printf '  would run: install script from opencode.ai\n'
  else
    curl -fsSL https://opencode.ai/install | bash || warn "No se pudo instalar opencode automáticamente; revisa https://opencode.ai"
  fi
fi

# ─────────────────────────── Post-instalación ───────────────────────────────
echo
log "────────────────────────────────────────────────────────────────"
log " ✓ Instalación de dependencias completada"
log "────────────────────────────────────────────────────────────────"
if $CHECK_ONLY; then
  echo "  (modo --check: nada fue modificado)"
  exit 0
fi

cat <<'EOF'

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
 PASOS MANUALES RESTANTES
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1. Aplicar los dotfiles con GNU Stow:

     cd ~/personal
     brew install stow            # si no lo tienes
     stow -t "$HOME" dotfiles

   Si hay conflictos porque ya existen archivos en $HOME, usa adopción:
     stow --adopt -t "$HOME" dotfiles
     git -C ~/personal/dotfiles diff   # revisa lo que se adoptó

2. Reiniciar el shell o:
     exec zsh

3. Neovim — abrir y dejar que lazy.nvim + Mason instalen plugins y LSPs:
     nvim
     # dentro: :MasonInstall java-test java-debug-extension
     # (jdtls se instala solo la primera vez)

4. Tmux — abrir y pulsar  prefix + I  (Ctrl-a I) para que TPM baje los plugins.

5. yabai — para funciones avanzadas necesitas deshabilitar parcialmente SIP.
   Reinicia en modo recuperación y ejecuta:
     csrutil enable --without fs-binding-only --without debug --without nvram
   Más info: https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection

6. kanata — necesita permisos Input Monitoring y ejecutarse como root:
     sudo ~/.cargo/bin/kanata --cfg ~/.config/kanata/config.kbd
   (o usa los alias kanata-start / kanata-restart del .zshrc)

7. Karabiner-Elements — abre la app una vez para conceder permisos, luego
   tu config en ~/.config/karabiner/karabiner.json se aplicará sola.

8. skhd y yabai — arranca los servicios:
     brew services start skhd
     brew services start yabai

EOF