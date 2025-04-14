{ config, pkgs, lib, ... }:

{
  options = {
    option.gui.enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enable mac specific tools";
      default = false;
    };
    option.alacritty.config-location = lib.mkOption {

      type = lib.types.path;
      description = ''
        The location of the alacritty configuration. It defaults to copying the config to the store,
        and symlinking there. If it is set, chainging the alacritty config has immediate effect.
        If it is left default, home-manager switch is needed beforehand.
      '';
      default = ./alacritty/alacritty.toml;
    };

  };
  config = lib.mkIf config.option.gui.enable {
    home.packages = with pkgs; [
      nerd-fonts.zed-mono
      nerd-fonts.jetbrains-mono
      python312Packages.grip
      # Depricated form:
      #(pkgs.nerdfonts.override { fonts = [ "ZedMono" ]; }) # Available fonts https://github.com/NixOS/nixpkgs/blob/master/pkgs/data/fonts/nerdfonts/shas.nix, then when I open apple fonts, the font name is visible
    ];
    home.shellAliases = {
      intellij = "open -a \"IntelliJ IDEA\" .";
      idea = "\"/Applications/IntelliJ IDEA.app/Contents/MacOS\"/idea";
      webstorm = "open -a WebStorm .";
    };
    home.file = {
      ".config/alacritty/alacritty.toml".source = config.lib.file.mkOutOfStoreSymlink config.option.nvim.config-location;
    };

    programs = {
      alacritty.enable = true;
    };
  };
}
