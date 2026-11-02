# shellcheck shell=sh
# 00-env.sh — variables d'environnement et helpers PATH.
# POSIX sh : sourcé par ~/.profile ET ~/.bashrc, tout doit être idempotent.

# path_prepend / path_append DIR : ajoute DIR au PATH s'il existe et n'y est pas déjà
path_prepend() {
  [ -d "$1" ] || return 0
  case ":$PATH:" in *":$1:"*) ;; *) PATH="$1:$PATH" ;; esac
}
path_append() {
  [ -d "$1" ] || return 0
  case ":$PATH:" in *":$1:"*) ;; *) PATH="$PATH:$1" ;; esac
}

export XDG_CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"
export XDG_CACHE_HOME="${XDG_CACHE_HOME:-$HOME/.cache}"
export XDG_DATA_HOME="${XDG_DATA_HOME:-$HOME/.local/share}"

export EDITOR=nano
export VISUAL=nano
export LESS="-R -F -X"

path_prepend "$HOME/.local/bin"
path_prepend "$HOME/bin"
path_append "$DOTFILES_DIR/bin"
export PATH
