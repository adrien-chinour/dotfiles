# shellcheck shell=sh
# 10-tools.sh — chaînes d'outils (Go, Rust, Deno, Bun, Node/pnpm via Vite+, Flutter).
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

# Node et pnpm via Vite+ (`vp`) : `bin` (vp, vpx, node) en tête du PATH,
# `fallback-bin` (npm, npx, pnpm, bun) en fin, comme ~/.config/vite-plus/env.
# Chaque shim lance la version déclarée par le projet courant (.node-version,
# devEngines, engines, .nvmrc), sinon celle de `vp env default`. Aucun script à
# sourcer : marche aussi en shell non interactif.
path_prepend "$XDG_DATA_HOME/vite-plus/bin"
path_append "$XDG_DATA_HOME/vite-plus/fallback-bin"

# Flutter / Dart
path_append "$HOME/code/tools/flutter/bin"

export PATH
