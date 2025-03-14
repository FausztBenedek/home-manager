{ config, pkgs, lib, ... }:
let
  gw = pkgs.callPackage ./gw-derivation.nix { };
in
{
  options = {
    option.dev.java.enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enable tools for kubernetes";
      default = false;
    };
  };
  config = lib.mkIf config.option.dev.java.enable {
    home.packages = [
      gw
    ];
  };

}
