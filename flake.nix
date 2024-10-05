{
  description = "Your new nix config";

  inputs = {
    # Nixpkgs
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";

    # Home manager
    home-manager.url = "github:nix-community/home-manager/release-23.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # Firefox browser addons
    nur.url = "github:nix-community/NUR";

    alacritty-theme.url = "github:alexghr/alacritty-theme.nix";
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";

    neovim-flake = {
      url = github:gvolpe/neovim-flake;
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... } @ inputs: 
  let
    inherit (self) outputs;
    system = "x86_64-linux";
  in {
    nixosConfigurations = {
      julrod-nix-desktop = nixpkgs.lib.nixosSystem {
        specialArgs = {inherit inputs outputs;};
        # > Our main nixos configuration file <
        modules = [./nixos/configuration.nix];
      };
    };

    homeConfigurations = {
      "julrod@julrod-nix-desktop" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.${system}; # Home-manager requires 'pkgs' instance
        extraSpecialArgs = { inherit inputs outputs ;};
        # > Our main home-manager configuration file <
        modules = [ ./home-manager/home.nix ];
      };
    };
  };
}
