{ config, lib, ... }:
{
  options = {
    option.linux.compositor.waybar = lib.mkEnableOption "Use waybar for bar";
    option.linux.compositor.waybar-location = lib.mkOption {
      type = lib.types.path;
      description = ''
        The location of the waybar configuration. It defaults to copying the config to the store,
        and symlinking there. If it is set, chainging the waybar config has immediate effect.
        If it is left default, home-manager switch is needed beforehand.
      '';
      default = ./waybar-config;
    };
  };
  config = lib.mkIf config.option.linux.compositor.waybar {
    # Hyprland stuff is installed by my nixos configuration
    home.file = {
      ".config/waybar".source = config.lib.file.mkOutOfStoreSymlink config.option.linux.compositor.waybar-location;
    };
  };
}
