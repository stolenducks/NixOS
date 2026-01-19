{ config, pkgs, lib, ... }:

# Home Manager Configuration
# Following Tony Banters methodology: https://github.com/tonybanters/nixos-from-scratch
#
# This file manages user-level configuration:
# - Desktop entries (xdg.desktopEntries)
# - GTK/Qt theming
# - Shell configuration
# - User packages

{
  # Enable Home Manager
  programs.home-manager.enable = true;

  # ─────────────────────────────────────────────────────────────────
  # DESKTOP ENTRIES (Fix btop, hide foot server/client)
  # ─────────────────────────────────────────────────────────────────

  xdg.desktopEntries = {
    # Hide Foot Server - it's a daemon, not an application
    foot-server = {
      name = "Foot Server";
      exec = "${pkgs.foot}/bin/foot --server";
      icon = "foot";
      terminal = false;
      noDisplay = true;
    };

    # Hide Foot Client - rarely used manually
    foot-client = {
      name = "Foot Client";
      exec = "${pkgs.foot}/bin/footclient";
      icon = "foot";
      terminal = false;
      noDisplay = true;
    };

    # Fix btop++ launcher - explicitly runs in foot terminal
    btop = {
      name = "btop++";
      genericName = "System Monitor";
      comment = "Resource monitor with graphs for CPU, memory, disks, network";
      icon = "utilities-system-monitor";
      exec = "${pkgs.foot}/bin/foot -e btop";
      terminal = false;
      categories = [ "System" "Monitor" "ConsoleOnly" ];
    };
  };

  # ─────────────────────────────────────────────────────────────────
  # GTK / QT THEMING
  # ─────────────────────────────────────────────────────────────────

  gtk = {
    enable = true;
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    theme = {
      name = "Catppuccin-Mocha";
      package = pkgs.catppuccin-gtk;
    };
  };

  qt = {
    enable = true;
    platformTheme = "gtk";
  };

  # ─────────────────────────────────────────────────────────────────
  # SESSION VARIABLES
  # ─────────────────────────────────────────────────────────────────

  home.sessionVariables = {
    GTK_ICON_THEME = "Papirus-Dark";
  };

  # ─────────────────────────────────────────────────────────────────
  # USER PACKAGES
  # ─────────────────────────────────────────────────────────────────

  home.packages = with pkgs; [
    # GUI apps that aren't in system config
    # (Add more here as needed)
  ];

  # ─────────────────────────────────────────────────────────────────
  # STATE VERSION
  # ─────────────────────────────────────────────────────────────────

  home.stateVersion = "25.11";
}
