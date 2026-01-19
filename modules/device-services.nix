{ pkgs, lib, config, ... }:
# Device Services Module
# Enables proper mounting, cloud storage, and automount for removable devices
# Required for: USB drives, cloud storage, network shares
# Reference: https://wiki.nixos.org/wiki/USB_storage_devices

let
  cfg = config.modules.device-services;
in
{
  options.modules.device-services = {
    enable = lib.mkEnableOption "Device services (udisks2, GVfs, polkit)";
    automountWithoutPassword = lib.mkEnableOption "Allow automount without password";
  };

  config = lib.mkIf cfg.enable {
    # Core device mounting (required for USB, etc.)
    services.udisks2.enable = true;

    # Cloud storage, network mounts, trash support
    services.gvfs.enable = true;

    # Polkit for authorization without password
    security.polkit.enable = true;

    # Polkit rules for passwordless automount (wheel group)
    security.polkit.extraConfig = lib.optionalAttrs cfg.automountWithoutPassword ''
      polkit.addRule(function(action, subject) {
        if (action.id.startsWith("org.freedesktop.udisks2.") &&
            subject.isInGroup("wheel")) {
          return polkit.Result.YES;
        }
      });
    '';
  };
}
