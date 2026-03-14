# Point to OMZ installation
export ZSH="$HOME/.oh-my-zsh"

# Set the update mode and frequency
zstyle ':omz:update' mode auto
zstyle ':omz:update' frequency 14

# Disable themes (Starship will be used)
ZSH_THEME=""

# Optional: load specific plugins
plugins=(
    git 
    sudo 
    zsh-autosuggestions 
    zsh-syntax-highlighting 
    web-search 
    copyfile 
    copybuffer 
    dirhistory 
    python 
    history 
    macos 
    copypath  
    emoji 
    encode64 
    colored-man-pages 
    aliases
)

# Wrapper for the history command to include date timestamps
HIST_STAMPS="dd.mm.yyyy"

# Load OMZ
source "$ZSH/oh-my-zsh.sh"