{ config, pkgs, inputs, ... }:

{
  # Machine-specific hardware (stays in /etc/nixos/, NOT in flake)
  imports = [
    ./hardware-configuration.nix
    # Import rest of config from your git repo (Tony Banters pattern)
    (builtins.fetchTarball "https://github.com/stolenducks/NixOS/archive/main.tar.gz" + "/configuration.nix")
  ];
}
