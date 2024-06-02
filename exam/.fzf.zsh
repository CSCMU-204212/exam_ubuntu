# Setup fzf
# ---------
if [[ ! "$PATH" == */home/exam/.fzf/bin* ]]; then
  PATH="${PATH:+${PATH}:}/home/exam/.fzf/bin"
fi

source <(fzf --zsh)
