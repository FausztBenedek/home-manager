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
              background = "0x282726";
              foreground = "0xFFFCF0";

              dim_foreground = "0xFFFCF0";
              bright_foreground = "0xFFFCF0";
              dim_background = "0x1C1B1A";
              bright_background = "0x1C1B1A";
            };

          # Cursor colors
          cursor =
            {
              text = "0xFFFCF0";
              cursor = "0xFFFCF0";
            };

          # Normal colors
          normal =
            {
              black = "0x100F0F";
              red = "0xAF3029";
              green = "0x66800B";
              yellow = "0xAD8301";
              blue = "0x205EA6";
              magenta = "0xA02F6F";
              cyan = "0x24837B";
              white = "0xFFFCF0";
            };

          # Bright colors
          bright =
            {
              black = "0x100F0F";
              red = "0xD14D41";
              green = "0x879A39";
              yellow = "0xD0A215";
              blue = "0x4385BE";
              magenta = "0xCE5D97";
              cyan = "0x3AA99F";
              white = "0xFFFCF0";
            };

          # Dim colors
          dim =
            {
              black = "0x100F0F";
              red = "0xAF3029";
              green = "0x66800B";
              yellow = "0xAD8301";
              blue = "0x205EA6";
              magenta = "0xA02F6F";
              cyan = "0x24837B";
              white = "0xFFFCF0";
            };
        };
      };
    };
  };
}
