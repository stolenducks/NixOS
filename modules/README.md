# NixOS Modules - Tony Banters Style

Modular, shareable NixOS configuration following Tony Banters' methodology.
Reference: https://github.com/tonybanters/nixos-from-scratch

## Structure

```
~/nixos/
├── modules/
│   ├── file-manager.nix    # GUI file manager (Nautilus)
│   ├── system-tools.nix    # btop fix, foot hiding
│   ├── device-services.nix # udisks2, GVfs, polkit
│   └── README.md           # This file
├── home.nix                # Home Manager user configuration
└── README.md               # This file
```

## Usage

### In your `/etc/nixos/configuration.nix`:

```nix
{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # Import modules from home directory
    "${config.home.homeDirectory}/nixos/modules/file-manager.nix"
    "${config.home.homeDirectory}/nixos/modules/system-tools.nix"
    "${config.home.homeDirectory}/nixos/modules/device-services.nix"
  ];

  # Enable modules
  modules.file-manager.enable = true;
  modules.file-manager.enableCloud = true;

  modules.system-tools.enable = true;
  modules.system-tools.hideFootServer = true;
  modules.system-tools.fixBtop = true;

  modules.device-services.enable = true;
  modules.device-services.automountWithoutPassword = true;
}
```

### Optional: Home Manager for user-level config

Add to `flake.nix`:
```nix
{
  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }: {
    nixosConfigurations.yourhost = nixpkgs.lib.nixosSystem {
      # ...
      modules = [
        ./configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.users.youruser = import /home/youruser/nixos/home.nix;
        }
      ];
    };
  };
}
```

## Module Options

### file-manager.nix
- `modules.file-manager.enable` - Enable GUI file manager (Nautilus)
- `modules.file-manager.enableCloud` - Enable cloud storage integration (Google Drive, NextCloud)

### system-tools.nix
- `modules.system-tools.enable` - Enable system tools configuration
- `modules.system-tools.hideFootServer` - Hide Foot Server/Client from launcher
- `modules.system-tools.fixBtop` - Fix btop++ launcher to work in terminal

### device-services.nix
- `modules.device-services.enable` - Enable device services
- `modules.device-services.enableUdiskie` - Enable udiskie tray for automount
- `modules.device-services.automountWithoutPassword` - Allow automount without password

## Tony's Best Practices

1. **Modular structure** - Each concern in its own module
2. **Shareable** - Modules can be copied between machines
3. **Declarative** - Everything in code, no manual config
4. **Reproducible** - Uses flakes for pinned dependencies

## References

- [Tony Banters - NixOS from Scratch](https://github.com/tonybanters/nixos-from-scratch)
- [Niri + Noctalia Setup](https://www.tonybtw.com/tutorial/niri/)
- [Quickshell Tutorial](https://www.tonybtw.com/tutorial/quickshell/)
