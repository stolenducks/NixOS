# NixOS System Configuration

> Flake-based NixOS configuration for ThinkPad X1 Carbon Gen 8 running Niri Wayland compositor with Noctalia shell.

## System Overview

| Property | Value |
|----------|-------|
| **Host** | `nixos` |
| **User** | `dolandstutts` |
| **Hardware** | Lenovo ThinkPad X1 Carbon Gen 8 (Intel) |
| **OS** | NixOS unstable (flake-based) |
| **Desktop** | Niri (scrollable tiling Wayland compositor) |
| **Shell** | Noctalia Shell (app launcher, panels, notifications) |
| **Terminal** | Ghostty |
| **Editor** | Zed |
| **Lock Screen** | Hyprlock |
| **Theme** | Nord colors, Papirus-Dark icons |

## Project Structure

```
~/NixOS/                              # Git repo - SINGLE SOURCE OF TRUTH
├── AGENT.md                          # This file - AI agent context
├── README.md                         # Project overview
├── flake.nix                         # Flake inputs + NixOS config outputs
├── flake.lock                        # Pinned dependency versions
├── configuration.nix                 # System config (boot, services, packages)
├── hardware-configuration.nix        # Machine-specific (auto-generated)
├── home.nix                          # Home Manager (user dotfiles, theming)
└── modules/                          # Custom reusable NixOS modules
    ├── README.md                     # Module documentation
    ├── file-manager.nix              # Nautilus + GVfs
    ├── system-tools.nix              # Desktop entry fixes (btop launcher)
    └── device-services.nix           # udisks2, polkit automount rules
```

## Flake Inputs

| Input | Purpose | URL |
|-------|---------|-----|
| `nixpkgs` | Package repository | `github:NixOS/nixpkgs/nixos-unstable` |
| `home-manager` | User-level config | `github:nix-community/home-manager` |
| `noctalia` | App launcher shell | `github:noctalia-dev/noctalia-shell` |
| `llm-agents` | OpenCode AI tool | `github:numtide/llm-agents.nix` |
| `catppuccin` | Theming module | `github:catppuccin/nix` |
| `nixos-hardware` | Hardware optimizations | `github:NixOS/nixos-hardware/master` |
| `mac-style-plymouth` | Boot animation | `github:SergioRibera/s4rchiso-plymouth-theme` |

## File Responsibilities

| File | What Goes Here |
|------|----------------|
| `flake.nix` | External inputs, nixosConfigurations output, module imports |
| `configuration.nix` | System packages, services, boot config, networking, shell setup |
| `home.nix` | User dotfiles, GTK/Qt theming, desktop entries, managed configs (niri, hyprlock) |
| `hardware-configuration.nix` | Auto-generated hardware config (filesystems, kernel modules) |
| `modules/*.nix` | Reusable modules with `mkEnableOption`/`mkIf` pattern |

## Commands

### Primary (use these)

| Command | Description |
|---------|-------------|
| `rebuild` | `nh os switch` - Rebuild system with diff preview |
| `rebuild-boot` | `nh os boot` - Rebuild, apply on next boot |
| `search` | `nh search` - Interactive package search |
| `clean` | `nh clean all --keep 5` - Remove old generations |

### Manual (if aliases unavailable)

```bash
sudo nixos-rebuild switch --flake ~/NixOS
```

### Boot Menu

Press **Space** during boot to select previous NixOS generations.

## Boot Flow

```
Power On
    |
    v
Plymouth (mac-style animated NixOS logo)
    |
    v
greetd (auto-login, no greeter shown)
    |
    v
niri-session (Wayland compositor)
    |
    v
Hyprlock (lock screen with --immediate --no-fade-in)
    |
    v
User unlocks -> Noctalia shell + desktop ready
```

## Custom Modules (Tony Banters Style)

All custom modules follow the NixOS module pattern:

```nix
{ config, lib, pkgs, ... }:
let cfg = config.modules.my-module;
in {
  options.modules.my-module = {
    enable = lib.mkEnableOption "description";
    # additional options...
  };
  config = lib.mkIf cfg.enable {
    # configuration here
  };
}
```

