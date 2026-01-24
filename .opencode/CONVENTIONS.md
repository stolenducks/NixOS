# NixOS Project Conventions

## Nix Language Style

### Module Structure
```nix
{ config, lib, pkgs, ... }:
let 
  cfg = config.modules.module-name;
in {
  options.modules.module-name = {
    enable = lib.mkEnableOption "description";
  };
  
  config = lib.mkIf cfg.enable {
    # implementation
  };
}
```

### Indentation
- 2 spaces, no tabs
- Align attribute sets vertically when readable

### Naming
- Module options: `modules.<name>.<option>`
- Packages: lowercase with hyphens (`my-package`)
- Variables: camelCase or snake_case (match surrounding code)

## File Organization

| Change Type | Target File |
|-------------|-------------|
| System services | `configuration.nix` |
| System packages | `configuration.nix` → `environment.systemPackages` |
| User packages | `home.nix` → `home.packages` |
| User dotfiles | `home.nix` → `xdg.configFile` |
| Desktop entries | `home.nix` → `xdg.desktopEntries` |
| GTK/Qt theming | `home.nix` → `gtk`, `qt` |
| Reusable feature | `modules/*.nix` |
| External dependency | `flake.nix` → `inputs` |

## Package References

### Prefer Full Paths in Desktop Entries
```nix
# Good - explicit path
exec = "${pkgs.ghostty}/bin/ghostty -e btop";

# Bad - relies on PATH
exec = "ghostty -e btop";
```

### Flake Input Packages
```nix
# Correct pattern
inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default

# Not: inputs.noctalia.packages.x86_64-linux.default (hardcoded arch)
```

## Testing Changes

### Before Committing
```bash
# Quick syntax check
nix flake check

# Full build without switch
nix build .#nixosConfigurations.nixos.config.system.build.toplevel
```

### Safe Deployment
```bash
# Apply on next boot (can rollback via boot menu)
nh os boot

# Only after testing boot config works
nh os switch
```

## Git Workflow

### Commit Messages
```
<type>: <description>

Types:
- feat: new functionality
- fix: bug fix
- refactor: code restructure
- docs: documentation
- style: formatting
- chore: maintenance
```

### Examples
```
feat: add bluetooth TUI desktop entry
fix: btop desktop entry now opens in ghostty terminal
refactor: extract device services to separate module
docs: update AGENT.md with boot flow diagram
```

## Prohibited Patterns

### Never Do
- `nix-env -i` (use declarative packages)
- Edit `/etc/nixos/` (we use flakes in ~/NixOS)
- Hardcode `/nix/store/` paths
- Use `../` relative imports in flake
- Suppress warnings with `builtins.trace` hacks
- Put secrets/passwords in nix files

### Avoid
- `with pkgs;` in large scopes (prefer explicit)
- Deeply nested `let...in` blocks
- Copy-pasting config between files (make a module)

## Gotchas

### Ghostty
- **Theme names are case-sensitive**: Use `ghostty +list-themes` to see exact names
- Example: `theme = "Nord"` not `theme = "nord"`
- Config location: `~/.config/ghostty/config` (managed via `home.nix` xdg.configFile)

### Noctalia-managed Files
- `~/.config/niri/noctalia.kdl` is managed by noctalia-shell for dynamic theming
- Do NOT add this file to Home Manager's `xdg.configFile` (causes read-only conflict)
- Only `config.kdl` should be managed by Home Manager

## Documentation Maintenance (CRITICAL)

**Rule**: When changing system architecture, packages, or configuration patterns, ALWAYS update documentation in the same commit.

### Files to Update
| Change Type | Update These Files |
|-------------|-------------------|
| Add/remove packages | `AGENT.md` (Installed Packages section) |
| Change terminal/editor/apps | `README.md` (System Overview table), `AGENT.md` |
| Add new modules | `AGENT.md` (Custom Modules), `modules/README.md` |
| Change boot flow | `AGENT.md` (Boot Flow section) |
| New gotchas/workarounds | `CONVENTIONS.md` (Gotchas), `AGENT.md` (Known Issues) |
| Change file management | `AGENT.md` (Key Configuration Locations) |

### Verification Checklist
Before committing system changes, verify:
- [ ] `README.md` System Overview table is accurate
- [ ] `AGENT.md` package lists match `configuration.nix` and `home.nix`
- [ ] `AGENT.md` Key Configuration Locations reflects current file ownership
- [ ] `CONVENTIONS.md` Gotchas section is up to date

**Stale documentation is worse than no documentation.**
