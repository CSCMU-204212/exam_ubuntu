# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
  *i*) ;;
    *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=-1
HISTFILESIZE=20000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
  debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
  xterm|xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
  if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
	# We have color support; assume it's compliant with Ecma-48
	# (ISO/IEC-6429). (Lack of such support is extremely rare, and such
	# a case would tend to support setf rather than setaf.)
	color_prompt=yes
  else
	color_prompt=
  fi
fi

emoji_list=(🐻 🐱 🦁 🦄 🦊 🦝 🐻‍❄️ 🐨 🐼 🐋 🐬 🌸 💮 🌺 🌻 🌼 🍀 🍁 🍇 🍉 🍊 🍋 🍍 🥭 🍎 🍐 🍒 🍓 🥝)


index=$(($RANDOM % ${#emoji_list[@]}))

emoji=${emoji_list[$index]}

if [ "$TERM" = "dumb" ]; then
  PS1='${debian_chroot:+($debian_chroot)}\u@\h \w \$ '
elif [ "$color_prompt" = yes ]; then
  if [[ ${EUID} == 0 ]] ; then
    # root
    PS1=' ${debian_chroot:+($debian_chroot)}\[\033[01;31m\]\h\[\033[01;34m\] \W \$\[\033[00m\] '
  elif [ "$TERM" = "eterm-color" ]; then
    PS1='${debian_chroot:+($debian_chroot)}\[\033[00;32m\]\u\[\033[00;35m\]$emoji\[\033[00m\]\[\033[00;32m\]\h\[\033[00m\] \[\033[00;33m\]\w\[\033[00m\] \[\033[01;31m\]\n\$\[\033[00m\] '
  else
    PS1='${debian_chroot:+($debian_chroot)}\[\e]0;\u $emoji \h: \w\a\]\n\[\033[00;32m\]\u\[\033[00;35m\]$emoji\[\033[00m\]\[\033[00;32m\]\h\[\033[00m\] \[\033[00;33m\]\w\[\033[00m\] \[\033[01;31m\]\n\$\[\033[00m\] '
  fi
else
  PS1='${debian_chroot:+($debian_chroot)}\u@\h \w \$ '
fi

unset color_prompt force_color_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*)
  PS1="\[\e]0;${debian_chroot:+($debian_chroot)}\u@\h \w\a\]$PS1"
  ;;
*)
  ;;
esac

# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
  test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
  alias ls='ls --color=auto'
  alias dir='dir --color=auto'
  alias vdir='vdir --color=auto'

  alias grep='grep --color=auto'
  alias fgrep='fgrep --color=auto'
  alias egrep='egrep --color=auto'
fi

# colored GCC warnings and errors
#export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'

# some more ls aliases
# alias ll='ls -alF'
# alias la='ls -A'
# alias l='ls -CF'

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# START -- For Sublime Text & VSCODE on WSL

if [[ -x "$(command -v subl.exe)" ]]; then
  function sublime_wsl {
    path_arr=()
    for p in "$@"; do
      path_arr+=("$(wslpath -m "$p")")
    done
    "subl.exe" "${path_arr[@]}";
  }
  export -f sublime_wsl
  alias subl='sublime_wsl'
fi

if [[ -x "$(command -v /mnt/c/Program\ Files/Microsoft\ VS\ Code/Code.exe)" ]]; then
  function vscode_wsl {
    path_arr=()
    for p in "$@"; do
      path_arr+=("$(wslpath -m "$p")")
    done
    cmd.exe /c code "${path_arr[@]}"
  }
  export -f vscode_wsl
  alias code="vscode_wsl"
fi

# END -- For Sublime Text & VSCODE on WSL

if [[ -x "$(command -v kdiff3.exe)" ]]; then
  alias kdiff3="kdiff3.exe"
fi

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

alias emacs='/usr/bin/emacs -nw'

if [ -f ~/.bash_aliases ]; then
  . ~/.bash_aliases
fi



# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

if [ -x /usr/bin/mint-fortune ]; then
   /usr/bin/mint-fortune
fi


# added by Miniconda3 4.3.11 installer
# export PATH="/home/kk/miniconda3/bin:$PATH"


shopt -s histappend            # append to history, don't overwrite it
PROMPT_COMMAND="history -a; history -c; history -r; $PROMPT_COMMAND"

[ -f ~/.fzf.bash ] && source ~/.fzf.bash

[ -d "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"

shopt -s cdspell

# go binaries

if ! echo "$PATH" | grep -q "/usr/local/go/bin"; then
  export PATH="$PATH:/usr/local/go/bin"
fi


if ! echo "$PATH" | grep -q "$HOME/go/bin"; then
  export PATH="$PATH:"$HOME"/go/bin"
fi

# python
if ! echo "$PATH" | grep -q "$HOME/.local/bin"; then
  export PATH="$PATH:$HOME/.local/bin"
fi


# Check if a screen session named "emacs" exists, if not, start Emacs daemon in a new screen session
if ! pgrep -f "emacs --daemon --no-desktop" >/dev/null; then
  ('emacs' --daemon --no-desktop >/dev/null 2>&1)
fi

# Define function to start Emacs or Emacs client depending on whether the daemon is running
emacs_or_emacsclient() {
  if ! pgrep -f "emacs --daemon --no-desktop" >/dev/null; then
    ('emacs' --daemon --no-desktop >/dev/null 2>&1)
  fi
  echo "Connecting to daemon..."
  # Wait for Emacs daemon to start
  while true; do
    # Start Emacs client
    emacsclient -n -e "1" -u > /dev/null 2>&1
      # Check exit code, if not zero, sleep for 2 more minutes
    if [ $? -ne 0 ]; then
      echo "Waiting 5 more second for daemon to be ready..."
      sleep 5
    else
      break
    fi
  done
  emacsclient -nw -c "$@"
}

# Use the function to start Emacs or Emacs client
alias emacs='emacs_or_emacsclient'

## base16 theming comment this if you want
[[ -d "$HOME"/.config/tinted-shell ]] && BASE16_SHELL_SET_BACKGROUND=false bash "$HOME"/.config/tinted-shell/scripts/base16-default-dark.sh


# unsetting the suspend key to
# prevent hitting Ctrl+Z (Control + Z) unintentionally
stty susp ""
