{ config, pkgs, lib, ... }: 
{
  options = {
    option.mac.maccy.enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enable Maccy on mac";
      default = false;
    };

  };
  config = lib.mkIf config.option.mac.maccy.enable {
    home.packages = with pkgs; [
      maccy
    ];
  };

}
