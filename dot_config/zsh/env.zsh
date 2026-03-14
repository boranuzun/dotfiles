export PATH=/opt/homebrew/bin:$PATH
export GPG_TTY=$(tty)
export EDITOR=nvim
export LANG=fr_CH.UTF-8
export LC_ALL=fr_CH.UTF-8

# Bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# Starship
export STARSHIP_CONFIG=~/.config/starship/starship.toml
eval "$(starship init zsh)"

# Eza
export EZA_CONFIG_DIR=~/.config/eza

# Created by `pipx` on 2025-11-09 23:22:44
export PATH="$PATH:/Users/boran/.local/bin"

# Added by Antigravity
export PATH="/Users/boran/.antigravity/antigravity/bin:$PATH"

# Load zoxide
eval "$(zoxide init zsh)"

# Load atuin
eval "$(atuin init zsh)"
