# shellcheck shell=bash
# 30-aliases.sh — alias

# Listing : eza si présent, sinon ls
if command -v eza >/dev/null 2>&1; then
  alias ls='eza --group-directories-first'
  alias ll='eza -l --git --group-directories-first'
  alias la='eza -la --git --group-directories-first'
  alias lt='eza --tree --level=2 --group-directories-first'
else
  alias ls='ls --color=auto'
  alias ll='ls -alF'
  alias la='ls -A'
fi
alias l='ls'

# Corbeille plutôt que suppression (`command rm` pour le vrai rm)
alias rm='gio trash'

# Divers
alias reload='source ~/.bashrc'
alias myip='curl -4 -fsS https://ifconfig.me && echo'
alias port='ss -lntp'
alias dev='cd ~/code'
command -v batcat >/dev/null 2>&1 && alias bat='batcat'
alias pbcopy='setclip'
alias pbpaste='getclip'

# Docker (compose v2)
alias doco='docker compose'
alias dcu='docker compose up -d'
alias dcd='docker compose down'
alias dcl='docker compose logs -f'
alias dps='docker ps'
alias dkc='docker container'
alias dki='docker image'
alias dkv='docker volume'
alias dkn='docker network'
alias dks='docker system'

# Git
alias gs='git status'
alias gl='git log --graph --decorate --oneline --all'
