{ pkgs, lib, config, ... }:
# System Tools Module
# - Fixes btop++ launcher (Terminal=true issue)
# - Provides proper desktop entries for CLI tools that need a terminal

let
  cfg = config.modules.system-tools;
in
{
  options.modules.system-tools = {
    enable = lib.mkEnableOption "System tools configuration";
    fixBtop = lib.mkEnableOption "Fix btop++ launcher to run in ghostty";
  };

  config = lib.mkIf cfg.enable {
    # Override btop.desktop to explicitly run in ghostty terminal
    # This goes to /run/current-system/sw/share/applications/ which overrides the package
    environment.etc = lib.optionalAttrs cfg.fixBtop {
      "share/applications/btop.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=btop++
        GenericName=System Monitor
        Comment=Resource monitor with graphs for CPU, memory, disks, network
        Icon=utilities-system-monitor
        Exec=${pkgs.ghostty}/bin/ghostty -e btop
        Terminal=false
        Categories=System;Monitor;ConsoleOnly;
      '';
    };
  };
}
