{ config, pkgs, lib, ... }:
{
  options = {
    option.dev.java.enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enable tools for kubernetes";
      default = false;
    };
  };
  config = lib.mkIf config.option.dev.java.enable {
    home.packages = [ ];

    home.file.".zshrc.d/sdkman.zsh" = {
      # Sourcing sdkman related stuff
      text = ''
        source $HOME/.sdkman/bin/sdkman-init.sh
      '';
    };
  };

}
