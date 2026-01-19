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
    platformTheme.name = "gtk";
  };

  # ─────────────────────────────────────────────────────────────────
  # SESSION VARIABLES
  # ─────────────────────────────────────────────────────────────────

  home.sessionVariables = {
    GTK_ICON_THEME = "Papirus-Dark";
  };

  # ─────────────────────────────────────────────────────────────────
  # HYPRLOCK (Lock Screen) - Ultra minimal for fast load
  # ─────────────────────────────────────────────────────────────────

  xdg.configFile."hypr/hyprlock.conf".text = ''
    general {
      disable_loading_bar = true
      immediate_render = true
      no_fade_in = true
      no_fade_out = true
      grace = 0
    }

    background {
      monitor =
      color = rgb(30, 30, 46)
    }

    input-field {
      monitor =
      size = 300, 50
      outline_thickness = 0
      dots_size = 0.25
      dots_spacing = 0.15
      dots_center = true
      outer_color = rgb(30, 30, 46)
      inner_color = rgb(69, 71, 90)
      font_color = rgb(205, 214, 244)
      fade_on_empty = false
      fade_timeout = 0
      placeholder_text =
      hide_input = false
      rounding = 8
      position = 0, 0
      halign = center
      valign = center
    }
  '';

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
