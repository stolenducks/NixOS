{ pkgs, lib, config, ... }:
# GUI File Manager Module
# Provides Nautilus (GNOME Files) - Finder-like experience
# Supports: removable devices, Wayland/Niri native
# Reference: https://wiki.nixos.org/wiki/Nautilus

let
  cfg = config.modules.file-manager;
in
{
  options.modules.file-manager = {
    enable = lib.mkEnableOption "GUI file manager (Nautilus)";
  };

  config = lib.mkIf cfg.enable {
    # Install file manager (Nautilus has its own desktop entry)
    environment.systemPackages = [
      pkgs.nautilus
    ];

    # Removable device mounting
    services.udisks2.enable = true;

    # Cloud storage, network shares, trash support
    services.gvfs.enable = true;
  };
}
