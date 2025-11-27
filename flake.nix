{
  description = "Home Manager configuration of benedekfauszt";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    private-configs.url = "git+ssh://git@github.com/FausztBenedek/sensitive-nix-config?ref=master";
    benedek-neovim-flake.url = "github:FausztBenedek/nvim-flake";
  };

  outputs = { self, nixpkgs, home-manager, private-configs, ... }@inputs:
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
            extraSpecialArgs = { inherit self; inherit inputs; inherit system; };
            modules = [
              ./modules
              ./default-options.nix
            ];
          };
      });

      homeConfigurations = {
        "fcb" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          extraSpecialArgs = { inherit self; inherit inputs; system = "aarch64-darwin"; };
          modules = [
            ./modules
            private-configs.fcb
          ];
        };
        "kn" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          extraSpecialArgs = { inherit self; inherit inputs; system = "aarch64-darwin"; };
          modules = [
            ./modules
            private-configs.kn
          ];
        };
        "private" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.aarch64-darwin;
          extraSpecialArgs = { inherit self; inherit inputs; system = "aarch64-darwin"; };
          modules = [
            ./modules
            private-configs.private
          ];
        };
        "nixos-setup" = home-manager.lib.homeManagerConfiguration {
          pkgs = nixpkgs.legacyPackages.x86_64-linux;
          extraSpecialArgs = { inherit self; inherit inputs; system = "x86_64-linux"; };
          modules = [
            ./modules
            private-configs.nixos-setup
          ];
        };

      };
    };
}
