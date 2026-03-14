# dotfiles

Personal macOS dotfiles managed with [chezmoi](https://chezmoi.io). Bootstraps a fresh Mac from zero to fully configured in one command — Homebrew, packages, shell, tools, and encrypted secrets all included.

## Table of Contents

- [Key Features](#key-features)
- [Tech Stack](#tech-stack)
- [What Gets Managed](#what-gets-managed)
- [Prerequisites](#prerequisites)
- [Bootstrap a New Mac](#bootstrap-a-new-mac)
- [Architecture](#architecture)
- [Directory Structure](#directory-structure)
- [Encryption](#encryption)
- [Day-to-Day Usage](#day-to-day-usage)
- [Shell Setup](#shell-setup)
- [Installed Tools](#installed-tools)
- [Adding New Files](#adding-new-files)
- [Troubleshooting](#troubleshooting)

---

## Key Features

- **One-command bootstrap** — `chezmoi init --apply boranuzun` sets up a new Mac end-to-end
- **Age encryption** for secrets (git config, SSH config, GitHub hosts)
- **Templated configs** — `zprofile` adapts based on whether OrbStack or JetBrains Toolbox is installed
- **Auto-installs Homebrew** and all packages via `Brewfile` on first apply
- **Conventional commit template** enforced globally for all git repos

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| [chezmoi](https://chezmoi.io) | Dotfile manager |
| [age](https://age-encryption.org) | Secret encryption |
| [Homebrew](https://brew.sh) | Package manager |
| [Oh My Zsh](https://ohmyz.sh) | Zsh framework |
| [Starship](https://starship.rs) | Shell prompt |
| [Atuin](https://atuin.sh) | Shell history |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` |
| [eza](https://github.com/eza-community/eza) | Modern `ls` |
| [bat](https://github.com/sharkdp/bat) | Modern `cat` |
| [yazi](https://yazi-rs.github.io) | Terminal file manager |
| [Ghostty](https://ghostty.org) | Terminal emulator |

---

## What Gets Managed

| Path | chezmoi source | Notes |
|------|---------------|-------|
| `~/.zshrc` | `dot_zshrc` | Delegates to `~/.config/zsh/.zshrc` |
| `~/.zprofile` | `dot_zprofile.tmpl` | Templated (OrbStack / JetBrains) |
| `~/.config/zsh/` | `dot_config/zsh/` | All zsh config modules |
| `~/.config/git/` | `dot_config/git/` | Global ignore, commit template, encrypted gitconfig |
| `~/.config/gh/` | `dot_config/gh/` | GitHub CLI preferences and encrypted hosts |
| `~/.config/ghostty/` | `dot_config/ghostty/` | Terminal config, themes, icons |
| `~/.config/starship/` | `dot_config/starship/` | Prompt config |
| `~/.config/atuin/` | `dot_config/private_atuin/` | Shell history config |
| `~/.config/bat/` | `dot_config/bat/` | `cat` replacement config |
| `~/.config/eza/` | `dot_config/eza/` | `ls` replacement config |
| `~/.config/yazi/` | `dot_config/yazi/` | File manager config |
| `~/.config/fastfetch/` | `dot_config/fastfetch/` | System info display |
| `~/.config/btop/` | `dot_config/btop/` | Resource monitor config |
| `~/.ssh/config` | `private_dot_ssh/encrypted_config.age` | Encrypted SSH config |
| `~/Brewfile` (applied at source) | `Brewfile` | All Homebrew packages and casks |

**Not tracked** (excluded via `.chezmoiignore`):
- `~/.config/opencode/` — AI coding assistant (machine-specific)
- `~/.config/nvim/` — Neovim config (managed separately)
- `~/.config/op/` — 1Password CLI (machine-specific)

---

## Prerequisites

- **macOS** (Apple Silicon assumed; Homebrew path `/opt/homebrew`)
- **Internet access** for Homebrew and package installation
- **age key file** at `~/.config/chezmoi/key.txt` to decrypt secrets

  Retrieve your age key from 1Password before bootstrapping:
  ```bash
  # Store it somewhere safe first, e.g. 1Password "age key" note
  mkdir -p ~/.config/chezmoi
  # Paste your age private key into:
  nano ~/.config/chezmoi/key.txt
  chmod 600 ~/.config/chezmoi/key.txt
  ```

---

## Bootstrap a New Mac

### 1. Install chezmoi and apply dotfiles

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply boranuzun
```

This single command:
1. Downloads and installs chezmoi
2. Clones `github.com/boranuzun/dotfiles` to `~/.local/share/chezmoi`
3. Runs `run_once_before_10-install-homebrew.sh` — installs Homebrew if absent
4. Runs `run_once_before_20-install-packages.sh.tmpl` — runs `brew bundle` to install all packages from `Brewfile`
5. Prompts for configuration values (see below)
6. Applies all dotfiles to their target locations

### 2. Answer the setup prompts

chezmoi will ask four questions on first apply:

| Prompt | Description | Stored as |
|--------|-------------|-----------|
| `Email address` | Your git/personal email | `data.email` |
| `Full name` | Your full name | `data.name` |
| `Is OrbStack installed?` | Enables OrbStack shell integration in `~/.zprofile` | `data.hasOrbStack` |
| `Is JetBrains Toolbox installed?` | Adds JetBrains scripts to `$PATH` | `data.hasJetBrains` |

Answers are saved to `~/.config/chezmoi/chezmoi.toml` and will not be asked again.

### 3. Verify the setup

```bash
# Check shell is working
fastfetch

# Check git config was decrypted
git config --global user.email

# Check SSH config was decrypted
cat ~/.ssh/config
```

### 4. Post-bootstrap steps (manual)

These are not automated and must be done manually after bootstrapping:

- **1Password SSH agent** — Enable in 1Password settings → Developer → SSH Agent. The SSH config already has `IdentityAgent` pointing to it.
- **Oh My Zsh** — Install if not already present:
  ```bash
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
  ```
- **zsh-syntax-highlighting plugin** — Install manually:
  ```bash
  git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
    ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
  ```
- **Atuin sync** — Log in to sync shell history across machines:
  ```bash
  atuin login
  atuin sync
  ```
- **GitHub CLI auth** — Authenticate with GitHub:
  ```bash
  gh auth login
  ```

---

## Architecture

### How chezmoi Works

chezmoi stores a *source* copy of every dotfile in `~/.local/share/chezmoi/`. When you run `chezmoi apply`, it compares the source to the target (your home directory) and copies any changed files.

**chezmoi is NOT symlink-based** — it physically copies files. The source directory is the single source of truth.

### Naming Conventions

chezmoi uses filename prefixes/suffixes to control behavior:

| Prefix/suffix | Meaning |
|--------------|---------|
| `dot_` | Becomes `.` in target (e.g., `dot_zshrc` → `~/.zshrc`) |
| `private_` | Applies `0600` permissions in target |
| `.tmpl` suffix | Rendered as a Go template before applying |
| `.age` suffix | Decrypted with age before applying |
| `run_once_before_` | Shell script run once, before applying |
| `encrypted_` | Convention (not enforced) — file is age-encrypted |

### Template Variables

The following data variables are available in all `.tmpl` files:

| Variable | Type | Description |
|----------|------|-------------|
| `.email` | string | User's email address |
| `.name` | string | User's full name |
| `.hasOrbStack` | bool | Whether OrbStack is installed |
| `.hasJetBrains` | bool | Whether JetBrains Toolbox is installed |

Example usage in a template:
```toml
[user]
  email = "{{ .email }}"
  name = "{{ .name }}"
```

### Bootstrap Script Order

Scripts run in lexicographic order by filename, before files are applied:

1. `run_once_before_10-install-homebrew.sh` — Installs Homebrew
2. `run_once_before_20-install-packages.sh.tmpl` — Runs `brew bundle`

`run_once_` scripts only execute once per machine (chezmoi tracks them by content hash). To force re-run, delete the entry from `~/.local/share/chezmoi/.chezmoistate.boltdb`.

---

## Directory Structure

```
~/.local/share/chezmoi/
├── .chezmoi.toml.tmpl          # Config template (prompts, encryption settings)
├── .chezmoiignore              # Files excluded from management
├── Brewfile                    # All Homebrew packages and casks
├── dot_zshrc                   # → ~/.zshrc (delegates to ~/.config/zsh/.zshrc)
├── dot_zprofile.tmpl           # → ~/.zprofile (templated, OrbStack/JetBrains)
├── run_once_before_10-install-homebrew.sh
├── run_once_before_20-install-packages.sh.tmpl
├── dot_config/
│   ├── zsh/
│   │   ├── dot_zshrc           # → ~/.config/zsh/.zshrc (sources all modules)
│   │   ├── aliases.zsh         # Shell aliases
│   │   ├── env.zsh             # Environment variables and PATH
│   │   ├── fzf.zsh             # fzf + yazi shell integration
│   │   ├── history.zsh         # Zsh history settings
│   │   └── omz.zsh             # Oh My Zsh config and plugins
│   ├── git/
│   │   ├── encrypted_config.age  # → ~/.config/git/config (name, email, etc.)
│   │   ├── ignore              # → ~/.config/git/ignore (global gitignore)
│   │   └── template            # → ~/.config/git/template (commit message template)
│   ├── gh/
│   │   ├── private_config.yml              # → ~/.config/gh/config.yml (preferences)
│   │   └── encrypted_private_hosts.yml.age # → ~/.config/gh/hosts.yml (auth tokens)
│   ├── ghostty/
│   │   ├── config              # Terminal settings (font, theme, keybinds)
│   │   ├── icons/              # Custom app icon
│   │   └── themes/             # Custom color themes
│   ├── starship/
│   │   └── starship.toml       # Prompt configuration
│   ├── private_atuin/
│   │   └── private_config.toml # Shell history sync config
│   ├── bat/                    # bat (cat replacement) config
│   ├── eza/                    # eza (ls replacement) config
│   ├── yazi/
│   │   ├── yazi.toml           # File manager config
│   │   ├── keymaps.toml        # Custom keybindings
│   │   ├── theme.toml          # Color theme
│   │   ├── package.toml        # yazi plugins
│   │   └── flavors/            # Theme flavors
│   ├── fastfetch/              # System info display config
│   └── btop/                   # Resource monitor config
└── private_dot_ssh/
    └── encrypted_config.age    # → ~/.ssh/config (SSH host definitions)
```

---

## Encryption

Secrets are encrypted with [age](https://age-encryption.org) before being committed to the public repo.

### Key details

- **age key location**: `~/.config/chezmoi/key.txt` (never committed, `chmod 600`)
- **Public recipient**: `age1kufmhsfggzs6c9qsf8h8p622c4rwjg4hmty9gfvanm6fp72s756q65exra`
- **Key backup**: Stored in 1Password (Personal vault)

### Encrypted files

| Source file | Decrypted target |
|-------------|-----------------|
| `dot_config/git/encrypted_config.age` | `~/.config/git/config` |
| `dot_config/gh/encrypted_private_hosts.yml.age` | `~/.config/gh/hosts.yml` |
| `private_dot_ssh/encrypted_config.age` | `~/.ssh/config` |

### Encrypting a new secret file

```bash
# Encrypt a file and add it to chezmoi
chezmoi add --encrypt ~/.config/some/secret-file

# Or encrypt inline during edit
chezmoi encrypt ~/.config/some/plaintext-file > \
  ~/.local/share/chezmoi/dot_config/some/encrypted_secret-file.age
```

### Editing an encrypted file

```bash
# Opens decrypted content in $EDITOR, re-encrypts on save
chezmoi edit ~/.config/git/config
```

---

## Day-to-Day Usage

### Edit a tracked file

```bash
# Opens the source file in $EDITOR and applies on save
chezmoi edit ~/.zshrc

# Edit and immediately apply
chezmoi edit --apply ~/.zshrc
```

### Apply changes

```bash
# Apply all pending changes
chezmoi apply

# Preview what would change (dry run)
chezmoi diff

# Apply a single file
chezmoi apply ~/.zshrc
```

### Check status

```bash
# Show which files differ between source and target
chezmoi status
```

### Commit changes

```bash
# Navigate to the source repo
cd ~/.local/share/chezmoi

# Commit all changes
git add -A && git commit -m "chore: update aliases"
git push
```

### Pull changes on another machine

```bash
# Pull and apply latest changes from GitHub
chezmoi update
```

### Re-run a bootstrap script

Bootstrap scripts run only once (tracked by content hash). To force re-run:

```bash
# Reset the run-once state for a specific script
chezmoi state delete-bucket --bucket=scriptState
```

Or edit the script slightly (e.g., add a comment) to change its hash.

---

## Shell Setup

The Zsh configuration is split into focused modules under `~/.config/zsh/`:

### Module overview

| File | Purpose |
|------|---------|
| `env.zsh` | `$PATH`, `$EDITOR`, locale, initializes Starship, zoxide, Atuin |
| `history.zsh` | History file size (1,000,000 entries), dedup options |
| `fzf.zsh` | fzf key bindings, previews using `bat` and `eza`, yazi `y()` wrapper |
| `omz.zsh` | Oh My Zsh theme (none — Starship handles prompt), plugins list |
| `aliases.zsh` | All shell aliases |
| `.zshrc` | Sources all modules in order |

### Notable aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `ls` | `eza --color --icons --long --header --git` | Long listing with git status |
| `lt` | `eza --tree --level=2 --long --icons --git` | Tree view (2 levels) |
| `cd` | `z` | zoxide smart directory jump |
| `ff` | `fastfetch` | System info |
| `sysup` | `brew upgrade; mas upgrade; omz update` | Update everything |
| `oc` | `opencode` | AI coding assistant |
| `gh-create` | `gh repo create --private ...` | Create private GitHub repo and push |
| `fh` | `fc -l 1 \| tac \| fzf` | Fuzzy search shell history |
| `idea` | IntelliJ IDEA Ultimate binary | Launch IDE |
| `rr` | `source ~/.zshrc` | Reload shell config |

### Oh My Zsh plugins

```
git           # Git aliases and prompt info
sudo          # Double Esc to prepend sudo
zsh-autosuggestions     # Fish-style autosuggestions
zsh-syntax-highlighting # Syntax highlighting as you type
web-search    # web-search google <query>
copyfile      # Copy file contents to clipboard
copybuffer    # Ctrl+O copies current buffer
dirhistory    # Alt+Arrow for directory history
python        # Python virtualenv helpers
history       # History aliases (h, hs, hsi)
macos         # macOS-specific utilities
copypath      # Copy current path to clipboard
emoji         # Emoji insertion
encode64      # Base64 encode/decode
colored-man-pages # Colorized man pages
aliases       # alias-finder helpers
```

---

## Installed Tools

### Homebrew packages

**Shell & prompt**
- `zsh`, `zsh-autosuggestions`, `starship`, `thefuck`, `direnv`, `zoxide`

**Shell history**
- `atuin`, `fzf`, `navi`

**File tools**
- `eza`, `bat`, `bat-extras`, `yazi`, `fd`, `ripgrep`, `tree`, `trash`, `duf`

**Dev tools**
- `neovim`, `git`, `git-lfs`, `git-filter-repo`, `diff-so-fancy`, `lazygit`, `gh`, `pre-commit`, `just`, `gum`, `jq`, `glow`, `curl`, `wget`, `rsync`

**Security & secrets**
- `age`, `sops`, `gnupg`, `detect-secrets`

**Infra / cloud**
- `ansible`, `opentofu`, `kubernetes-cli`, `tailscale`

**Networking & diagnostics**
- `mtr`, `nmap`, `iperf3`, `speedtest-cli`, `xh`, `curlie`

**Misc CLI**
- `fastfetch`, `btop`, `htop`, `tmux`, `mas`, `opencode`

### Homebrew casks (GUI apps)

| App | Purpose |
|-----|---------|
| Ghostty | Terminal emulator |
| OrbStack | Docker / Linux VMs |
| 1Password + CLI | Password manager + secrets |
| Raycast | Spotlight replacement |
| LinearMouse | Mouse customization |
| AltTab | Window switcher |
| Ice | Menu bar manager |
| Stats | System stats in menu bar |
| Shottr | Screenshot tool |
| JetBrains Toolbox | IDE manager |
| Figma | Design tool |
| draw.io | Diagramming |
| Postman | API client |
| Cyberduck | FTP/S3/cloud storage client |
| LocalSend | Local file transfer |
| Keka | Archive manager |
| kDrive | Infomaniak cloud storage |
| Zotero | Reference manager |
| Discord, Telegram, WhatsApp | Messaging |
| Zen, Brave Browser | Web browsers |
| Wireshark | Network analyzer |
| Symbols Only Nerd Font | Nerd Font icons for terminal |

---

## Adding New Files

### Track a new dotfile

```bash
# Add a file to chezmoi source
chezmoi add ~/.config/some/config-file

# Add as encrypted
chezmoi add --encrypt ~/.config/some/secret-file
```

### Track a directory

```bash
chezmoi add ~/.config/some-tool/
```

### Exclude a file/directory from tracking

Add a pattern to `.chezmoiignore`:

```bash
# In ~/.local/share/chezmoi/.chezmoiignore
dot_config/some-tool/
```

---

## Troubleshooting

### age decryption fails on apply

**Error:** `chezmoi: decrypt: ...`

**Cause:** The age key at `~/.config/chezmoi/key.txt` is missing or wrong.

**Solution:**
1. Retrieve the age private key from 1Password
2. Write it to `~/.config/chezmoi/key.txt`:
   ```bash
   mkdir -p ~/.config/chezmoi
   # Paste the key:
   nano ~/.config/chezmoi/key.txt
   chmod 600 ~/.config/chezmoi/key.txt
   ```
3. Re-run: `chezmoi apply`

### Prompts appear on every `chezmoi apply`

**Cause:** `~/.config/chezmoi/chezmoi.toml` is missing or incomplete.

**Solution:** Answer all prompts once — chezmoi saves them to `chezmoi.toml`. If the file was deleted, re-run `chezmoi init --apply boranuzun` or create it manually:

```toml
# ~/.config/chezmoi/chezmoi.toml
encryption = "age"

[data]
  email = "you@example.com"
  name = "Your Name"
  hasOrbStack = true
  hasJetBrains = false

[age]
  identity = "~/.config/chezmoi/key.txt"
  recipient = "age1kufmhsfggzs6c9qsf8h8p622c4rwjg4hmty9gfvanm6fp72s756q65exra"
```

### Homebrew packages not installing

**Cause:** `run_once_before_20` script already ran and chezmoi won't re-run it.

**Solution:** Run `brew bundle` manually from the chezmoi source directory:

```bash
brew bundle --file="$HOME/.local/share/chezmoi/Brewfile"
```

### `chezmoi diff` shows unexpected changes

chezmoi detected a difference between source and target. Preview:

```bash
chezmoi diff
```

To overwrite target with source (apply source → target):
```bash
chezmoi apply
```

To overwrite source with target (update source from your edits):
```bash
chezmoi re-add ~/.config/some/file
```

### zsh-syntax-highlighting not working

The plugin must be cloned manually into Oh My Zsh custom plugins:

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
  ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

Then reload: `source ~/.zshrc`

### SSH keys not available

SSH private keys are stored in 1Password and served via the 1Password SSH agent. The `~/.ssh/config` (decrypted from the age-encrypted source) already configures:

```
IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
```

Ensure:
1. 1Password is installed and running
2. SSH agent is enabled in 1Password → Settings → Developer → SSH Agent

---

## License

Personal dotfiles — feel free to use anything here as inspiration.
