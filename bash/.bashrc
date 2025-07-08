#
# ~/.bashrc
#

# Start ssh-agent
if [ -z "$SSH_AUTH_SOCK" ]; then
  eval $(keychain --eval github)
  eval $(keychain --eval gitea)
fi

# Start Tmux by default
if command -v tmux &> /dev/null && [ -n "$PS1" ] && [[ ! "$TERM" =~ screen ]] && [[ ! "$TERM" =~ tmux ]] && [ -z "$TMUX" ]; then
  exec tmux
fi


[[ -f ~/.bash.alias ]] && . ~/.bash.alias

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='[\u@\h \W]\$ '

# Expo Android Stuff
export ANDROID_HOME=$HOME/Android/Sdk
export PATH=$PATH:$ANDROID_HOME/emulator
export PATH=$PATH:$ANDROID_HOME/platform-tools

# Export Go Bin
[ -n "$(go env GOBIN)" ] && export PATH="$(go env GOBIN):${PATH}"
[ -n "$(go env GOPATH)" ] && export PATH="$(go env GOPATH)/bin:${PATH}"
. "$HOME/.cargo/env"

# Created by `pipx` on 2025-06-21 11:35:59
export PATH="$PATH:/home/joshua/.local/bin"
