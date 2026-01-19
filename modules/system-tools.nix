{ pkgs, lib, config, ... }:
# System Tools Module
# - Fixes btop++ launcher (Terminal=true issue)
# - Hides Foot Server/Client from application launcher
# - Provides proper desktop entries for CLI tools

let
  cfg = config.modules.system-tools;
in
{
  options.modules.system-tools = {
    enable = lib.mkEnableOption "System tools configuration";
    hideFootServer = lib.mkEnableOption "Hide Foot Server from launcher";
    fixBtop = lib.mkEnableOption "Fix btop++ launcher wrapper";
  };

  config = lib.mkIf cfg.enable {
    # Override btop.desktop to explicitly run in foot terminal
    # This goes to /run/current-system/sw/share/applications/ which overrides the package
    environment.etc = (lib.optionalAttrs cfg.hideFootServer {
      "share/applications/foot-server.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Foot Server
        Exec=${pkgs.foot}/bin/foot --server
        Icon=foot
        Terminal=false
        NoDisplay=true
      '';
      "share/applications/foot-client.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=Foot Client
        Exec=${pkgs.foot}/bin/footclient
        Icon=foot
        Terminal=false
        NoDisplay=true
      '';
    }) // (lib.optionalAttrs cfg.fixBtop {
      "share/applications/btop.desktop".text = ''
        [Desktop Entry]
        Type=Application
        Name=btop++
        GenericName=System Monitor
        Comment=Resource monitor with graphs for CPU, memory, disks, network
        Icon=utilities-system-monitor
        Exec=${pkgs.foot}/bin/foot -e btop
        Terminal=false
        Categories=System;Monitor;ConsoleOnly;
      '';
    });
  };
}
