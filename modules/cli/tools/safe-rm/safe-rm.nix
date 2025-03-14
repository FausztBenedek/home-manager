{ config, lib, pkgs, ... }:
let
  safe-rm = pkgs.callPackage ./safe-rm-derivation.nix { };
in
{
  options = {
    option.cli.tools.safe-rm.enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enable tools cloud";
      default = false;
    };
  };
  config = lib.mkIf config.option.cli.tools.safe-rm.enable {
    home.packages = [
      safe-rm # I aliased this to `rm`
    ];
    home.shellAliases = {
      rm = "safe-rm";
    };
  };
}