### Available Modules

#### `modules.file-manager`
- **Purpose**: GUI file manager (Nautilus) with removable device support
- **Options**: `enable`
- **Enables**: Nautilus, udisks2, gvfs

#### `modules.system-tools`
- **Purpose**: Fix desktop entries for CLI tools
- **Options**: `enable`, `fixBtop`
- **Enables**: btop runs in ghostty terminal

#### `modules.device-services`
- **Purpose**: Device mounting and polkit rules
- **Options**: `enable`, `automountWithoutPassword`
- **Enables**: udisks2, gvfs, polkit with wheel group automount

## Key Configuration Locations

| Path | Description | Managed By |
|------|-------------|------------|
| `~/NixOS/` | Git repo, edit configs here | Manual |
| `/etc/nixos/` | Empty (unused with flakes) | - |
| `~/.config/ghostty/config` | Ghostty terminal config | `home.nix` (xdg.configFile) |
| `~/.config/ghostty/shaders/` | Ghostty shader effects | `home.nix` (xdg.configFile) |
| `~/.config/niri/config.kdl` | Niri compositor config | `home.nix` (xdg.configFile) |
| `~/.config/hypr/hyprlock.conf` | Lock screen config | `home.nix` (xdg.configFile) |
| `~/.config/niri/noctalia.kdl` | Noctalia theme colors | `home.nix` (xdg.configFile) |

## Package Installation Patterns

### System-wide (in `configuration.nix`)
```nix
environment.systemPackages = with pkgs; [ package-name ];
```

### User-only (in `home.nix`)
```nix
home.packages = with pkgs; [ package-name ];
```

### From Flake Input
```nix
inputs.INPUT-NAME.packages.${pkgs.stdenv.hostPlatform.system}.default
```

### Example: Adding a new flake input
```nix
# 1. Add to flake.nix inputs
inputs.new-tool = {
  url = "github:owner/repo";
  inputs.nixpkgs.follows = "nixpkgs";
};

# 2. Add to outputs function args
outputs = inputs@{ ..., new-tool, ... }:

# 3. Use in configuration.nix
environment.systemPackages = [
  inputs.new-tool.packages.${pkgs.stdenv.hostPlatform.system}.default
];
```

## Desktop Entry Patterns

### In `home.nix` (preferred for user apps)
```nix
xdg.desktopEntries.app-name = {
  name = "App Name";
  exec = "${pkgs.package}/bin/command";
  icon = "icon-name";
  terminal = false;
  categories = [ "Category" ];
};
```

### In `configuration.nix` (system-wide)
```nix
environment.etc."xdg/applications/app.desktop".text = ''
  [Desktop Entry]
  Name=App Name
  Exec=command
  Icon=icon-name
  Terminal=false
  Type=Application
  Categories=Category;
'';
```

### Hiding Apps from Launcher
```nix
xdg.desktopEntries.app-to-hide = {
  name = "Hidden App";
  exec = "true";  # or actual command
  noDisplay = true;
  settings.Hidden = "true";
};
```

## Shell Aliases (Fish)

| Alias | Expansion | Purpose |
|-------|-----------|---------|
| `ls` | `eza --icons` | Enhanced ls with icons |
| `ll` | `eza -la --icons` | Long listing |
| `lt` | `eza --tree --icons` | Tree view |
| `cat` | `bat` | Syntax-highlighted cat |
| `grep` | `rg` | Ripgrep |
| `find` | `fd` | fd-find |
| `rebuild` | `nh os switch` | Rebuild system |
| `rebuild-boot` | `nh os boot` | Rebuild for next boot |
| `search` | `nh search` | Package search |
| `clean` | `nh clean all --keep 5` | Cleanup generations |

## Installed System Packages

