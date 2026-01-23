# NixOS Custom Modules

Modular, reusable NixOS configuration components following the Tony Banters methodology.

## Module Pattern

All modules use the standard NixOS module system:

```nix
{ config, lib, pkgs, ... }:
let cfg = config.modules.<name>;
in {
  options.modules.<name> = {
    enable = lib.mkEnableOption "<description>";
    # Additional options with lib.mkOption
  };
  
  config = lib.mkIf cfg.enable {
    # Configuration applied when enabled
  };
}
```

## Available Modules

### file-manager.nix

GUI file manager with removable device support.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `modules.file-manager.enable` | bool | false | Enable Nautilus file manager |

**What it enables:**
- `pkgs.nautilus` - GNOME Files GUI
- `services.udisks2` - Removable device mounting
- `services.gvfs` - Cloud storage, network shares, trash

**Usage:**
```nix
modules.file-manager.enable = true;
```

---

### system-tools.nix

Desktop entry fixes for CLI tools that don't integrate well with app launchers.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `modules.system-tools.enable` | bool | false | Enable system tools fixes |
| `modules.system-tools.fixBtop` | bool | false | Make btop++ open in ghostty terminal |

**What it fixes:**
- btop++ desktop entry runs `ghostty -e btop` instead of broken `Terminal=true`

**Usage:**
```nix
modules.system-tools.enable = true;
modules.system-tools.fixBtop = true;
```

---

### device-services.nix

Device mounting services and polkit rules for passwordless automount.

| Option | Type | Default | Description |
|--------|------|---------|-------------|
| `modules.device-services.enable` | bool | false | Enable device services |
| `modules.device-services.automountWithoutPassword` | bool | false | Wheel group can mount without password |

**What it enables:**
- `services.udisks2` - USB/removable device mounting
- `services.gvfs` - Virtual filesystem (cloud, network, trash)
- `security.polkit` - Authorization framework
- Polkit rule: `org.freedesktop.udisks2.*` actions allowed for wheel group

**Usage:**
```nix
modules.device-services.enable = true;
modules.device-services.automountWithoutPassword = true;
```

## Creating New Modules

### 1. Create the file

```bash
touch ~/NixOS/modules/my-feature.nix
```

### 2. Use the template

```nix
{ config, lib, pkgs, ... }:
let cfg = config.modules.my-feature;
in {
  options.modules.my-feature = {
    enable = lib.mkEnableOption "My feature description";
    
    # Add typed options
    someSetting = lib.mkOption {
      type = lib.types.str;
      default = "default-value";
      description = "What this setting does";
    };
  };
  
  config = lib.mkIf cfg.enable {
    # System packages
    environment.systemPackages = [ pkgs.some-package ];
    
    # Services
    services.some-service.enable = true;
    
    # Use the option value
    services.some-service.setting = cfg.someSetting;
  };
}
```

### 3. Import in configuration.nix

```nix
imports = [
  ./hardware-configuration.nix
  ./modules/file-manager.nix
  ./modules/system-tools.nix
  ./modules/device-services.nix
  ./modules/my-feature.nix  # Add this
];
```

### 4. Enable the module

```nix
modules.my-feature.enable = true;
modules.my-feature.someSetting = "custom-value";
```

## Best Practices

1. **Single responsibility** - One concern per module
2. **Sensible defaults** - Modules should work with just `enable = true`
3. **Document options** - Add `description` to all `mkOption` calls
4. **Use `mkIf`** - Never apply config unless module is enabled
5. **Avoid hardcoding** - Use options for anything that might vary

## References

- [NixOS Module System](https://nixos.wiki/wiki/Module)
- [lib.mkOption documentation](https://nixos.org/manual/nixpkgs/stable/#sec-option-declarations)
- [Tony Banters NixOS tutorials](https://www.tonybtw.com/)
