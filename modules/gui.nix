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
      alacritty = {
        # Alacritty only worked on mac so far, TODO Make it work on linux
        enable = true;
        #settings.font.normal.family = "ZedMono Nerd Font Mono"; # My previous fond
        settings.font.normal.family = "JetBrainsMono Nerd Font";
        settings.font.size = 14;
        settings.window.decorations = "Buttonless";
        settings.window.opacity = 0.85;
        settings.window.blur = true;
        settings.colors = {
          primary =
            {
              background = "#282726";
              foreground = "#FFFCF0";

              dim_foreground = "#FFFCF0";
              bright_foreground = "#FFFCF0";
              # dim_background = "#1C1B1A"; Reported as unused key
              # bright_background = "#1C1B1A"; Reported as unused key
            };

          # Cursor colors
          cursor =
            {
              text = "#FFFCF0";
              cursor = "#FFFCF0";
            };

          # Normal colors
          normal =
            {
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
          bright =
            {
              black = "#100F0F";
              red = "#D14D41";
              green = "#879A39";
              yellow = "#D0A215";
              blue = "#4385BE";
              magenta = "#CE5D97";
              cyan = "#3AA99F";
              white = "#FFFCF0";
            };

          # Dim colors
          dim =
            {
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
