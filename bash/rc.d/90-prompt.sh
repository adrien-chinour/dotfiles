# shellcheck shell=bash
# 90-prompt.sh — prompt Starship (config : starship/starship.toml).
# Repli sur le PS1 Ubuntu si starship n'est pas installé.
#
# Dans les terminaux VTE (ddterm, GNOME Terminal…), Ubuntu charge
# /etc/profile.d/vte-2.91.sh qui entoure PS1 de marqueurs OSC 133 invisibles
# (D = code de retour, A = début du prompt, B = fin du prompt) et met C (début
# de la sortie) dans PS0. Le terminal s'en sert pour naviguer entre les prompts.
# Comme PS1 est réécrit ici (par starship à chaque prompt, ou par le repli),
# ces marqueurs seraient perdus : on les remet nous-mêmes.

_prompt_osc133=0
[[ ${PS1-} == *']133;'* ]] && _prompt_osc133=1

if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
  if (( _prompt_osc133 )); then
    # Exécuté après starship_precmd (qui vient de régler PS1 et STARSHIP_CMD_STATUS)
    __prompt_osc133() {
      PS1='\[\e]133;D;'"${STARSHIP_CMD_STATUS:-0}"'\e\\\e]133;A\e\\\]'"$PS1"'\[\e]133;B\e\\\]'
    }
    [[ "${PROMPT_COMMAND[*]}" == *__prompt_osc133* ]] || PROMPT_COMMAND+=(__prompt_osc133)
  fi
else
  # shellcheck disable=SC2154  # debian_chroot : variable Debian optionnelle
  PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '
  # shellcheck disable=SC2016  # $? est développé par bash à l'affichage du prompt
  (( _prompt_osc133 )) && PS1='\[\e]133;D;$?\e\\\e]133;A\e\\\]'"$PS1"'\[\e]133;B\e\\\]'
fi
unset _prompt_osc133
