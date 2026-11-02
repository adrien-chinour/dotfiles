# shellcheck shell=bash
# 40-functions.sh — fonctions utilitaires

# own [CHEMIN…] : reprend la propriété des fichiers (défaut : répertoire courant)
own() {
  sudo chown -R "$(id -u):$(id -g)" "${@:-.}"
}

# setclip / getclip : presse-papiers (wl-clipboard sous Wayland, sinon xclip)
setclip() {
  if [ -n "${WAYLAND_DISPLAY:-}" ] && command -v wl-copy >/dev/null 2>&1; then
    wl-copy
  else
    xclip -selection clipboard
  fi
}
getclip() {
  if [ -n "${WAYLAND_DISPLAY:-}" ] && command -v wl-paste >/dev/null 2>&1; then
    wl-paste
  else
    xclip -selection clipboard -o
  fi
}

# gitignore node python … : génère un .gitignore (ex-gitignore.io)
gitignore() {
  local IFS=,
  curl -fsSL "https://www.toptal.com/developers/gitignore/api/$*"
}

# git-prune-gone : supprime les branches locales dont la branche distante a disparu
git-prune-gone() {
  git fetch -p && git branch -vv | awk '/: (gone|disparue)\]/ {print $1}' | xargs -r git branch -D
}

# mkcd DIR : crée le répertoire et s'y place
mkcd() {
  mkdir -p "$1" && cd "$1" || return
}
