# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt autocd
bindkey -v
# End of lines configured by zsh-newuser-install
# The following lines were added by compinstall
zstyle :compinstall filename '/home/dan/.zshrc'

autoload -Uz compinit && compinit
# End of lines added by compinstall

# Some parameters taken from
# https://github.com/BreadOnPenguins/dots/blob/master/.config/zsh/.zshrc

# Enable colors
autoload -U colors && colors

# Enable auto-completion for lower and upper case
#zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}'
setopt auto_menu menu_complete
setopt no_case_glob no_case_match

# Colorize completion options 
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS} ma=0\;33
#setopt globdots

# set up prompt
NEWLINE=$'\n'
PROMPT="${NEWLINE}%K{#2E3440}%F{#E5E9F0}$(date +%_I:%M%P) %K{#3b4252}%F{#ECEFF4} %n %K{#4c566a} %~ %f%k ❯ " # nord theme
#echo -e "${NEWLINE}\x1b[38;5;137m\x1b[48;5;0m it's$(print -P '%D{%_I:%M%P}\n') \x1b[38;5;180m\x1b[48;5;0m $(uptime -p | cut -c 4-) \x1b[38;5;223m\x1b[48;5;0m $(uname -r) \033[0m"

export EDITOR="nvim"

# Enable history search via ctrl+r
#bindkey "^R" history-incremental-pattern-search-backward
# Emacs mode - enable history, beginning of line, etc.
bindkey -e
