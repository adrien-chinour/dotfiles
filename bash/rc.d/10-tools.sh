# shellcheck shell=sh
# 10-tools.sh — chaînes d'outils (Go, Rust, Deno, Bun, pnpm, Node/nvm, Flutter).
# POSIX sh. Chaque bloc est conditionné à la présence du répertoire : rien ne
# casse sur une machine où l'outil est absent.

# Go : installation officielle dans /usr/local/go (GOROOT est déduit par go)
path_append /usr/local/go/bin
export GOPATH="${GOPATH:-$HOME/go}"
path_append "$GOPATH/bin"

# Rust (rustup), Deno, Bun : remplace `. ~/.cargo/env` et `. ~/.deno/env`
path_prepend "$HOME/.cargo/bin"
path_prepend "$HOME/.deno/bin"
export BUN_INSTALL="$HOME/.bun"
path_prepend "$BUN_INSTALL/bin"

# pnpm
export PNPM_HOME="$XDG_DATA_HOME/pnpm"
path_prepend "$PNPM_HOME"

# Node via nvm, chargement paresseux : le bin de la version par défaut est mis
# au PATH directement (instantané) ; nvm lui-même (nvm.sh, ~150 ms) n'est
# chargé qu'au premier appel de la commande `nvm`.
export NVM_DIR="$HOME/.nvm"
if [ -d "$NVM_DIR" ]; then
  _nvm_default="$(cat "$NVM_DIR/alias/default" 2>/dev/null)"
  if [ -n "$_nvm_default" ]; then
    # shellcheck disable=SC2012  # ls trié par version, chemins sans espaces
    _nvm_bin="$(ls -d "$NVM_DIR/versions/node/v${_nvm_default#v}"*/bin 2>/dev/null | sort -V | tail -n 1)"
    [ -n "$_nvm_bin" ] && path_prepend "$_nvm_bin"
  fi
  unset _nvm_default _nvm_bin
  nvm() {
    unset -f nvm
    # shellcheck source=/dev/null
    . "$NVM_DIR/nvm.sh"
    # shellcheck source=/dev/null
    [ -s "$NVM_DIR/bash_completion" ] && . "$NVM_DIR/bash_completion"
    nvm "$@"
  }
fi

# Flutter / Dart
path_append "$HOME/code/tools/flutter/bin"

# cup (github.com/adrien-chinour/cup) : racine des projets docker compose
export CUPDIR="$HOME/code"

export PATH
