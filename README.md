# NixOS Configuration

Flake-based NixOS configuration for ThinkPad X1 Carbon Gen 8.

## Quick Start

```bash
# Rebuild system (with diff preview)
rebuild

# Or manually
sudo nixos-rebuild switch --flake ~/NixOS
```

## System Overview

| Component | Choice |
|-----------|--------|
| Desktop | Niri (scrollable tiling Wayland) |
| Shell | Noctalia (app launcher, panels) |
| Terminal | Foot |
| Editor | Zed |
| Theme | Nord colors, Papirus-Dark icons |

## Structure

```
~/NixOS/
├── flake.nix           # Flake inputs and outputs
├── configuration.nix   # System configuration
├── home.nix            # User configuration (Home Manager)
├── hardware-configuration.nix
├── modules/            # Custom reusable modules
│   ├── file-manager.nix
│   ├── system-tools.nix
│   └── device-services.nix
├── AGENT.md            # AI assistant context
└── .opencode/          # OpenCode project config
```

## Commands

| Command | Description |
|---------|-------------|
| `rebuild` | Rebuild and switch (`nh os switch`) |
| `rebuild-boot` | Rebuild for next boot (`nh os boot`) |
| `search` | Search packages (`nh search`) |
| `clean` | Remove old generations (`nh clean all --keep 5`) |

## Documentation

- [AGENT.md](./AGENT.md) - Comprehensive system documentation for AI assistants
- [modules/README.md](./modules/README.md) - Custom module documentation

## Links

- [NixOS Package Search](https://search.nixos.org/packages)
- [NixOS Options Search](https://search.nixos.org/options)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)
