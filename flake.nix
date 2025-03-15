{
  description = "Home Manager configuration of benedekfauszt";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ... }:
    let
      forAllSystems = function:
        nixpkgs.lib.genAttrs [
          "x86_64-linux"
          "aarch64-linux"
          "aarch64-darwin"
        ]
          (system: function nixpkgs.legacyPackages.${system});

    in
    {

      homeManagerModules = import ./modules/index.nix;
      homeConfigurations."default" = forAllSystems (pkgs: home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit self; };
        modules = [
          ./modules/index.nix
          ./default-options.nix
        ];
      });
    };
}
