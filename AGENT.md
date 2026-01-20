# NixOS System Agent Context

## Architecture Overview

```
~/NixOS/                          # Git repo - SINGLE SOURCE OF TRUTH
├── flake.nix                     # Flake inputs + NixOS config definition
├── flake.lock                    # Pinned dependency versions
├── configuration.nix             # System configuration (boot, services, packages)
├── hardware-configuration.nix    # Machine-specific (auto-generated, in git)
├── home.nix                      # Home Manager (user config, theming, dotfiles)
└── modules/                      # Custom reusable NixOS modules
    ├── file-manager.nix          # Nautilus + GVfs
    ├── system-tools.nix          # Desktop entry fixes (btop, foot)
    └── device-services.nix       # udisks2, polkit automount
```

## Key Facts

- **Distro**: NixOS unstable (flake-based)
- **Desktop**: Niri (Wayland tiling compositor)
- **Shell**: Fish + Starship prompt
- **Theme**: Catppuccin Mocha
- **Lock Screen**: Hyprlock (auto-locks on login)
- **App Launcher**: Noctalia Shell
- **User**: dolandstutts

## Commands

| Command | Description |
|---------|-------------|
| `rebuild` | `nh os switch` - Rebuild system with diff preview |
| `rebuild-boot` | `nh os boot` - Rebuild, apply on next boot |
| `search` | `nh search` - Interactive package search |
| `clean` | `nh clean all --keep 5` - Remove old generations |

### Manual rebuild (if aliases unavailable)
```sh
sudo nixos-rebuild switch --flake ~/NixOS
```

### Boot menu
Press **Space** during boot to select previous NixOS generations.

## File Responsibilities

| File | What goes here |
|------|----------------|
| `configuration.nix` | System packages, services, boot, networking, shell config |
| `home.nix` | User dotfiles, GTK/Qt theming, desktop entries, hyprlock config |
| `modules/*.nix` | Reusable modules with `mkEnableOption`/`mkIf` pattern |
| `flake.nix` | External inputs (nixpkgs, home-manager, noctalia, etc.) |

## Module Pattern

Custom modules use NixOS module system:
```nix
{ config, lib, pkgs, ... }:
let cfg = config.modules.my-module;
in {
  options.modules.my-module = {
    enable = lib.mkEnableOption "description";
  };
  config = lib.mkIf cfg.enable {
    # configuration here
  };
}
```

Enable in `configuration.nix`:
```nix
modules.my-module.enable = true;
```

## Flake Inputs

| Input | Purpose |
|-------|---------|
| `nixpkgs` | Package repository (unstable) |
| `home-manager` | User-level config management |
| `noctalia` | App launcher shell |
| `llm-agents` | OpenCode AI tool |
| `catppuccin` | Theming (Plymouth, etc.) |

Access in config via `inputs.NAME.packages.${system}.default`

## Known Issues

1. **"import-environment without a list" warning** - Comes from `niri-session` upstream, harmless, hidden by Plymouth during normal boot

2. **Plymouth timing** - If boot text shows briefly, Plymouth may need earlier start. Current kernel params hide most output.

3. **Lock screen delay** - Hyprlock configured with `immediate_render = true` and `no_fade_in = true` for fastest display

## Important Paths

| Path | Description |
|------|-------------|
| `~/NixOS/` | Git repo, edit configs here |
| `/etc/nixos/` | Empty (unused with flakes) |
| `~/.config/niri/config.kdl` | Niri compositor config |
| `~/.config/hypr/hyprlock.conf` | Lock screen (managed by home.nix) |

## Adding Packages

**System-wide** (in `configuration.nix`):
```nix
environment.systemPackages = with pkgs; [ package-name ];
```

**User-only** (in `home.nix`):
```nix
home.packages = with pkgs; [ package-name ];
```

**From flake input**:
```nix
inputs.INPUT-NAME.packages.${pkgs.stdenv.hostPlatform.system}.default
```

## Adding Desktop Entries

In `home.nix`:
```nix
xdg.desktopEntries.app-name = {
  name = "App Name";
  exec = "${pkgs.package}/bin/command";
  icon = "icon-name";
  terminal = false;
  categories = [ "Category" ];
};
```

## After Editing

1. Edit files in `~/NixOS/`
2. Run `rebuild`
3. Commit: `git add -A && git commit -m "message" && git push`

## Don'ts

- Don't use `nix-env -i` (breaks reproducibility)
- Don't edit `/etc/nixos/` (it's ignored)
- Don't use `../` paths in flake imports
- Don't hardcode `/nix/store/` paths