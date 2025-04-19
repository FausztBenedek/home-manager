{ config, lib, ... }:
{
  options = {
    option.linux.compositor.rofi = lib.mkEnableOption "Use hyprland as compositor";
    option.linux.compositor.rofi-location = lib.mkOption {
      type = lib.types.path;
      description = ''
        The location of the rofi configuration. It defaults to copying the config to the store,
        and symlinking there. If it is set, chainging the rofi config has immediate effect.
        If it is left default, home-manager switch is needed beforehand.
      '';
      default = ./rofi-config;
    };
  };
  config = lib.mkIf config.option.linux.compositor.rofi { 
    # Hyprland stuff is installed by my nixos configuration;
    home.file = {
      ".config/rofi".source = config.lib.file.mkOutOfStoreSymlink config.option.linux.compositor.rofi-location;
    };
  };
}
