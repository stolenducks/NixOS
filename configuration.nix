# ╔══════════════════════════════════════════════════════════════════╗
# ║  NixOS Configuration                                              ║
# ║  Host: nixos                                                      ║
# ║  Desktop: Niri + Noctalia                                         ║
# ║  Login: Auto-login + Swaylock                                     ║
# ╚══════════════════════════════════════════════════════════════════╝

{ config, pkgs, inputs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    # Custom modules (Tony Banters style - modular, shareable)
    ./modules/file-manager.nix
    ./modules/system-tools.nix
    ./modules/device-services.nix
  ];

  # ─────────────────────────────────────────────────────────────────
  # SYSTEM
  # ─────────────────────────────────────────────────────────────────

  system.stateVersion = "25.11";
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nixpkgs.config.allowUnfree = true;

  # ─────────────────────────────────────────────────────────────────
  # BOOT + PLYMOUTH (Silent Boot)
  # ─────────────────────────────────────────────────────────────────

  boot = {
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
    loader.timeout = 0;

    # Plymouth - clean boot/shutdown splash
    plymouth = {
      enable = true;
      theme = "spinner";  # Simple spinner, no extra logos
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
      "systemd.show_status=false"   # Hide systemd status completely
      "rd.systemd.show_status=false"
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

  # Fix "import-environment without a list" warning
  # Properly import environment variables into systemd user session
  systemd.user.services.import-environment = {
    description = "Import environment variables for systemd user session";
    wantedBy = [ "default.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl --user import-environment PATH WAYLAND_DISPLAY XDG_CURRENT_DESKTOP";
    };
  };

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

  programs.localsend.enable = true;

  services.printing.enable = true;
  services.openssh.enable = true;

  # ─────────────────────────────────────────────────────────────────
  # MODULES (Tony Banters style)
  # ─────────────────────────────────────────────────────────────────

  # GUI File Manager (Nautilus)
  modules.file-manager.enable = true;

  # System Tools (btop fix, foot hiding)
  modules.system-tools.enable = true;
  modules.system-tools.hideFootServer = true;
  modules.system-tools.fixBtop = true;

  # Device Services (udisks2, GVfs, polkit for automount)
  modules.device-services.enable = true;
  modules.device-services.automountWithoutPassword = true;

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
      # nh commands (better UX than raw nixos-rebuild)
      rebuild = "nh os switch";           # Rebuild with diff preview
      rebuild-boot = "nh os boot";        # Rebuild, apply on next boot
      search = "nh search";               # Search packages interactively
      clean = "nh clean all --keep 5";    # Clean old generations, keep 5
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
    inputs.noctalia.packages.${pkgs.stdenv.hostPlatform.system}.default
    inputs.llm-agents.packages.${pkgs.stdenv.hostPlatform.system}.opencode
    nh  # Better nixos-rebuild UX with diff, search, clean
    zed-editor
    superfile
    foot
    ripgrep fd eza bat fzf zoxide starship tldr jq tree superfile nixd ventoy-full
    fishPlugins.fzf-fish
    fishPlugins.done
    fishPlugins.autopair
    btop fastfetch ncdu
    wget curl unzip p7zip trash-cli
    wl-clipboard cliphist grim slurp hyprlock
    xwayland-satellite
    obsidian
    hicolor-icon-theme papirus-icon-theme adwaita-icon-theme
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
  ];

  nixpkgs.config.permittedInsecurePackages = [
    "ventoy-1.1.10"
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
