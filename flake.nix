{
  description = "NixOS Configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    llm-agents = {
      url = "github:numtide/llm-agents.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
    };

    nixos-hardware = {
      url = "github:NixOS/nixos-hardware/master";
    };

    mac-style-plymouth = {
      url = "github:SergioRibera/s4rchiso-plymouth-theme";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager, noctalia, llm-agents, catppuccin, nixos-hardware, mac-style-plymouth, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        # ThinkPad X1 Carbon Gen 7/8 hardware optimizations (Gen 8 uses Gen 7 module)
        nixos-hardware.nixosModules.lenovo-thinkpad-x1-7th-gen

        # Catppuccin theming (for other apps, not Plymouth)
        catppuccin.nixosModules.catppuccin

        # Mac-style Plymouth overlay
        { nixpkgs.overlays = [ mac-style-plymouth.overlays.default ]; }

        # Main configuration (imports hardware-configuration.nix and custom modules)
        ./configuration.nix

        # Home Manager
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "backup";
          home-manager.users.dolandstutts = import ./home.nix;
        }
      ];
    };
  };
}
