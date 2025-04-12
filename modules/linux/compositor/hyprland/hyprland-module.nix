{ config, pkgs, lib, ... }:
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
    home.pointerCursor =
      let
        getFrom = url: hash: name: {
          gtk.enable = true;
          x11.enable = true;
          name = name;
          size = 48;
          package =
            pkgs.runCommand "moveUp" { } ''
              mkdir -p $out/share/icons
              ln -s ${pkgs.fetchzip {
                url = url;
                hash = hash;
              }} $out/share/icons/${name}
            '';
        };
      in
      getFrom
        "https://github.com/ful1e5/fuchsia-cursor/releases/download/v2.0.0/Fuchsia-Pop.tar.gz"
        "sha256-BvVE9qupMjw7JRqFUj1J0a4ys6kc9fOLBPx2bGaapTk="
        "Fuchsia-Pop";

  };
}
