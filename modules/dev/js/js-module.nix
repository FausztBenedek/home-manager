{ config, lib, pkgs, stdenv, fetchFromGitHub, ... }:
let
  nodeDependencies = (pkgs.callPackage ./node-packages/default.nix { }).nodeDependencies;
in
{
  options = {
    option.dev.js.enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enabled developer tools for javascript";
      default = false;
    };
  };
  config = lib.mkIf config.option.dev.js.enable {
    option.dev.js.nvm.enable = true;
    home.sessionVariables = {
      NODE_DEPENDENCIES_INSTALLED_BY_NIX = nodeDependencies;
    };
    home.packages = [
      (pkgs.callPackage ./node-packages/default.nix { }).nodeDependencies
    ];
  };

}
