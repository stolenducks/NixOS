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

    # Bluetooth - TUI manager (replaces blueman)
    bluetooth = {
      name = "Bluetooth";
      genericName = "Bluetooth Manager";
      comment = "Manage Bluetooth devices";
      icon = "bluetooth";
      exec = "${pkgs.foot}/bin/foot -e bluetui";
      terminal = false;
      categories = [ "Settings" "HardwareSettings" ];
    };

    # Hide Bluetui entry (replaced by bluetooth entry)
    bluetui = {
      name = "Bluetui";
      exec = "true";
      noDisplay = true;
      settings.Hidden = "true";
    };

    # Burn ISO - guided flow then Caligula
    burn-iso = {
      name = "Burn ISO";
      genericName = "Disk Imager";
      comment = "Download, select, and burn ISO images";
      icon = "drive-removable-media";
      exec = "${pkgs.foot}/bin/foot -e burn-iso";
      terminal = false;
      categories = [ "System" "Utility" ];
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
    (writeShellApplication {
      name = "burn-iso";
      runtimeInputs = [ gum fd fzf curl caligula coreutils ];
      text = ''
        set -euo pipefail

        downloads_dir="$HOME/Downloads"
        if [ ! -d "$downloads_dir" ]; then
          gum style --foreground 1 "Downloads directory not found: $downloads_dir"
          exit 1
        fi

        gum style --bold "Burn ISO"
        gum style "Step 1: Download an ISO (optional)"

        if gum confirm "Download an ISO from a URL?"; then
          url=$(gum input --placeholder "https://example.com/image.iso" --prompt "ISO URL: ")
          if [ -z "$url" ]; then
            gum style --foreground 1 "No URL provided."
            exit 1
          fi

          filename=$(basename "$url")
          if [ -z "$filename" ]; then
            gum style --foreground 1 "Could not determine filename from URL."
            exit 1
          fi

          output_path="$downloads_dir/$filename"
          gum spin --title "Downloading ISO..." -- curl -L --progress-bar -o "$output_path" "$url"
          gum style --foreground 2 "Downloaded to: $output_path"
        fi

        gum style "Step 2: Select an ISO file"
        iso=$(fd -i --hidden -e iso -e img -e bin -e raw -e dmg -e udf . "$HOME" --exclude .git --exclude .cache --exclude .local/share/Trash | sort -r | fzf --prompt "Select image: " --delimiter / --with-nth -1 --preview 'ls -lh {}' --height 40% --border || true)

        if [ -z "$iso" ]; then
          gum style --foreground 1 "No ISO selected (no .iso files found under $downloads_dir)."
          exit 1
        fi

        gum style --bold "Selected ISO:"
        gum style "$iso"

        if ! gum confirm "Proceed to Caligula to burn this ISO?"; then
          exit 0
        fi

        exec caligula burn "$iso"
      '';
    })
  ];

  # ─────────────────────────────────────────────────────────────────
  # STATE VERSION
  # ─────────────────────────────────────────────────────────────────

  home.stateVersion = "25.11";
}
