{ config, lib, ... }:
{
  options = {
    option.linux.compositor.hyprland = lib.mkEnableOption "Use hyprland as compositor";
    option.linux.compositor.hyprland-location = lib.mkOption {
      type = lib.types.path;
      description = ''
        The location of the hyprland configuration. It defaults to copying the config to the store,
        and symlinking there. If it is set, chainging the nvim config has immediate effect.
        If it is left default, home-manager switch is needed beforehand.
      '';
      default = ./hyprland-module.nix;
    };
  };
  config = lib.mkIf config.option.mac.enable {
    # Hyprland stuff is installed by my nixos configuration
    home.file = {
      ".config/hypr".source = config.lib.file.mkOutOfStoreSymlink config.option.linux.compositor.hyprland-location;
    };

  };
}
