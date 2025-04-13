{
  description = "Home Manager configuration of benedekfauszt";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    private-configs.url = "git+ssh://git@github.com/FausztBenedek/sensitive-nix-config?ref=master";
  };

  outputs = { self, nixpkgs, home-manager, private-configs, ... }:
    let

      forAllSystems = nixpkgs.lib.genAttrs [
        "aarch64-darwin"
        "x86_64-linux"
        "aarch64-linux"
      ];

    in
    {
      packages = forAllSystems (system: {
        homeConfigurations.default = home-manager.lib.homeManagerConfiguration
          {
            pkgs = nixpkgs.legacyPackages.${system};
            extraSpecialArgs = { inherit self; };
            modules = [
              ./modules
              ./default-options.nix
            ];
          };
      });

      homeConfigurations = {
        "kn" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          extraSpecialArgs = { inherit self; };
          modules = [
            ./modules
            private-configs.kn
          ];
        };
        "private" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          extraSpecialArgs = { inherit self; };
          modules = [
            ./modules
            private-configs.private
          ];
        };
        "nixos-setup" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit self; }; # TODO Is this needed?
          modules = [
            ./modules
            private-configs.nixos-setup
          ];
        };

      };
    };
}
