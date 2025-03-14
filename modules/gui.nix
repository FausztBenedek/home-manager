{ config, pkgs, lib, ... }:

{
  options = {
    option.gui.enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enable mac specific tools";
      default = false;
    };

  };
  config = lib.mkIf config.option.gui.enable {
    home.packages = with pkgs; [
      nerd-fonts.zed-mono
      # Depricated form:
      #(pkgs.nerdfonts.override { fonts = [ "ZedMono" ]; }) # Available fonts https://github.com/NixOS/nixpkgs/blob/master/pkgs/data/fonts/nerdfonts/shas.nix, then when I open apple fonts, the font name is visible
    ];
    home.shellAliases = {
      intellij = "open -a \"IntelliJ IDEA\" .";
      webstorm = "open -a WebStorm .";
    };

    programs = {
      alacritty = {
        enable = true;
        settings.font.normal.family = "ZedMono Nerd Font Mono";
        settings.font.size = 16;
        settings.window.decorations = "Buttonless";
        settings.colors = {
          # Source https://github.com/kepano/flexoki/blob/main/alacritty/flexoki-dark.yaml
          # Default colors
          primary = {
            background = "#282726";
            foreground = "#FFFCF0";

            dim_foreground = "#FFFCF0";
            bright_foreground = "#FFFCF0";
          };
          # Cursor colors
          cursor = {
            text = "#0F0C00";
            cursor = "#FFFCF0";
          };
          # Normal colors
          normal = {
            black = "#100F0F";
            red = "#AF3029";
            green = "#66800B";
            yellow = "#AD8301";
            blue = "#205EA6";
            magenta = "#A02F6F";
            cyan = "#24837B";
            white = "#FFFCF0";
          };

          # Bright colors
          bright = {
            black = "#606060";
            red = "#D14D41";
            green = "#879A39";
            yellow = "#D0A215";
            blue = "#4385BE";
            magenta = "#CE5D97";
            cyan = "#3AA99F";
            white = "#FFFCF0";
          };

          # Dim colors
          dim = {
            black = "#100F0F";
            red = "#AF3029";
            green = "#66800B";
            yellow = "#AD8301";
            blue = "#205EA6";
            magenta = "#A02F6F";
            cyan = "#24837B";
            white = "#FFFCF0";
          };
        };
      };
    };
  };
}
