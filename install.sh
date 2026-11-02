#!/usr/bin/env bash
# install.sh — crée les liens symboliques du dépôt vers $HOME.
# Idempotent : relançable à volonté. Un fichier réel existant est déplacé dans
# ~/.dotfiles-backup/<horodatage>/ avant d'être remplacé par un lien ; rien
# n'est jamais supprimé.
#
# Usage : ./install.sh [--dry-run] [--help]
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles-backup/$(date +%Y%m%d-%H%M%S)"
DRY_RUN=0

# Table des liens : "source relative au dépôt:cible relative à $HOME"
LINKS=(
  "bash/bashrc:.bashrc"
  "bash/profile:.profile"
  "bash/inputrc:.inputrc"
  "git/gitconfig:.gitconfig"
  "git/ignore:.config/git/ignore"
  "starship/starship.toml:.config/starship.toml"
  "gh/config.yml:.config/gh/config.yml"
  "htop/htoprc:.config/htop/htoprc"
)
# Liens conditionnés à la présence d'une commande : "commande:source:cible"
OPTIONAL_LINKS=(
  "delta:git/delta.gitconfig:.config/git/delta"
)

usage() { sed -n '2,7s/^# \{0,1\}//p' "$0"; exit "${1:-0}"; }
info() { printf '  %-8s %s\n' "$1" "$2"; }
run() {
  if (( DRY_RUN )); then printf '  [dry-run] %s\n' "$*"; else "$@"; fi
}

# link SRC DST : crée $HOME/DST -> $DOTFILES_DIR/SRC
link() {
  local src="$DOTFILES_DIR/$1" dst="$HOME/$2"
  if [[ ! -e "$src" ]]; then
    info "ERREUR" "source absente : $src"
    return 1
  fi
  if [[ -L "$dst" && "$(readlink -f "$dst")" == "$(readlink -f "$src")" ]]; then
    info "ok" "$dst"
    return 0
  fi
  if [[ -e "$dst" || -L "$dst" ]]; then
    run mkdir -p "$BACKUP_DIR/$(dirname "$2")"
    run mv "$dst" "$BACKUP_DIR/$2"
    info "backup" "$dst -> $BACKUP_DIR/$2"
  fi
  run mkdir -p "$(dirname "$dst")"
  run ln -s "$src" "$dst"
  info "lien" "$dst -> $src"
}

main() {
  while (($#)); do
    case $1 in
      --dry-run) DRY_RUN=1 ;;
      -h|--help) usage ;;
      *) printf 'option inconnue : %s\n' "$1" >&2; usage 1 ;;
    esac
    shift
  done

  (( DRY_RUN )) && echo "Mode simulation : aucune modification."
  echo "Dépôt : $DOTFILES_DIR"

  local entry rc=0
  for entry in "${LINKS[@]}"; do
    link "${entry%%:*}" "${entry#*:}" || rc=1
  done
  for entry in "${OPTIONAL_LINKS[@]}"; do
    local cmd="${entry%%:*}" rest="${entry#*:}"
    if command -v "$cmd" >/dev/null 2>&1; then
      link "${rest%%:*}" "${rest#*:}" || rc=1
    else
      info "ignore" "$HOME/${rest#*:} ($cmd non installé)"
    fi
  done

  # Hooks locaux non versionnés
  if [[ ! -e "$HOME/.bashrc.local" ]]; then
    run touch "$HOME/.bashrc.local"
    info "nouveau" "$HOME/.bashrc.local"
  fi

  [[ -d "$BACKUP_DIR" ]] && echo "Sauvegardes dans $BACKUP_DIR"
  echo "Terminé. Ouvrez un nouveau terminal (ou : exec bash -l)."
  return "$rc"
}

main "$@"
