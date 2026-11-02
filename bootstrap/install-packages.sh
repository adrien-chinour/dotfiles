#!/usr/bin/env bash
# install-packages.sh — installe les outils listés dans bootstrap/*.txt.
# Non lancé par install.sh (sudo + réseau). Chaque section est idempotente.
#
# Usage : ./install-packages.sh [--only apt,snap,node,rust,go,github] [--dry-run] [--help]
set -euo pipefail

HERE="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
SECTIONS="apt,snap,node,rust,go,github"
DRY_RUN=0
NVM_VERSION=v0.40.3
NODE_VERSION=24

usage() { sed -n '2,5s/^# \{0,1\}//p' "$0"; exit "${1:-0}"; }
log() { printf '\n==> %s\n' "$*"; }
run() {
  if (( DRY_RUN )); then printf '  [dry-run] %s\n' "$*"; else "$@"; fi
}
want() { [[ ",$SECTIONS," == *",$1,"* ]]; }
# pkg_list FICHIER : lignes utiles (sans commentaires ni lignes vides)
pkg_list() { grep -vE '^\s*(#|$)' "$HERE/$1"; }

do_apt() {
  log "apt"
  local pkgs=() missing=() p
  while read -r p; do
    if LC_ALL=C apt-cache policy "$p" 2>/dev/null | grep -E '^[[:space:]]+Candidate: [^(]' >/dev/null; then
      pkgs+=("$p")
    else
      missing+=("$p")
    fi
  done < <(pkg_list apt.txt)
  (( ${#missing[@]} )) && echo "Ignorés (aucun candidat, dépôt absent ?) : ${missing[*]}"
  (( ${#pkgs[@]} )) || return 0
  run sudo apt-get update
  run sudo apt-get install -y --no-install-recommends "${pkgs[@]}"
  if command -v tldr >/dev/null 2>&1; then run tldr --update; fi
}

do_snap() {
  log "snap"
  command -v snap >/dev/null 2>&1 || { echo "snap absent, section ignorée"; return 0; }
  local name flags
  while read -r name flags; do
    if snap list "$name" >/dev/null 2>&1; then
      echo "  ok      $name"
    else
      # shellcheck disable=SC2086  # flags volontairement découpés (--classic…)
      run sudo snap install "$name" $flags
    fi
  done < <(pkg_list snap.txt)
}

do_node() {
  log "node (nvm $NVM_VERSION, node $NODE_VERSION)"
  export NVM_DIR="$HOME/.nvm"
  if [[ ! -s "$NVM_DIR/nvm.sh" ]]; then
    # PROFILE=/dev/null : l'installeur n'écrit pas dans ~/.bashrc (géré par rc.d/10-tools.sh)
    run bash -c "curl -fsSL https://raw.githubusercontent.com/nvm-sh/nvm/$NVM_VERSION/install.sh | PROFILE=/dev/null bash"
  fi
  (( DRY_RUN )) && return 0
  # shellcheck source=/dev/null
  . "$NVM_DIR/nvm.sh"
  nvm install "$NODE_VERSION"
  nvm alias default "$NODE_VERSION"
  local pkg
  while read -r pkg; do
    npm ls -g "$pkg" >/dev/null 2>&1 || npm install -g "$pkg"
  done < <(pkg_list npm-global.txt)
}

do_rust() {
  log "rust"
  if command -v rustup >/dev/null 2>&1; then
    echo "  ok      rustup"
    return 0
  fi
  # --no-modify-path : le PATH est géré par rc.d/10-tools.sh
  run bash -c "curl -fsSf https://sh.rustup.rs | sh -s -- -y --no-modify-path"
}

do_go() {
  log "go"
  if ! command -v go >/dev/null 2>&1; then
    echo "Go absent : installer l'archive officielle dans /usr/local/go (https://go.dev/dl)"
    return 0
  fi
  local mod
  while read -r mod; do
    run go install "$mod"
  done < <(pkg_list go.txt)
}

do_github() {
  log "github releases"
  command -v gh >/dev/null 2>&1 || { echo "gh absent, section ignorée"; return 0; }
  local repo pattern bin tmp asset
  while IFS='|' read -r repo pattern bin; do
    if command -v "$bin" >/dev/null 2>&1; then
      echo "  ok      $bin"
      continue
    fi
    if (( DRY_RUN )); then
      printf '  [dry-run] gh release download --repo %s --pattern %s → ~/.local/bin/%s\n' "$repo" "$pattern" "$bin"
      continue
    fi
    tmp="$(mktemp -d)"
    gh release download --repo "$repo" --pattern "$pattern" --dir "$tmp"
    asset="$(find "$tmp" -type f | head -n 1)"
    case "$asset" in
      *.tar.gz|*.tgz) tar -xzf "$asset" -C "$tmp" && asset="$(find "$tmp" -type f -name "$bin" | head -n 1)" ;;
      *.zip) unzip -q "$asset" -d "$tmp" && asset="$(find "$tmp" -type f -name "$bin" | head -n 1)" ;;
    esac
    [[ -n "$asset" ]] || { echo "  ERREUR  $bin : binaire introuvable dans l'asset"; command rm -rf "$tmp"; continue; }
    mkdir -p "$HOME/.local/bin"
    install -m 755 "$asset" "$HOME/.local/bin/$bin"
    command rm -rf "$tmp"
    echo "  install $HOME/.local/bin/$bin"
  done < <(pkg_list github-releases.txt)
}

main() {
  while (($#)); do
    case $1 in
      --only) SECTIONS="$2"; shift ;;
      --only=*) SECTIONS="${1#--only=}" ;;
      --dry-run) DRY_RUN=1 ;;
      -h|--help) usage ;;
      *) printf 'option inconnue : %s\n' "$1" >&2; usage 1 ;;
    esac
    shift
  done
  (( DRY_RUN )) && echo "Mode simulation : aucune modification."
  local s
  for s in apt snap node rust go github; do
    want "$s" && "do_$s"
  done
  echo
  echo "Terminé."
}

main "$@"
