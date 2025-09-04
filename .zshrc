#
# .zshrc is sourced in interactive shells.
# It should contain commands to set up aliases,
# functions, options, key bindings, etc.
#

fpath=(~/.zsh/completions $fpath)
autoload -Uz compinit && compinit

#allow tab completion in the middle of a word
setopt COMPLETE_IN_WORD

## keep background processes at full speed
#setopt NOBGNICE
## restart running processes on exit
#setopt HUP

## history
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
#setopt APPEND_HISTORY
## for sharing history between zsh processes
#setopt INC_APPEND_HISTORY
#setopt SHARE_HISTORY
setopt EXTENDED_HISTORY
setopt inc_append_history_time
setopt HIST_IGNORE_SPACE

## never ever beep ever
#setopt NO_BEEP

## automatically decide when to page a list of completions
#LISTMAX=0

## disable mail checking
MAILCHECK=0

## Coloured prompt
autoload -U colors
colors
PS1="%{$fg[green]%}%n%{$reset_color%}@%{$fg[blue]%}%m %{$fg[yellow]%}%(5~|%-1~/.../%3~|%4~) %{$reset_color%}$ "

export VISUAL=/usr/bin/nvim

# local key bindings
bindkey "" beginning-of-line
bindkey "^[[H" beginning-of-line
bindkey "" end-of-line
bindkey "^[[F" end-of-line
bindkey "\e." insert-last-word
bindkey "^[[1;5D" backward-word
bindkey "^[[1;5C" forward-word
bindkey "^W" backward-kill-word
bindkey "\ed" kill-word
bindkey "^K" kill-line
bindkey "^[[3~" delete-char

alias vim="/usr/bin/nvim"

PATH=$PATH:~/bin:~/.local/bin:$(go env GOPATH)/bin:~/.cargo.bin

# autosuggestions
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# use skim to browse history (and a couple of other things)
source /usr/share/skim/shell/key-bindings.zsh
skim-history-widget() {
  local selected num
  setopt localoptions noglobsubst noposixbuiltins pipefail no_aliases 2> /dev/null
  local awk_filter='{ cmd=$0; sub(/^\s*[0-9]+\**\s+/, "", cmd); if (!seen[cmd]++) print $0 }'  # filter out duplicates
  local n=1 fc_opts=''
  if [[ -o extended_history ]]; then
    awk_filter='
{
  ts = int($2)
  delta = systime() - ts
  delta_days = int(delta / 86400)
  if (delta < 0) { $2="+" (-delta_days) "d" }
  else if (delta_days < 1 && delta < 72000) { $2=strftime("%H:%M", ts) }
  else if (delta_days == 0) { $2="1d" }
  else { $2=delta_days "d" }
  line=$0; $1=""; $2=""
  if (!seen[$0]++) print line
}'
    fc_opts='-i'
    n=2
  fi
  selected=( $(fc -rl $fc_opts -t '%s' 1 | sed -E "s/^ *//" | awk "$awk_filter" |
    SKIM_DEFAULT_OPTIONS="--height ${SKIM_TMUX_HEIGHT:-40%} $SKIM_DEFAULT_OPTIONS --with-nth $n.. --bind=ctrl-r:toggle-sort $SKIM_CTRL_R_OPTS --query=${(qqq)LBUFFER} --no-multi" $(__skimcmd)) )
  local ret=$?
  if [ -n "$selected" ]; then
    num=$selected[1]
    if [ -n "$num" ]; then
      zle vi-fetch-history -n $num
    fi
  fi
  zle reset-prompt
  return $ret
}
zle     -N   skim-history-widget
bindkey '^R' skim-history-widget

# autocomplete
for f in ~/.zsh/completions/*; do
  source $f
done

source /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

eval "$(starship init zsh)"
