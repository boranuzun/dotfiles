# dotfiles

Personal dotfiles managed with [chezmoi](https://chezmoi.io). Bootstraps a fresh machine from zero to fully configured in one command — packages, shell, tools, and encrypted secrets all included.

Works on **macOS** (primary) and **Linux** (Debian/Ubuntu and Arch). All OS-specific logic lives in chezmoi templates — no runtime branching in shell configs.

## Table of Contents

- [Key Features](#key-features)
- [Tech Stack](#tech-stack)
- [What Gets Managed](#what-gets-managed)
- [Prerequisites](#prerequisites)
- [Bootstrap](#bootstrap)
  - [macOS](#macos)
  - [Linux](#linux)
- [Architecture](#architecture)
- [Directory Structure](#directory-structure)
- [Template Variables](#template-variables)
- [Encryption](#encryption)
- [Day-to-Day Usage](#day-to-day-usage)
- [Shell Setup](#shell-setup)
- [Installed Tools](#installed-tools)
- [Adding New Files](#adding-new-files)
- [Troubleshooting](#troubleshooting)

---

## Key Features

- **One-command bootstrap** — `chezmoi init --apply boranuzun` sets up a new machine end-to-end
- **Cross-platform** — macOS (Apple Silicon) and Linux (Debian/Ubuntu, Arch) with OS-gated templates
- **Age encryption** for secrets (git config, SSH config, GitHub hosts)
- **Templated configs** — shell files adapt based on OS and whether OrbStack is installed
- **Auto-installs packages** — Homebrew + `Brewfile` on macOS; `apt`/`pacman` on Linux
- **Zsh on all platforms** — installed and set as default shell on Linux automatically
- **Conventional commit template** enforced globally for all git repos

---

## Tech Stack

| Tool | Purpose |
|------|---------|
| [chezmoi](https://chezmoi.io) | Dotfile manager |
| [age](https://age-encryption.org) | Secret encryption |
| [Homebrew](https://brew.sh) | Package manager (macOS only) |
| [Oh My Zsh](https://ohmyz.sh) | Zsh framework |
| [Starship](https://starship.rs) | Shell prompt |
| [fzf](https://github.com/junegunn/fzf) | Fuzzy finder |
| [zoxide](https://github.com/ajeetdsouza/zoxide) | Smart `cd` |
| [eza](https://github.com/eza-community/eza) | Modern `ls` |
| [bat](https://github.com/sharkdp/bat) | Modern `cat` |
| [yazi](https://yazi-rs.github.io) | Terminal file manager |
| [Ghostty](https://ghostty.org) | Terminal emulator (macOS) |

---

## What Gets Managed

| Path | chezmoi source | Notes |
|------|---------------|-------|
| `~/.zshrc` | `dot_zshrc` | Delegates to `~/.config/zsh/.zshrc` |
| `~/.zprofile` | `dot_zprofile.tmpl` | Templated (Homebrew/OrbStack — macOS only) |
| `~/.config/zsh/` | `dot_config/zsh/` | All zsh config modules (templated) |
| `~/.config/git/` | `dot_config/git/` | Global ignore, commit template, encrypted gitconfig |
| `~/.config/gh/` | `dot_config/gh/` | GitHub CLI preferences and encrypted hosts |
| `~/.config/ghostty/` | `dot_config/ghostty/` | Terminal config, themes, icons |
| `~/.config/starship/` | `dot_config/starship/` | Prompt config |
| `~/.config/bat/` | `dot_config/bat/` | `cat` replacement config |
| `~/.config/eza/` | `dot_config/eza/` | `ls` replacement config |
| `~/.config/yazi/` | `dot_config/yazi/` | File manager config |
| `~/.config/fastfetch/` | `dot_config/fastfetch/` | System info display |
| `~/.config/btop/` | `dot_config/btop/` | Resource monitor config |
| `~/.ssh/config` | `private_dot_ssh/encrypted_config.age` | Encrypted SSH config |
| `~/Brewfile` (applied at source) | `Brewfile` | All Homebrew packages and casks (macOS only) |

**Not tracked** (excluded via `.chezmoiignore`):
- `~/.config/opencode/` — AI coding assistant (machine-specific)
- `~/.config/nvim/` — Neovim config (managed separately)
- `~/.config/op/` — 1Password CLI (machine-specific)

---

## Prerequisites

### macOS

- **macOS** (Apple Silicon assumed; Homebrew path `/opt/homebrew`)
- **Internet access** for Homebrew and package installation
- **age key file** at `~/.config/chezmoi/key.txt` to decrypt secrets

  Retrieve your age key from 1Password before bootstrapping:
  ```bash
  mkdir -p ~/.config/chezmoi
  # Paste your age private key into:
  nano ~/.config/chezmoi/key.txt
  chmod 600 ~/.config/chezmoi/key.txt
  ```

### Linux

- **Debian/Ubuntu** or **Arch Linux**
- **Internet access** for package installation
- **`sudo` access** for package manager commands and setting default shell
- **age key file** at `~/.config/chezmoi/key.txt` (same as macOS)
- `curl` must be available before bootstrapping (pre-installed on most distros)

---

## Bootstrap

### macOS

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply boranuzun
```

This single command:
1. Downloads and installs chezmoi
2. Clones `github.com/boranuzun/dotfiles` to `~/.local/share/chezmoi`
3. Runs `run_once_before_10-install-homebrew.sh.tmpl` — installs Homebrew if absent
4. Runs `run_once_before_20-install-packages.sh.tmpl` — runs `brew bundle` from `Brewfile`, then installs oh-my-zsh and its plugins
5. Prompts for configuration values (see below)
6. Applies all dotfiles to their target locations

### Linux

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- -b ~/.local/bin init --apply boranuzun
```

On Linux, the bootstrap script:
1. Installs chezmoi to `~/.local/bin`
2. Detects the distro via `/etc/os-release`
3. **Arch**: runs `pacman -Syu` and installs all packages in one shot
4. **Debian/Ubuntu**: runs `apt-get install` for packages available in apt, then installs `gh`, `fzf`, `starship`, `zoxide`, `lazygit`, `fastfetch`, `chezmoi`, `just`, `sops`, `oh-my-zsh`, and its plugins via their official install scripts or GitHub releases
5. Sets zsh as the default shell (`chsh`) if not already

> **Note:** Homebrew is **not** installed on Linux. Native package managers are used instead.

### Answer the Setup Prompts

chezmoi will ask questions on first apply:

| Prompt | Description | Stored as |
|--------|-------------|-----------|
| `Email address` | Your git/personal email | `data.email` |
| `Full name` | Your full name | `data.name` |
| `Is OrbStack installed?` | Enables OrbStack shell integration in `~/.zprofile` (macOS only) | `data.hasOrbStack` |

Answers are saved to `~/.config/chezmoi/chezmoi.toml` and will not be asked again.

### Verify the Setup

```bash
# Check shell is working
fastfetch

# Check git config was decrypted
git config --global user.email

# Check SSH config was decrypted
cat ~/.ssh/config
```

### Post-Bootstrap Steps (Manual)

These are not automated and must be done manually after bootstrapping:

- **GitHub CLI auth** — Authenticate with GitHub:
  ```bash
  gh auth login
  ```
- **(macOS only) 1Password SSH agent** — Enable in 1Password settings → Developer → SSH Agent. The SSH config already has `IdentityAgent` pointing to it.

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
| `run_once_before_` | Shell script run once, before applying dotfiles |
| `encrypted_` | Convention (not enforced) — file is age-encrypted |

### Bootstrap Script Order

Scripts run in lexicographic order by filename, before files are applied:

1. `run_once_before_10-install-homebrew.sh.tmpl` — Installs Homebrew (macOS only; no-op on Linux)
2. `run_once_before_20-install-packages.sh.tmpl` — Installs packages (`brew bundle` on macOS, `apt`/`pacman` on Linux)

`run_once_` scripts only execute once per machine (chezmoi tracks them by content hash). To force re-run, delete the entry from `~/.local/share/chezmoi/.chezmoistate.boltdb`.

### OS Branching

All platform-specific logic lives in chezmoi templates using `.chezmoi.os` and `.chezmoi.osRelease.id`:

```go
{{- if eq .chezmoi.os "darwin" }}
# macOS-only block
{{- else if eq .chezmoi.os "linux" }}
{{-   if eq .chezmoi.osRelease.id "arch" }}
# Arch-only block
{{-   else }}
# Debian/Ubuntu block
{{-   end }}
{{- end }}
```

No runtime OS detection happens in any shell config file.

---

## Directory Structure

```
~/.local/share/chezmoi/
├── .chezmoi.toml.tmpl               # Config template (prompts, encryption settings)
├── .chezmoiignore                   # Files excluded from management
├── .gitignore                       # Excludes docs/superpowers/ (local planning docs)
├── Brewfile                         # All Homebrew packages and casks (macOS only)
├── dot_zshrc                        # → ~/.zshrc (delegates to ~/.config/zsh/.zshrc)
├── dot_zprofile.tmpl                # → ~/.zprofile (Homebrew/OrbStack — macOS gated)
├── run_once_before_10-install-homebrew.sh.tmpl   # Installs Homebrew (macOS only)
├── run_once_before_20-install-packages.sh.tmpl   # Installs packages (cross-platform)
├── dot_config/
│   ├── zsh/
│   │   ├── dot_zshrc               # → ~/.config/zsh/.zshrc (sources all modules)
│   │   ├── aliases.zsh.tmpl        # Shell aliases (macOS/Linux variants)
│   │   ├── env.zsh.tmpl            # $PATH, $EDITOR, Starship, zoxide, Atuin
│   │   ├── fzf.zsh                 # fzf + yazi shell integration
│   │   ├── history.zsh             # Zsh history settings
│   │   └── omz.zsh.tmpl            # Oh My Zsh config (macos plugin gated)
│   ├── git/
│   │   ├── encrypted_config.age    # → ~/.config/git/config (name, email, etc.)
│   │   ├── ignore                  # → ~/.config/git/ignore (global gitignore)
│   │   └── template                # → ~/.config/git/template (commit message template)
│   ├── gh/
│   │   ├── private_config.yml              # → ~/.config/gh/config.yml
│   │   └── encrypted_private_hosts.yml.age # → ~/.config/gh/hosts.yml (auth tokens)
│   ├── ghostty/
│   │   ├── config                  # Terminal settings (font, theme, keybinds)
│   │   ├── icons/                  # Custom app icon
│   │   └── themes/                 # Custom color themes
│   ├── starship/
│   │   └── starship.toml           # Prompt configuration
│   ├── bat/                        # bat (cat replacement) config
│   ├── eza/                        # eza (ls replacement) config
│   ├── yazi/
│   │   ├── yazi.toml               # File manager config
│   │   ├── keymaps.toml            # Custom keybindings
│   │   ├── theme.toml              # Color theme
│   │   ├── package.toml            # yazi plugins
│   │   └── flavors/                # Theme flavors
│   ├── fastfetch/                  # System info display config
│   └── btop/                       # Resource monitor config
└── private_dot_ssh/
    └── encrypted_config.age        # → ~/.ssh/config (SSH host definitions)
```

---

## Template Variables

The following data variables are available in all `.tmpl` files:

| Variable | Type | Description |
|----------|------|-------------|
| `.chezmoi.os` | string | `"darwin"` or `"linux"` |
| `.chezmoi.osRelease.id` | string | `"arch"`, `"debian"`, `"ubuntu"`, etc. (Linux only) |
| `.email` | string | User's email address (from prompt) |
| `.name` | string | User's full name (from prompt) |
| `.hasOrbStack` | bool | Whether OrbStack is installed (macOS only; always `false` on Linux) |

Example usage in a template:
```toml
[user]
  email = "{{ .email }}"
  name = "{{ .name }}"
```

---

## Encryption

Secrets are encrypted with [age](https://age-encryption.org) before being committed to the public repo.

### Key Details

- **age key location**: `~/.config/chezmoi/key.txt` (never committed, `chmod 600`)
- **Public recipient**: `age1kufmhsfggzs6c9qsf8h8p622c4rwjg4hmty9gfvanm6fp72s756q65exra`
- **Key backup**: Stored in 1Password (Personal vault)

### Encrypted Files

| Source file | Decrypted target |
|-------------|-----------------|
| `dot_config/git/encrypted_config.age` | `~/.config/git/config` |
| `dot_config/gh/encrypted_private_hosts.yml.age` | `~/.config/gh/hosts.yml` |
| `private_dot_ssh/encrypted_config.age` | `~/.ssh/config` |

### Encrypting a New Secret File

```bash
# Encrypt a file and add it to chezmoi
chezmoi add --encrypt ~/.config/some/secret-file

# Or encrypt inline during edit
chezmoi encrypt ~/.config/some/plaintext-file > \
  ~/.local/share/chezmoi/dot_config/some/encrypted_secret-file.age
```

### Editing an Encrypted File

```bash
# Opens decrypted content in $EDITOR, re-encrypts on save
chezmoi edit ~/.config/git/config
```

---

## Day-to-Day Usage

### Edit a Tracked File

```bash
# Opens the source file in $EDITOR and applies on save
chezmoi edit ~/.zshrc

# Edit and immediately apply
chezmoi edit --apply ~/.zshrc
```

### Apply Changes

```bash
# Apply all pending changes
chezmoi apply

# Preview what would change (dry run)
chezmoi diff

# Apply a single file
chezmoi apply ~/.zshrc
```

### Check Status

```bash
# Show which files differ between source and target
chezmoi status
```

### Commit Changes

```bash
# Navigate to the source repo
cd ~/.local/share/chezmoi

# Commit all changes
git add -A && git commit -m "chore: update aliases"
git push
```

### Pull Changes on Another Machine

```bash
# Pull and apply latest changes from GitHub
chezmoi update
```

### Re-Run a Bootstrap Script

Bootstrap scripts run only once (tracked by content hash). To force re-run:

```bash
# Reset the run-once state for all scripts
chezmoi state delete-bucket --bucket=scriptState
```

Or edit the script slightly (e.g., add a comment) to change its hash.

---

## Shell Setup

The Zsh configuration is split into focused modules under `~/.config/zsh/`:

### Module Overview

| File | Purpose |
|------|---------|
| `env.zsh.tmpl` | `$PATH` (Homebrew on macOS), `$EDITOR`, locale, Starship, zoxide, Atuin |
| `history.zsh` | History file size (1,000,000 entries), dedup options |
| `fzf.zsh` | fzf key bindings (`source <(fzf --zsh)`), previews using `bat` and `eza`, yazi `y()` wrapper |
| `omz.zsh.tmpl` | Oh My Zsh theme (none — Starship handles prompt), plugins list |
| `aliases.zsh.tmpl` | All shell aliases (OS-specific variants) |
| `.zshrc` | Sources all modules in order |

### Notable Aliases

| Alias | Command | Description |
|-------|---------|-------------|
| `ls` | `eza --color --icons --long --header --git` | Long listing with git status |
| `lt` | `eza --tree --level=2 --long --icons --git` | Tree view (2 levels) |
| `cd` | `z` | zoxide smart directory jump |
| `ff` | `fastfetch` | System info |
| `sysup` | macOS: `brew upgrade; mas upgrade; omz update` / Arch: `sudo pacman -Syu; omz update` / Debian: `sudo apt update && sudo apt upgrade -y; omz update` | Update everything |
| `opc` | `opencode` | AI coding assistant |
| `cm` | `chezmoi` | chezmoi shortcut |
| `gh-create` | `gh repo create --private ...` | Create private GitHub repo and push |
| `fh` | `fc -l 1 \| tac \| fzf` | Fuzzy search shell history |
| `rr` | `source ~/.zshrc` | Reload shell config |
| `ql` | `qlmanage -p` | Quick Look preview (macOS only) |
| `idea` | IntelliJ IDEA Ultimate binary | Launch IDE (macOS only) |

### Oh My Zsh Plugins

```
git                      # Git aliases and prompt info
sudo                     # Double Esc to prepend sudo
zsh-autosuggestions      # Fish-style autosuggestions
zsh-syntax-highlighting  # Syntax highlighting as you type
web-search               # web-search google <query>
copyfile                 # Copy file contents to clipboard
copybuffer               # Ctrl+O copies current buffer
dirhistory               # Alt+Arrow for directory history
python                   # Python virtualenv helpers
history                  # History aliases (h, hs, hsi)
macos                    # macOS-specific utilities (macOS only)
copypath                 # Copy current path to clipboard
emoji                    # Emoji insertion
encode64                 # Base64 encode/decode
colored-man-pages        # Colorized man pages
aliases                  # alias-finder helpers
```

---

## Installed Tools

### macOS — Homebrew Packages

**Shell & prompt**
- `zsh`, `starship`, `thefuck`, `zoxide`

**Shell history**
- `fzf`, `navi`

**File tools**
- `eza`, `bat`, `bat-extras`, `yazi`, `fd`, `ripgrep`, `tree`, `trash`, `duf`

**Dev tools**
- `neovim`, `git`, `git-filter-repo`, `diff-so-fancy`, `lazygit`, `gh`, `just`, `jq`, `glow`, `curl`, `wget`, `rsync`

**Security & secrets**
- `age`, `sops`, `gnupg`, `detect-secrets`

**Infra / cloud**
- `ansible`, `opentofu`, `kubernetes-cli`, `tailscale`

**Networking & diagnostics**
- `mtr`, `nmap`, `iperf3`, `speedtest-cli`, `curlie`

**Misc CLI**
- `fastfetch`, `btop`, `tmux`, `mas`, `opencode`, `chezmoi`

### macOS — Homebrew Casks (GUI Apps)

| App | Purpose |
|-----|---------|
| Ghostty | Terminal emulator |
| OrbStack | Docker / Linux VMs |
| 1Password + CLI | Password manager + secrets |
| Raycast | Spotlight replacement |
| LinearMouse | Mouse customization |
| AltTab | Window switcher |
| Stats | System stats in menu bar |
| Thaw | Unfreeze / utility app |
| Figma | Design tool |
| draw.io | Diagramming |
| Postman | API client |
| Cyberduck | FTP/S3/cloud storage client |
| LocalSend | Local file transfer |
| Keka | Archive manager |
| Discord, WhatsApp | Messaging |
| Wireshark | Network analyzer |
| BasicTeX | Minimal TeX distribution |
| cmux | Terminal multiplexer UI |
| Symbols Only Nerd Font | Nerd Font icons for terminal |

### Linux — Native Packages

**Arch** (via `pacman` + install scripts):
`zsh`, `starship`, `eza`, `bat`, `fzf`, `fd`, `ripgrep`, `zoxide`, `git`, `neovim`, `lazygit`, `github-cli`, `jq`, `tmux`, `age`, `gnupg`, `curl`, `wget`, `rsync`, `tree`, `btop`, `fastfetch`, `chezmoi`, `just`, `sops`, then `oh-my-zsh`, `zsh-autosuggestions`, `zsh-syntax-highlighting` via install scripts

**Debian/Ubuntu** (via `apt` + install scripts):
- `apt`: `zsh`, `eza`, `bat`, `fd-find`, `ripgrep`, `git`, `neovim`, `jq`, `tmux`, `age`, `gnupg`, `curl`, `wget`, `rsync`, `tree`, `btop`
- Install scripts: `gh` (official apt repo), `fzf` (GitHub releases — apt version too old for `fzf --zsh`), `starship`, `zoxide`, `lazygit`, `fastfetch`, `chezmoi`, `just`, `sops`, `oh-my-zsh`, `zsh-autosuggestions`, `zsh-syntax-highlighting`

---

## Adding New Files

### Track a New Dotfile

```bash
# Add a file to chezmoi source
chezmoi add ~/.config/some/config-file

# Add as encrypted
chezmoi add --encrypt ~/.config/some/secret-file
```

### Track a Directory

```bash
chezmoi add ~/.config/some-tool/
```

### Exclude a File/Directory from Tracking

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
   nano ~/.config/chezmoi/key.txt
   chmod 600 ~/.config/chezmoi/key.txt
   ```
3. Re-run: `chezmoi apply`

### Prompts Appear on Every `chezmoi apply`

**Cause:** `~/.config/chezmoi/chezmoi.toml` is missing or incomplete.

**Solution:** Answer all prompts once — chezmoi saves them to `chezmoi.toml`. If the file was deleted, re-run `chezmoi init --apply boranuzun` or create it manually:

```toml
# ~/.config/chezmoi/chezmoi.toml
encryption = "age"

[data]
  email = "you@example.com"
  name = "Your Name"
  hasOrbStack = true   # set to false on Linux (ignored by templates anyway)

[age]
  identity = "~/.config/chezmoi/key.txt"
  recipient = "age1kufmhsfggzs6c9qsf8h8p622c4rwjg4hmty9gfvanm6fp72s756q65exra"
```

### Packages Not Installing (macOS)

**Cause:** `run_once_before_20` script already ran and chezmoi won't re-run it.

**Solution:** Run `brew bundle` manually:

```bash
brew bundle --file="$HOME/.local/share/chezmoi/Brewfile"
```

### Packages Not Installing (Linux)

**Cause:** Same — script already ran.

**Solution:** Re-run the relevant install commands manually. For example, on Debian/Ubuntu:

```bash
sudo apt-get update -y && sudo apt-get install -y zsh git neovim jq tmux ...
```

### `chezmoi diff` Shows Unexpected Changes

chezmoi detected a difference between source and target. Preview with:

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

### zsh-syntax-highlighting Not Working

The plugin is cloned automatically by the bootstrap script. If it's missing, clone it manually:

```bash
git clone https://github.com/zsh-users/zsh-syntax-highlighting \
  ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
```

Then reload: `source ~/.zshrc`

### SSH Keys Not Available

SSH private keys are stored in 1Password and served via the 1Password SSH agent. The `~/.ssh/config` (decrypted from the age-encrypted source) already configures:

```
IdentityAgent "~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
```

Ensure:
1. 1Password is installed and running
2. SSH agent is enabled in 1Password → Settings → Developer → SSH Agent

### Default Shell Not Set to Zsh (Linux)

The bootstrap script runs `chsh -s $(which zsh)` automatically. If it didn't take effect:

```bash
# Verify zsh path
which zsh

# Set manually
chsh -s /usr/bin/zsh

# Log out and back in for the change to apply
```

---

## License

Personal dotfiles — feel free to use anything here as inspiration.
