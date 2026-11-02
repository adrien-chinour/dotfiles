# shellcheck shell=bash
# 20-shell.sh — options du shell interactif (historique, shopt, couleurs, less)

HISTSIZE=100000
HISTFILESIZE=200000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT='%F %T  '
HISTIGNORE='ls:ll:la:cd:pwd:exit:clear:history'
shopt -s histappend checkwinsize globstar cmdhist no_empty_cmd_completion
shopt -s autocd cdspell dirspell
# Écrit l'historique après chaque commande : partagé entre terminaux ouverts
PROMPT_COMMAND="history -a${PROMPT_COMMAND:+;$PROMPT_COMMAND}"

# less : fichiers non texte lisibles (archives, pdf…)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# Couleurs
if [ -x /usr/bin/dircolors ]; then
  eval "$(dircolors -b)"
  alias grep='grep --color=auto'
fi
