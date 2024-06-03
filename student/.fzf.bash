# Setup fzf
# ---------
if [[ ! "$PATH" == */home/student/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/student/.fzf/bin"
fi

eval "$(fzf --bash)"
