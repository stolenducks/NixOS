# ╔══════════════════════════════════════════════════════════════════╗
# ║  NixOS Configuration                                              ║
# ║  Host: nixos                                                      ║
# ║  Desktop: Niri + Noctalia                                         ║
# ║  Login: Auto-login + Swaylock                                     ║
# ╚══════════════════════════════════════════════════════════════════╝

{ config, pkgs, inputs, ... }:

{
  imports = [
    /etc/nixos/hardware-configuration.nix
  ];

  # ─────────────────────────────────────────────────────────────────
  # SYSTEM
  # ─────────────────────────────────────────────────────────────────

  system.stateVersion = "25.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # ─────────────────────────────────────────────────────────────────
  # BOOT + PLYMOUTH (Silent Boot)
  # Reference: https://wiki.nixos.org/wiki/Plymouth
  # ─────────────────────────────────────────────────────────────────

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.timeout = 0;  # Hide boot menu (press key to show)

    # Plymouth boot splash
    plymouth.enable = true;

    # Silent boot - hide all messages
    consoleLogLevel = 0;
    initrd.verbose = false;
    initrd.systemd.enable = true;  # Smoother Plymouth transition
    kernelParams = [
      "quiet"
      "splash"
      "loglevel=3"
      "udev.log_level=3"
      "rd.udev.log_level=3"
      "systemd.show_status=auto"
      "rd.systemd.show_status=auto"
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
  # LOGIN: greetd Auto-login
  # Reference: https://wiki.nixos.org/wiki/Greetd
  # ─────────────────────────────────────────────────────────────────

  services.greetd = {
    enable = true;
    settings = {
      default_session = {
        command = "${pkgs.niri}/bin/niri-session";
        user = "dolandstutts";
      };
    };
  };

  # Prevent greetd TTY spam on shutdown
  systemd.services.greetd.serviceConfig = {
    Type = "idle";
    StandardInput = "tty";
    StandardOutput = "tty";
    StandardError = "journal";
    TTYReset = true;
    TTYVHangup = true;
    TTYVTDisallocate = true;
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
  services.blueman.enable = true;
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

  services.printing.enable = true;
  services.openssh.enable = true;

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
      zoxide init fish | source
    '';
    shellAliases = {
      ls = "eza --icons";
      ll = "eza -la --icons";
      lt = "eza --tree --icons";
      cat = "bat";
      grep = "rg";
      find = "fd";
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

  programs.firefox.enable = true;
  programs.git.enable = true;

  # ─────────────────────────────────────────────────────────────────
  # PACKAGES
  # ─────────────────────────────────────────────────────────────────

  environment.systemPackages = with pkgs; [
    # Noctalia Shell
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default

    # AI Coding Agents
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode

    # Editors
    zed-editor

    # File Manager
    superfile

    # Terminal
    foot

    # CLI Tools
    ripgrep fd eza bat fzf zoxide starship tldr jq tree superfile nixd

    # Fish Plugins
    fishPlugins.fzf-fish
    fishPlugins.done
    fishPlugins.autopair

    # System Monitoring
    btop fastfetch ncdu

    # File Management
    wget curl unzip p7zip trash-cli

    # Wayland Utilities
    wl-clipboard cliphist grim slurp hyprlock

    # XWayland
    xwayland-satellite

    # Productivity
    obsidian

    # Theming
    hicolor-icon-theme papirus-icon-theme adwaita-icon-theme

    # Fonts
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
  # CUSTOM DESKTOP ENTRIES
  # ─────────────────────────────────────────────────────────────────

  environment.etc."xdg/applications/superfile.desktop".text = ''
    [Desktop Entry]
    Name=Superfile
    Comment=Modern terminal file manager
    Exec=foot superfile
    Icon=system-file-manager
    Terminal=false
    Type=Application
    Categories=System;FileTools;FileManager;
  '';

  environment.etc."xdg/applications/opencode.desktop".text = ''
    [Desktop Entry]
    Name=OpenCode
    Comment=AI coding agent
    Exec=foot opencode
    Icon=code
    Terminal=false
    Type=Application
    Categories=Development;IDE;
  '';

  # ─────────────────────────────────────────────────────────────────
  # XDG PORTAL
  # ─────────────────────────────────────────────────────────────────

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

}
