{ config, pkgs, lib, ... }:
let
  cursorSize = 40;
in
{
  options = {
    option.linux.compositor.hyprland = lib.mkEnableOption "Use hyprland as compositor";
    option.linux.compositor.hyprland-location = lib.mkOption {
      type = lib.types.path;
      description = ''
        The location of the hyprland configuration. It defaults to copying the config to the store,
        and symlinking there. If it is set, chainging the hyprland config has immediate effect.
        If it is left default, home-manager switch is needed beforehand.
      '';
      default = ./hyprland-config;
    };
  };
  config = lib.mkIf config.option.linux.compositor.hyprland {
    # Hyprland stuff is installed by my nixos configuration
    home.file = {
      ".config/hypr".source = config.lib.file.mkOutOfStoreSymlink config.option.linux.compositor.hyprland-location;
    };
    gtk = {
      enable = true;
      theme.name = "Numix";
      # theme.package = pkgs.numix-gtk-theme;
      iconTheme.name = "Numix-Circle";
      # iconTheme.package = pkgs.numix-icon-theme-circle;
    };
    home.sessionVariables = {
      XCURSOR_SIZE = cursorSize;
    };
    home.pointerCursor = {
      enable = true;
      name = "Numix-Cursor";
      gtk.enable = true;
      hyprcursor = { enable = true; size = cursorSize; };
      x11.enable = true;
      dotIcons.enable = true;
      size = cursorSize;
      package = pkgs.numix-cursor-theme;
    };

  };
}
