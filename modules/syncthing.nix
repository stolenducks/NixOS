{ config, lib, pkgs, ... }:
# Syncthing Module
# Continuous file synchronization between devices
# Connects to home server (Proxmox) over Tailscale
# Local Web UI: http://localhost:8384
# Proxmox Web UI: http://100.85.235.123:8384

let
  cfg = config.modules.syncthing;
in
{
  options.modules.syncthing = {
    enable = lib.mkEnableOption "Syncthing file synchronization";

    user = lib.mkOption {
      type = lib.types.str;
      default = "dolandstutts";
      description = "User to run Syncthing as";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open firewall ports for Syncthing";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable Syncthing service
    services.syncthing = {
      enable = true;
      user = cfg.user;
      group = "users";

      # Store data in user's home directory
      dataDir = "/home/${cfg.user}";
      configDir = "/home/${cfg.user}/.config/syncthing";

      # Open default ports (22000/tcp for sync, 21027/udp for discovery)
      openDefaultPorts = cfg.openFirewall;

      # Declarative configuration - NixOS manages devices and folders
      overrideDevices = true;
      overrideFolders = true;

      settings = {
        options = {
          relaysEnabled = true;
          natEnabled = true;
          localAnnounceEnabled = true;
          globalAnnounceEnabled = true;
        };

        # Devices to sync with
        devices = {
          "proxmox" = {
            # Docker container Syncthing (secure, non-root)
            id = "VRBJKCA-ZBQFOFM-OFUJLNN-R273F7Q-2AH6BSS-I65HCGQ-2HQQS2Y-TXVNYAB";
            addresses = [ "tcp://100.85.235.123:22000" ]; # Tailscale IP
          };
        };

        # Folders to sync
        folders = {
          "sync" = {
            id = "sync";
            label = "Sync";
            path = "/home/${cfg.user}/Sync";
            devices = [ "proxmox" ];
            versioning = {
              type = "simple";
              params.keep = "5";
            };
          };
        };
      };
    };

    # Desktop entry to quickly access the web UI
    environment.etc."xdg/applications/syncthing.desktop".text = ''
      [Desktop Entry]
      Name=Syncthing
      GenericName=File Synchronization
      Comment=Open Syncthing Web Interface
      Exec=sh -c "xdg-open 'http://127.0.0.1:8384'"
      Icon=syncthing
      Terminal=false
      Type=Application
      Categories=Network;FileTransfer;
      Keywords=sync;synchronization;backup;
    '';

    # Desktop entry to access Proxmox Syncthing (home server)
    environment.etc."xdg/applications/syncthing-server.desktop".text = ''
      [Desktop Entry]
      Name=Syncthing (Server)
      GenericName=Home Server Syncthing
      Comment=Open Proxmox Syncthing Web Interface
      Exec=sh -c "xdg-open 'http://100.85.235.123:8384'"
      Icon=syncthing
      Terminal=false
      Type=Application
      Categories=Network;FileTransfer;
      Keywords=sync;synchronization;server;proxmox;
    '';
  };
}
