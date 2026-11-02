# shellcheck shell=bash
# 90-prompt.sh — prompt Starship (config : starship/starship.toml).
# Repli sur le PS1 Ubuntu si starship n'est pas installé.

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
else
  # shellcheck disable=SC2154  # debian_chroot : variable Debian optionnelle
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
fi
