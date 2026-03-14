# System
alias shutdown='sudo shutdown now'
alias reboot='sudo reboot'
alias c='clear'
alias e='exit'

alias rr='source ~/.zshrc'

# Folders
alias doc="$HOME/Documents"
alias dow="$HOME/Downloads"

alias ff='fastfetch'

# update all
alias sysup='brew upgrade; mas upgrade; omz update'
alias buc='brew upgrade --cask'

# launch pentaho data integration
alias spoon='/Applications/data-integration/spoon.sh'

# open quicklook
alias ql='qlmanage -p'

# create a new private repo on GitHub and push the current directory to it
alias gh-create='gh repo create --private --source=. --remote=origin && git push -u --all && gh browse'

# ---- EZA (better ls) ----
alias ls='eza --color=always --icons=always --long --header --git --time-style=relative --group-directories-first'
alias lt="eza --tree --level=2 --long --icons --git"
alias ltree="eza --tree --level=2  --icons --git"

# ---- Zoxide (better cd) ----
alias cd=z

# IntelliJ IDEA Ultimate alias
alias idea='/Users/boran/Applications/IntelliJ\ IDEA\ Ultimate.app/Contents/MacOS/idea'

# FZF history search
alias fh='fc -l 1 | tac | fzf --no-sort --border'

# OpenCode
alias opc="opencode"

# Chezmoi
alias cm="chezmoi"
