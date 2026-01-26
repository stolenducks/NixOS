{ config, pkgs, lib, ... }:

# Home Manager Configuration
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
  # DESKTOP ENTRIES (TUI apps launched in Ghostty)
  # ─────────────────────────────────────────────────────────────────

  xdg.desktopEntries = {
    # Fix btop++ launcher - explicitly runs in ghostty terminal
    btop = {
      name = "Monitor";
      genericName = "System Monitor";
      comment = "Resource monitor with graphs for CPU, memory, disks, network";
      icon = "utilities-system-monitor";
      exec = "${pkgs.ghostty}/bin/ghostty -e btop";
      terminal = false;
      categories = [ "System" "Monitor" "ConsoleOnly" ];
    };

    # Bluetooth - TUI manager (replaces blueman)
    bluetooth = {
      name = "Bluetooth";
      genericName = "Bluetooth Manager";
      comment = "Manage Bluetooth devices";
      icon = "bluetooth";
      exec = "${pkgs.ghostty}/bin/ghostty -e bluetui";
      terminal = false;
      categories = [ "Settings" "HardwareSettings" ];
    };

    # Burn ISO guided flow then Caligula
    burn-iso = {
      name = "Burn ISO";
      genericName = "Disk Imager";
      comment = "Download, select, and burn ISO images";
      icon = "drive-removable-media";
      exec = "${pkgs.ghostty}/bin/ghostty -e burn-iso";
      terminal = false;
      categories = [ "System" "Utility" ];
    };

    # Yazi - Terminal file manager
    yazi = {
      name = "Yazi";
      genericName = "File Manager";
      comment = "Blazing fast terminal file manager";
      icon = "system-file-manager";
      exec = "${pkgs.ghostty}/bin/ghostty -e yazi";
      terminal = false;
      categories = [ "System" "FileTools" "FileManager" ];
    };

    # OpenCode - AI coding agent
    opencode = {
      name = "OpenCode";
      genericName = "AI Coding Agent";
      comment = "AI-powered coding assistant";
      icon = "code";
      exec = "${pkgs.ghostty}/bin/ghostty -e opencode";
      terminal = false;
      categories = [ "Development" "IDE" ];
    };

    # Helium Browser - with GTK theme and dark mode
    helium = {
      name = "Helium";
      genericName = "Web Browser";
      comment = "Privacy-focused Chromium browser";
      icon = "web-browser";
      exec = "helium --force-dark-mode --enable-features=WebUIDarkMode";
      terminal = false;
      categories = [ "Network" "WebBrowser" ];
    };

    # Override fastmail.desktop from package - rename to "Mail"
    # Key must match the package's .desktop filename to override it
    fastmail = {
      name = "Mail";
      genericName = "By Fastmail";
      comment = "Fastmail email client";
      icon = "fastmail";
      exec = "fastmail";
      terminal = false;
      categories = [ "Network" "Email" ];
    };

    # Override bluetui.desktop from package - hide it (we use "bluetooth" entry above)
    bluetui = {
      name = "Bluetui";
      exec = "bluetui";
      noDisplay = true;
      settings.Hidden = "true";
    };
  };

  # ─────────────────────────────────────────────────────────────────
  # GIT + GITHUB CLI
  # ─────────────────────────────────────────────────────────────────

  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "stolenducks";
        email = "stolenducks@pm.me";
      };
      init.defaultBranch = "main";
      push.autoSetupRemote = true;   # Auto-track upstream on first push
      pull.rebase = true;            # Rebase instead of merge on pull
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";          # Use SSH for security
      prompt = "enabled";            # Interactive prompts
      editor = "zed";                # Use Zed as editor
      aliases = {
        co = "pr checkout";          # gh co <pr-number>
        pv = "pr view";              # gh pv
        pc = "pr create";            # gh pc
        rc = "repo create";          # gh rc (for new projects)
        rv = "repo view --web";      # gh rv (open repo in browser)
        cl = "repo clone";           # gh cl <repo>
      };
    };
    gitCredentialHelper.enable = true;  # Auto git auth via gh
  };

  # ─────────────────────────────────────────────────────────────────
  # YAZI (Terminal File Manager)
  # ─────────────────────────────────────────────────────────────────

  programs.yazi = {
    enable = true;
    enableFishIntegration = true;
    settings = {
      mgr = {
        show_hidden = true;
        ratio = [0 3 7];  # 2 columns: 30% current, 70% preview
      };
      preview = {
        max_width = 4000;   # Large limit so images can scale with window
        max_height = 4000;  # Large limit so images can scale with window
      };
      opener = {
        edit = [
          { run = ''zeditor "$@"''; block = true; desc = "Zed"; for = "unix"; }
        ];
      };
    };
    # Theme: Reference Noctalia flavor + custom overrides
    theme = {
      # Reference the Noctalia flavor (provides base colors)
      flavor = {
        dark = "noctalia";
        light = "noctalia";
      };
      # Status bar - sharp angular separators (not rounded)
      status = {
        sep_left = { open = ""; close = ""; };
        sep_right = { open = ""; close = ""; };
      };
      # Tabs - sharp separators
      tabs = {
        sep_inner = { open = ""; close = ""; };
      };
      # Indicator - sharp rectangular selection (not rounded pill)
      indicator = {
        padding = { open = ""; close = ""; };
      };
      # Manager - solid hover highlighting
      mgr = {
        hovered = { fg = "#2e3440"; bg = "#8fbcbb"; bold = true; };
        preview_hovered = { underline = true; };
      };
      # Input - solid selection
      input = {
        selected = { fg = "#2e3440"; bg = "#88c0d0"; };
      };
      # Help menu
      help = {
        hovered = { fg = "#2e3440"; bg = "#8fbcbb"; bold = true; };
      };
      # Tasks
      tasks = {
        hovered = { fg = "#2e3440"; bg = "#8fbcbb"; bold = true; };
      };
    };
  };

  # ─────────────────────────────────────────────────────────────────
  # GTK / QT THEMING
  # ─────────────────────────────────────────────────────────────────

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    iconTheme = {
      name = "Papirus-Dark";
      package = pkgs.papirus-icon-theme;
    };
    gtk3.extraCss = ''
      /* Import noctalia dynamic colors */
      @import url("file:///home/dolandstutts/.config/gtk-3.0/noctalia.css");

      /* Sharp corners - no rounded edges */
      * {
        border-radius: 0;
      }
      window, dialog, popover, menu, tooltip {
        border-radius: 0;
      }
      button, entry, .linked > * {
        border-radius: 0;
      }
    '';
    gtk4.extraCss = ''
      /* Import noctalia dynamic colors */
      @import url("file:///home/dolandstutts/.config/gtk-4.0/noctalia.css");

      /* Sharp corners - no rounded edges */
      * {
        border-radius: 0;
      }
      window, dialog, popover, menu, tooltip {
        border-radius: 0;
      }
      button, entry, .linked > * {
        border-radius: 0;
      }
    '';
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
    GTK_THEME = "adw-gtk3-dark";
    EDITOR = "zeditor";
    VISUAL = "zeditor";
  };

  # ─────────────────────────────────────────────────────────────────
  # FASTFETCH (System Info)
  # ─────────────────────────────────────────────────────────────────

  xdg.configFile."fastfetch/config.jsonc".text = ''
    {
      "$schema": "https://github.com/fastfetch-cli/fastfetch/raw/master/doc/json_schema.json",
      "logo": { "type": "none" },
      "display": { "separator": " " },
      "modules": [
        { "type": "custom", "format": "{#white}▄▄▄▄  ▄ ▄   ▄  ▗▄▖  ▗▄▄▖{#}" },
        { "type": "custom", "format": "{#white}█   █ ▄  ▀▄▀  ▐▌ ▐▌▐▌{#}" },
        { "type": "custom", "format": "{#white}█   █ █ ▄▀ ▀▄ ▐▌ ▐▌ ▝▀▚▖{#}" },
        { "type": "custom", "format": "{#white}▄▄▄▄▄▄▄▄▄▄▄▄▄▄▞▘▄▞▘▗▄▄▞▘{#}" },
        { "key": "╭───────────╮", "type": "custom" },
        { "key": "│   user    │", "type": "title", "format": "{user-name}" },
        { "key": "│   hname   │", "type": "title", "format": "{host-name}" },
        { "key": "│   distro  │", "type": "os" },
        { "key": "│   kernel  │", "type": "kernel" },
        { "key": "│   uptime  │", "type": "uptime" },
        { "key": "│   shell   │", "type": "shell" },
        { "key": "│   pkgs    │", "type": "packages" },
        { "key": "│   memory  │", "type": "memory" },
        { "key": "├───────────┤", "type": "custom" },
        { "key": "│   colors  │", "type": "colors", "symbol": "circle" },
        { "key": "╰───────────╯", "type": "custom" }
      ]
    }
  '';

  # ─────────────────────────────────────────────────────────────────
  # HYPRLOCK (Lock Screen) - Optimized for boot-to-lock
  # ─────────────────────────────────────────────────────────────────

  xdg.configFile."hypr/hyprlock.conf".text = ''
    general {
      disable_loading_bar = true
      hide_cursor = true
      ignore_empty_input = true
      immediate_render = true
      no_fade_in = true
      no_fade_out = true
    }

    background {
      monitor =
      path = /home/dolandstutts/Pictures/Wallpapers/mojave-night.jpg
      # Fallback: Nord Polar Night
      color = rgb(46, 52, 64)
      blur_passes = 0
      contrast = 1.0
      brightness = 1.0
    }

    input-field {
      monitor =
      size = 300, 50
      outline_thickness = 2
      dots_size = 0.25
      dots_spacing = 0.3
      dots_center = true
      # Nord colors
      outer_color = rgb(143, 188, 187)
      inner_color = rgb(59, 66, 82)
      font_color = rgb(236, 239, 244)
      fade_on_empty = false
      hide_input = false
      placeholder_text = <i>Password...</i>
      rounding = 8
      position = 0, -100
      halign = center
      valign = center
    }

    # Time display (12-hour format)
    label {
      monitor =
      text = cmd[update:1000] echo "$(date +'%-I:%M %p')"
      color = rgb(236, 239, 244)
      font_size = 72
      font_family = JetBrainsMono Nerd Font
      position = 0, 100
      halign = center
      valign = center
    }

    # Date display
    label {
      monitor =
      text = cmd[update:60000] echo "$(date '+%A, %B %d')"
      color = rgb(216, 222, 233)
      font_size = 18
      font_family = JetBrainsMono Nerd Font
      position = 0, 40
      halign = center
      valign = center
    }
  '';

  # ─────────────────────────────────────────────────────────────────
  # GHOSTTY (Terminal Emulator)
  # ─────────────────────────────────────────────────────────────────

  xdg.configFile."ghostty/config" = {
    force = true;  # Overwrite existing file without backup (fixes HM clobber errors)
    text = ''
    # Font
    font-family = "JetBrainsMono Nerd Font"
    font-size = 9

    # Theme - managed by Noctalia (dynamic theming)
    theme = "noctalia"

    # Window
    window-padding-x = 10
    window-padding-y = 10
    window-decoration = false
    gtk-titlebar = false

    # Cursor
    cursor-style = bar
    cursor-style-blink = false

    # Shell integration
    shell-integration = fish

    # Scrollback
    scrollback-limit = 10000

    # Clipboard
    copy-on-select = true
    clipboard-paste-protection = false

    # Keybindings
    keybind = ctrl+shift+c=copy_to_clipboard
    keybind = ctrl+shift+v=paste_from_clipboard
    keybind = ctrl+shift+n=new_window
    keybind = ctrl+plus=increase_font_size:1
    keybind = ctrl+minus=decrease_font_size:1
    keybind = ctrl+zero=reset_font_size

    # Background opacity (subtle transparency)
    background-opacity = 0.95

    # Shader - cursor blaze with Nord colors (cyan/blue trail)
    # Custom: ~/.config/ghostty/shaders/  Community: ~/.config/ghostty/shaders-community/
    custom-shader = ~/.config/ghostty/shaders/cursor_blaze_nord.glsl
  '';
  };

  # CRT shader for Ghostty (optional - uncomment custom-shader above to enable)
  xdg.configFile."ghostty/shaders/crt.glsl".text = ''
    // CRT Shader - Subtle scanlines effect
    // Based on ghostty-shaders community collection

    void mainImage(out vec4 fragColor, in vec2 fragCoord) {
        vec2 uv = fragCoord.xy / iResolution.xy;

        // Sample the terminal texture
        vec4 color = texture(iChannel0, uv);

        // Subtle scanline effect
        float scanline = sin(fragCoord.y * 1.5) * 0.02;
        color.rgb -= scanline;

        // Very subtle vignette
        float vignette = 1.0 - length(uv - 0.5) * 0.3;
        color.rgb *= vignette;

        fragColor = color;
    }
  '';

  # ─────────────────────────────────────────────────────────────────
  # NIRI (Managed config)
  # ─────────────────────────────────────────────────────────────────

  xdg.configFile."niri/config.kdl".text = ''
    // ╔══════════════════════════════════════════════════════════════════╗
    // ║  Niri Configuration                                               ║
    // ║  Shell: Noctalia                                                  ║
    // ╚══════════════════════════════════════════════════════════════════╝

    // ─────────────────────────────────────────────────────────────────
    // INPUT
    // ─────────────────────────────────────────────────────────────────

    input {
        keyboard {
            xkb {
                layout "us"
            }
        }

        touchpad {
            tap
            natural-scroll
            click-method "clickfinger"
        }

        mouse {
        }

        warp-mouse-to-focus
        focus-follows-mouse max-scroll-amount="0%"
    }

    // ─────────────────────────────────────────────────────────────────
    // LAYOUT
    // ─────────────────────────────────────────────────────────────────

    layout {
        gaps 10

        center-focused-column "never"

        preset-column-widths {
            proportion 0.33333
            proportion 0.5
            proportion 0.66667
        }

        default-column-width { proportion 0.5; }

        focus-ring {
            width 3
            active-color "#7fc8ff"
            inactive-color "#505050"
        }

        border {
            off
        }

        shadow {
            on
        }
    }

    // ─────────────────────────────────────────────────────────────────
    // ENVIRONMENT
    // ─────────────────────────────────────────────────────────────────

    environment {
        NIXOS_OZONE_WL "1"
        XDG_CURRENT_DESKTOP "niri"
    }

    // ─────────────────────────────────────────────────────────────────
    // STARTUP (Hyprlock first for boot-to-lock-screen)
    // ─────────────────────────────────────────────────────────────────

    spawn-at-startup "hyprlock" "--immediate" "--no-fade-in"
    spawn-at-startup "xwayland-satellite"
    spawn-at-startup "noctalia-shell"

    // ─────────────────────────────────────────────────────────────────
    // APPEARANCE
    // ─────────────────────────────────────────────────────────────────

    cursor {
        xcursor-theme "Adwaita"
        xcursor-size 24
    }

    hotkey-overlay {
        skip-at-startup
    }

    prefer-no-csd

    screenshot-path "~/Pictures/Screenshots/Screenshot %Y-%m-%d %H-%M-%S.png"

    // ─────────────────────────────────────────────────────────────────
    // WINDOW RULES
    // ─────────────────────────────────────────────────────────────────

    window-rule {
        match app-id="dev.zed.Zed"
        geometry-corner-radius 0
        draw-border-with-background true
    }

    window-rule {
        match app-id=r#"firefox$"# title="^Picture-in-Picture$"
        open-floating true
    }

    window-rule {
        match app-id="Fastmail"
        open-maximized true
    }

    window-rule {
        geometry-corner-radius 0
        clip-to-geometry true
    }

    // ─────────────────────────────────────────────────────────────────
    // KEY BINDINGS
    // ─────────────────────────────────────────────────────────────────

    binds {
        // ── Applications ────────────────────────────────────────────
        Mod+Return { spawn "ghostty"; }
        Mod+Space { spawn "noctalia-shell" "ipc" "call" "launcher" "toggle"; }
        Mod+D { spawn "noctalia-shell" "ipc" "call" "launcher" "toggle"; }
        Mod+E { spawn "zeditor"; }

        // ── Noctalia Panels ─────────────────────────────────────────
        Mod+Escape { spawn "noctalia-shell" "ipc" "call" "sessionMenu" "toggle"; }
        Mod+N { spawn "noctalia-shell" "ipc" "call" "notificationHistory" "toggle"; }

        // ── Hotkey Help ─────────────────────────────────────────────
        Mod+Shift+Slash { show-hotkey-overlay; }

        // ── Window Management ───────────────────────────────────────
        Mod+Q { close-window; }
        Mod+W { close-window; }

        // ── Focus ───────────────────────────────────────────────────
        Mod+Left  { focus-column-left; }
        Mod+Down  { focus-window-down; }
        Mod+Up    { focus-window-up; }
        Mod+Right { focus-column-right; }
        Mod+H     { focus-column-left; }
        Mod+J     { focus-window-down; }
        Mod+K     { focus-window-up; }
        Mod+L     { focus-column-right; }

        // ── Move Windows ────────────────────────────────────────────
        Mod+Ctrl+Left  { move-column-left; }
        Mod+Ctrl+Down  { move-window-down; }
        Mod+Ctrl+Up    { move-window-up; }
        Mod+Ctrl+Right { move-column-right; }
        Mod+Ctrl+H     { move-column-left; }
        Mod+Ctrl+J     { move-window-down; }
        Mod+Ctrl+K     { move-window-up; }
        Mod+Ctrl+L     { move-column-right; }

        // ── First/Last Column ───────────────────────────────────────
        Mod+Home { focus-column-first; }
        Mod+End  { focus-column-last; }
        Mod+Ctrl+Home { move-column-to-first; }
        Mod+Ctrl+End  { move-column-to-last; }

        // ── Monitor Focus ───────────────────────────────────────────
        Mod+Shift+Left  { focus-monitor-left; }
        Mod+Shift+Down  { focus-monitor-down; }
        Mod+Shift+Up    { focus-monitor-up; }
        Mod+Shift+Right { focus-monitor-right; }
        Mod+Shift+H     { focus-monitor-left; }
        Mod+Shift+J     { focus-monitor-down; }
        Mod+Shift+K     { focus-monitor-up; }
        Mod+Shift+L     { focus-monitor-right; }

        // ── Move to Monitor ─────────────────────────────────────────
        Mod+Shift+Ctrl+Left  { move-column-to-monitor-left; }
        Mod+Shift+Ctrl+Down  { move-column-to-monitor-down; }
        Mod+Shift+Ctrl+Up    { move-column-to-monitor-up; }
        Mod+Shift+Ctrl+Right { move-column-to-monitor-right; }
        Mod+Shift+Ctrl+H     { move-column-to-monitor-left; }
        Mod+Shift+Ctrl+J     { move-column-to-monitor-down; }
        Mod+Shift+Ctrl+K     { move-column-to-monitor-up; }
        Mod+Shift+Ctrl+L     { move-column-to-monitor-right; }

        // ── Workspaces ──────────────────────────────────────────────
        Mod+Page_Down { focus-workspace-down; }
        Mod+Page_Up   { focus-workspace-up; }
        Mod+U         { focus-workspace-down; }
        Mod+I         { focus-workspace-up; }

        Mod+Ctrl+Page_Down { move-column-to-workspace-down; }
        Mod+Ctrl+Page_Up   { move-column-to-workspace-up; }
        Mod+Ctrl+U         { move-column-to-workspace-down; }
        Mod+Ctrl+I         { move-column-to-workspace-up; }

        Mod+Shift+Page_Down { move-workspace-down; }
        Mod+Shift+Page_Up   { move-workspace-up; }
        Mod+Shift+U         { move-workspace-down; }
        Mod+Shift+I         { move-workspace-up; }

        Mod+1 { focus-workspace 1; }
        Mod+2 { focus-workspace 2; }
        Mod+3 { focus-workspace 3; }
        Mod+4 { focus-workspace 4; }
        Mod+5 { focus-workspace 5; }
        Mod+6 { focus-workspace 6; }
        Mod+7 { focus-workspace 7; }
        Mod+8 { focus-workspace 8; }
        Mod+9 { focus-workspace 9; }

        Mod+Ctrl+1 { move-column-to-workspace 1; }
        Mod+Ctrl+2 { move-column-to-workspace 2; }
        Mod+Ctrl+3 { move-column-to-workspace 3; }
        Mod+Ctrl+4 { move-column-to-workspace 4; }
        Mod+Ctrl+5 { move-column-to-workspace 5; }
        Mod+Ctrl+6 { move-column-to-workspace 6; }
        Mod+Ctrl+7 { move-column-to-workspace 7; }
        Mod+Ctrl+8 { move-column-to-workspace 8; }
        Mod+Ctrl+9 { move-column-to-workspace 9; }

        // ── Column/Window Operations ────────────────────────────────
        Mod+Comma  { consume-window-into-column; }
        Mod+Period { expel-window-from-column; }

        Mod+BracketLeft  { consume-or-expel-window-left; }
        Mod+BracketRight { consume-or-expel-window-right; }

        // ── Sizing ──────────────────────────────────────────────────
        Mod+R { switch-preset-column-width; }
        Mod+Shift+R { switch-preset-window-height; }
        Mod+Ctrl+R { reset-window-height; }
        Mod+F { maximize-column; }
        Mod+Shift+F { fullscreen-window; }
        Mod+C { center-column; }

        Mod+Minus { set-column-width "-10%"; }
        Mod+Equal { set-column-width "+10%"; }
        Mod+Shift+Minus { set-window-height "-10%"; }
        Mod+Shift+Equal { set-window-height "+10%"; }

        // ── Floating ────────────────────────────────────────────────
        Mod+V       { toggle-window-floating; }
        Mod+Shift+V { switch-focus-between-floating-and-tiling; }

        // ── Screenshots ─────────────────────────────────────────────
        Print { screenshot; }
        Ctrl+Print { screenshot-screen; }
        Alt+Print { screenshot-window; }

        // ── Media Keys ──────────────────────────────────────────────
        XF86AudioRaiseVolume allow-when-locked=true { spawn "noctalia-shell" "ipc" "call" "volume" "increase"; }
        XF86AudioLowerVolume allow-when-locked=true { spawn "noctalia-shell" "ipc" "call" "volume" "decrease"; }
        XF86AudioMute        allow-when-locked=true { spawn "noctalia-shell" "ipc" "call" "volume" "muteOutput"; }
        XF86AudioMicMute     allow-when-locked=true { spawn "noctalia-shell" "ipc" "call" "volume" "muteInput"; }

        XF86MonBrightnessUp   allow-when-locked=true { spawn "noctalia-shell" "ipc" "call" "brightness" "increase"; }
        XF86MonBrightnessDown allow-when-locked=true { spawn "noctalia-shell" "ipc" "call" "brightness" "decrease"; }

        // ── Session ─────────────────────────────────────────────────
        Mod+Shift+E { quit; }
        Mod+Shift+P { power-off-monitors; }
        Mod+O { toggle-overview; }
    }

    include "./noctalia.kdl"
  '';

  # Note: noctalia.kdl is managed by noctalia-shell itself (dynamic theming)
  # Only config.kdl is managed by Home Manager - it includes noctalia.kdl

  # ─────────────────────────────────────────────────────────────────
  # USER SERVICES
  # ─────────────────────────────────────────────────────────────────

  # Note: Hyprlock autostart is now handled via Niri's spawn-at-startup
  # in the niri config above. This is cleaner and more reliable than
  # a systemd service that waits for Noctalia wallpaper state.

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