**Desktop**: noctalia-shell, ghostty, zed-editor, firefox, nautilus, obsidian
**CLI Tools**: ripgrep, fd, eza, bat, fzf, gum, zoxide, starship, tldr, jq, tree, btop, fastfetch, ncdu
**TUI Apps**: superfile (file manager), bluetui (bluetooth), caligula (disk imager)
**System**: nh, nixd, hyprlock, wl-clipboard, cliphist, grim, slurp
**Fonts**: JetBrainsMono Nerd Font, Fira Code Nerd Font, Noto (+ emoji)

## Hardware Services

| Service | Status | Notes |
|---------|--------|-------|
| Bluetooth | Enabled | Managed via bluetui TUI |
| Power Profiles | Enabled | power-profiles-daemon |
| UPower | Enabled | Battery monitoring |
| Audio | PipeWire | With PulseAudio compatibility |
| Printing | Enabled | CUPS |
| SSH | Enabled | openssh |
| Tailscale | Enabled | VPN mesh network |
| LocalSend | Enabled | LAN file sharing |

## Known Issues / Workarounds

1. **"import-environment without a list" warning**
   - Source: `niri-session` upstream
   - Status: Harmless, hidden by redirecting stderr in greetd config

2. **Plymouth timing**
   - If boot text shows briefly, Plymouth may need earlier start
   - Current kernel params hide most output

3. **Lock screen delay**
   - Hyprlock uses `--immediate --no-fade-in` flags for instant display

4. **Ghostty theme names are case-sensitive**
   - Use `ghostty +list-themes` to see exact names
   - Example: `theme = "Nord"` not `theme = "nord"`

## Development Workflow

### After Editing Configs

1. Edit files in `~/NixOS/`
2. Run `rebuild` (or `rebuild-boot` for risky changes)
3. Review diff preview from `nh`
4. Commit: `git add -A && git commit -m "message" && git push`

### Testing Changes Safely

```bash
# Build without switching (check for errors)
nix build .#nixosConfigurations.nixos.config.system.build.toplevel

# Build and apply on next boot only
rebuild-boot

# Full rebuild with switch
rebuild
```

### Rollback

```bash
# List generations
sudo nix-env --list-generations --profile /nix/var/nix/profiles/system

# Rollback to previous
sudo nixos-rebuild switch --rollback

# Or select from boot menu (Space during boot)
```

## Don'ts

- **Don't** use `nix-env -i` (breaks reproducibility)
- **Don't** edit `/etc/nixos/` (it's ignored with flakes)
- **Don't** use `../` relative paths in flake imports
- **Don't** hardcode `/nix/store/` paths
- **Don't** edit `hardware-configuration.nix` manually (regenerate with `nixos-generate-config`)
- **Don't** put secrets in nix files (use sops-nix or agenix if needed)

## Agent Instructions

### When Modifying This System

1. **Always check file responsibilities** - system config vs home-manager vs modules
2. **Use existing patterns** - match the style of surrounding code
3. **Test builds** before committing: `nix build .#nixosConfigurations.nixos.config.system.build.toplevel`
4. **Run `rebuild`** after changes to verify they work
5. **Check `lsp_diagnostics`** if using nixd for Nix LSP

### When Adding New Features

1. Determine if it's system-level (configuration.nix) or user-level (home.nix)
2. For reusable functionality, create a module in `modules/`
3. For new flake inputs, add to `flake.nix` inputs and outputs
4. Document significant changes in this AGENT.md

### Nix Language Notes

- Use `lib.mkIf` for conditional config
- Use `lib.mkEnableOption` for boolean options
- Use `lib.mkOption` for typed options with defaults
- Use `with pkgs;` for package lists
- Prefer `${pkgs.package}/bin/command` over bare commands in desktop entries

## External References

- [Tony Banters NixOS Guide](https://github.com/tonybanters/nixos-from-scratch)
- [Niri + Noctalia Setup](https://www.tonybtw.com/tutorial/niri/)
- [NixOS Package Search](https://search.nixos.org/packages)
- [NixOS Options Search](https://search.nixos.org/options)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)
- [NixOS Wiki](https://wiki.nixos.org/)
