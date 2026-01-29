# ╔══════════════════════════════════════════════════════════════════╗
# ║  NixOS Configuration - ThinkPad X1 Carbon Gen 8                   ║
# ║  Host: nixos                                                      ║
# ║  Desktop: Niri + Noctalia                                         ║
# ║  Boot: Plymouth (Catppuccin) → greetd → Niri → Hyprlock           ║
# ╚══════════════════════════════════════════════════════════════════╝

{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # Custom modules (Tony Banters style - modular, shareable)
    ./modules/file-manager.nix
    ./modules/system-tools.nix
    ./modules/device-services.nix
    ./modules/office.nix
    ./modules/syncthing.nix
  ];

  # ─────────────────────────────────────────────────────────────────
  # SYSTEM
  # ─────────────────────────────────────────────────────────────────

  system.stateVersion = "25.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # ─────────────────────────────────────────────────────────────────
  # BOOT + PLYMOUTH (Silent Boot - Mac-style NixOS theme)
  # ─────────────────────────────────────────────────────────────────

  boot = {
    loader.systemd-boot = {
      enable = true;
      configurationLimit = 10;  # Keep last 10 generations
      editor = false;  # Disable kernel cmdline editing for security
    };
    loader.efi.canTouchEfiVariables = true;
    loader.timeout = 0;  # Hidden, Space key shows menu

    # Plymouth - Mac-style animated NixOS logo
    plymouth = {
      enable = true;
      theme = "mac-style";
      themePackages = [ pkgs.mac-style-plymouth ];
      extraConfig = ''
        [Daemon]
        ShowDelay=0
        DeviceTimeout=8
      '';
    };

    # Hide ALL boot/shutdown text
    consoleLogLevel = 0;
    initrd.verbose = false;
    initrd.systemd.enable = true;
    kernelParams = [
      "quiet"
      "splash"
      "loglevel=0"
      "udev.log_level=0"
      "rd.udev.log_level=0"
      "vt.global_cursor_default=0"  # Hide cursor
      "systemd.show_status=auto"    # Let Plymouth control status display
      "rd.systemd.show_status=false"
      "fbcon=nodefer"               # Prevent early framebuffer console
      "vt.handoff=7"                # Seamless Plymouth → compositor handoff
      "i915.fastboot=1"             # Intel GPU fast boot (ThinkPad X1)
    ];
  };



  # ─────────────────────────────────────────────────────────────────
  # NETWORKING
  # ─────────────────────────────────────────────────────────────────

  networking.hostName = "nixos";
  networking.networkmanager.enable = true;
  services.tailscale.enable = true;

  # ─────────────────────────────────────────────────────────────────
  # LOCALIZATION
  # ─────────────────────────────────────────────────────────────────

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT = "en_US.UTF-8";
    LC_MONETARY = "en_US.UTF-8";
    LC_NAME = "en_US.UTF-8";
    LC_NUMERIC = "en_US.UTF-8";
    LC_PAPER = "en_US.UTF-8";
    LC_TELEPHONE = "en_US.UTF-8";
    LC_TIME = "en_US.UTF-8";
  };

  # ─────────────────────────────────────────────────────────────────
  # LOGIN: greetd Auto-login (Seamless - No TTY flash)
  # ─────────────────────────────────────────────────────────────────

  services.greetd = {
    enable = true;
    restart = false;  # Don't restart on session exit (prevents re-autologin loop)
    settings = {
      # initial_session runs once at boot - bypasses greeter entirely
      # Redirect stderr to suppress "import-environment" warning
      initial_session = {
        command = "${pkgs.niri}/bin/niri-session 2>/dev/null";
        user = "dolandstutts";
      };
      # Fallback if initial_session exits (logout/crash)
      default_session = {
        command = "${pkgs.niri}/bin/niri-session 2>/dev/null";
        user = "dolandstutts";
      };
    };
  };

  # ─────────────────────────────────────────────────────────────────
  # DESKTOP: Niri
  # ─────────────────────────────────────────────────────────────────

  programs.niri.enable = true;
  programs.xwayland.enable = true;

  # ─────────────────────────────────────────────────────────────────
  # HARDWARE SERVICES
  # ─────────────────────────────────────────────────────────────────

  hardware.bluetooth.enable = true;
  # Bluetooth managed via bluetui TUI (no blueman)
  services.power-profiles-daemon.enable = true;
  services.upower.enable = true;

  # ─────────────────────────────────────────────────────────────────
  # AUDIO (PipeWire)
  # ─────────────────────────────────────────────────────────────────

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ─────────────────────────────────────────────────────────────────
  # OTHER SERVICES
  # ─────────────────────────────────────────────────────────────────

  programs.localsend.enable = true;

  services.printing.enable = true;
  services.openssh.enable = true;

  # ─────────────────────────────────────────────────────────────────
  # MODULES (Tony Banters style)
  # ─────────────────────────────────────────────────────────────────

  # GUI File Manager (Nautilus)
  modules.file-manager.enable = true;

  # System Tools (btop launcher fix)
  modules.system-tools.enable = true;
  modules.system-tools.fixBtop = true;

  # Device Services (udisks2, GVfs, polkit for automount)
  modules.device-services.enable = true;
  modules.device-services.automountWithoutPassword = true;

  # Office Applications (OnlyOffice)
  modules.office.enable = true;

  # Syncthing (File Synchronization)
  # Web UI: http://localhost:8384
  modules.syncthing.enable = true;

  # ─────────────────────────────────────────────────────────────────
  # USER
  # ─────────────────────────────────────────────────────────────────

  users.users.dolandstutts = {
    isNormalUser = true;
    description = "Doland Stutts";
    extraGroups = [ "networkmanager" "wheel" "video" "audio" ];
    shell = pkgs.fish;
  };

  # ─────────────────────────────────────────────────────────────────
  # SHELL: Fish + Starship
  # ─────────────────────────────────────────────────────────────────

  programs.fish = {
    enable = true;
    interactiveShellInit = ''
      set -g fish_greeting
      set -gx NH_FLAKE ~/NixOS  # Tell nh where your flake is
      zoxide init fish | source
    '';
    shellAliases = {
      ls = "eza --icons";
      ll = "eza -la --icons";
      lt = "eza --tree --icons";
      cat = "bat";
      grep = "rg";
      find = "fd";
      ff = "fastfetch";
      # nh commands with styled gum banners
      rebuild = "gum style --border thick --border-foreground 110 --foreground 255 --bold --padding '0 2' '󱄅 NixOS Rebuild' && nh os switch";
      rebuild-boot = "gum style --border thick --border-foreground 110 --foreground 255 --bold --padding '0 2' '󱄅 NixOS Boot' && nh os boot";
      search = "gum style --border thick --border-foreground 110 --foreground 255 --bold --padding '0 2' ' NixOS Search' && nh search";
      clean = "gum style --border thick --border-foreground 110 --foreground 255 --bold --padding '0 2' '󰃢 NixOS Clean' && nh clean all --keep 5";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      format = "$directory$git_branch$git_status$nix_shell$character";
      add_newline = false;
      character = {
        success_symbol = "[›](bold green)";
        error_symbol = "[›](bold red)";
      };
      directory = {
        style = "bold cyan";
        truncation_length = 3;
        truncate_to_repo = true;
      };
      git_branch = {
        symbol = " ";
        style = "bold purple";
      };
      git_status.style = "bold yellow";
      nix_shell = {
        symbol = " ";
        format = "[$symbol]($style)";
        style = "bold blue";
      };
      aws.disabled = true;
      gcloud.disabled = true;
      kubernetes.disabled = true;
      docker_context.disabled = true;
    };
  };

  # ─────────────────────────────────────────────────────────────────
  # PROGRAMS
  # ─────────────────────────────────────────────────────────────────

  programs.git.enable = true;

  # ─────────────────────────────────────────────────────────────────
  # PACKAGES
  # ─────────────────────────────────────────────────────────────────

  environment.systemPackages = with pkgs; [
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
    inputs.helium-browser.packages.${pkgs.stdenv.hostPlatform.system}.default
    nh  # Better nixos-rebuild UX with diff, search, clean
    zed-editor
    yazi
    ghostty
    ripgrep fd eza bat fzf gum zoxide starship tldr jq tree nixd
    fishPlugins.fzf-fish
    fishPlugins.done
    fishPlugins.autopair
    btop fastfetch ncdu feh
    fastmail-desktop  # Fastmail email client
    caligula      # TUI disk imager
    bluetui       # TUI bluetooth manager
    wget curl unzip p7zip trash-cli
    wl-clipboard cliphist grim slurp hyprlock
    xwayland-satellite
    obsidian
    hicolor-icon-theme papirus-icon-theme adwaita-icon-theme
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];



  # ─────────────────────────────────────────────────────────────────
  # FONTS
  # ─────────────────────────────────────────────────────────────────

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    noto-fonts
    noto-fonts-color-emoji
  ];

  # ─────────────────────────────────────────────────────────────────
  # XDG PORTAL
  # ─────────────────────────────────────────────────────────────────

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

}
