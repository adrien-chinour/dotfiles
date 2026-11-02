# shellcheck shell=bash
# 50-completion.sh — complétions bash.
# docker, gh, git, make, gcloud sont fournies par leurs paquets dans
# /usr/share/bash-completion. Les autres sont générées une fois et mises en
# cache dans ~/.cache/bash-completion/ (completion-refresh pour régénérer).

if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    # shellcheck source=/dev/null
    . /usr/share/bash-completion/bash_completion
  fi
fi

# _cache_completion NOM COMMANDE… : COMMANDE imprime le script de complétion de NOM
_cache_completion() {
  local name="$1" file="$XDG_CACHE_HOME/bash-completion/$1.bash"
  shift
  command -v "$name" >/dev/null 2>&1 || return 0
  if [ ! -s "$file" ]; then
    mkdir -p "${file%/*}"
    "$@" >"$file" 2>/dev/null || { command rm -f "$file"; return 0; }
  fi
  # shellcheck source=/dev/null
  . "$file"
}

_cache_completion pnpm pnpm completion bash
_cache_completion deno deno completions bash
_cache_completion composer composer completion bash
_cache_completion symfony symfony self:completion bash
command -v terraform >/dev/null 2>&1 && complete -C terraform terraform
command -v aws_completer >/dev/null 2>&1 && complete -C aws_completer aws
# nvm : sa complétion est chargée par la fonction paresseuse nvm() (10-tools.sh)

completion-refresh() {
  command rm -rf "$XDG_CACHE_HOME/bash-completion"
  # shellcheck source=/dev/null
  source "$HOME/.bashrc"
}
