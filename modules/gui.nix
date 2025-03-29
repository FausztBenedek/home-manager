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
      nerd-fonts.jetbrains-mono
      # Depricated form:
      #(pkgs.nerdfonts.override { fonts = [ "ZedMono" ]; }) # Available fonts https://github.com/NixOS/nixpkgs/blob/master/pkgs/data/fonts/nerdfonts/shas.nix, then when I open apple fonts, the font name is visible
    ];
    home.shellAliases = {
      intellij = "open -a \"IntelliJ IDEA\" .";
      idea = "\"/Applications/IntelliJ IDEA.app/Contents/MacOS\"/idea";
      webstorm = "open -a WebStorm .";
    };

    programs = {
      alacritty = lib.mkIf config.option.mac.enable {
        # Alacritty only worked on mac so far, TODO Make it work on linux
        enable = true;
        #settings.font.normal.family = "ZedMono Nerd Font Mono"; # My previous fond
        settings.font.normal.family = "JetBrainsMono Nerd Font";
        settings.font.size = 14;
        settings.window.decorations = "Buttonless";
        settings.colors = {
          # Source https://github.com/kepano/flexoki/blob/main/alacritty/flexoki-dark.yaml
          # Default colors
          primary = {
            background = "#ccd4e1";
            foreground = "#4c4f69";

            dim_foreground = "#5c5f79";
            bright_foreground = "#1f2020";
          };
          # Cursor colors
          cursor = {
            text = "#4c4f69";
            cursor = "#CE5D97";
          };
          # Normal colors
          normal = {
            black = "#0c0f29";
            red = "#D14B5A";
            green = "#5F9EA0";
            yellow = "#E3B95D";
            blue = "#5A73C4";
            magenta = "#CE5D97";
            cyan = "#5f8b89";
            white = "#FFFCF0";
          };
          # My old color config
          #primary = {
          #  background = "#282726";
          #  foreground = "#FFFCF0";

          #  dim_foreground = "#FFFCF0";
          #  bright_foreground = "#FFFCF0";
          #};
          ## Cursor colors
          #cursor = {
          #  text = "#0F0C00";
          #  cursor = "#A02F6F";
          #};
          ## Normal colors
          #normal = {
          #  black = "#100F0F";
          #  red = "#AF3029";
          #  green = "#66800B";
          #  yellow = "#AD8301";
          #  blue = "#205EA6";
          #  magenta = "#A02F6F";
          #  cyan = "#24837B";
          #  white = "#FFFCF0";
          #};

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
