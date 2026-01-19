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
  # HYPRLOCK (Lock Screen)
  # ─────────────────────────────────────────────────────────────────

  xdg.configFile."hypr/hyprlock.conf".text = ''
    # Clean, minimal lock screen

    background {
      monitor =
      color = rgb(30, 30, 46)  # Solid dark background (Catppuccin base)
    }

    input-field {
      monitor =
      size = 250, 50
      outline_thickness = 2
      dots_size = 0.2
      dots_spacing = 0.2
      dots_center = true
      outer_color = rgb(137, 180, 250)  # Catppuccin blue
      inner_color = rgb(49, 50, 68)     # Catppuccin surface0
      font_color = rgb(205, 214, 244)   # Catppuccin text
      fade_on_empty = false             # ALWAYS show input field
      fade_timeout = 0
      placeholder_text =
      hide_input = false
      rounding = 10
      check_color = rgb(166, 227, 161)  # Catppuccin green
      fail_color = rgb(243, 139, 168)   # Catppuccin red
      fail_text = <i>$FAIL</i>
      fail_timeout = 2000
      position = 0, -20
      halign = center
      valign = center
    }

    label {
      monitor =
      text = $TIME
      color = rgba(205, 214, 244, 1.0)
      font_size = 64
      font_family = JetBrainsMono Nerd Font
      position = 0, 100
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
