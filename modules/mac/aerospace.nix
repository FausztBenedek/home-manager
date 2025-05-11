{ config, pkgs, lib, ... }: {
  options = {
    option.mac.aerospace.enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enable aerospace on mac";
      default = false;
    };

  };

  # Some commands that should be executed:

  # Disable windows opening animations (Observable in Google Chrome) 
  # See https://nikitabobko.github.io/AeroSpace/goodies#disable-open-animations
  # $ defaults write -g NSAutomaticWindowAnimationsEnabled -bool false

  # To show windows adequately in mission control
  # See https://nikitabobko.github.io/AeroSpace/guide#a-note-on-mission-control
  # $ defaults write com.apple.dock expose-group-apps -bool true && killall Dock

  # Resolves some bugs when moving windows between spaces
  # See https://nikitabobko.github.io/AeroSpace/guide#a-note-on-displays-have-separate-spaces
  # $ defaults write com.apple.spaces spans-displays -bool true && killall SystemUIServer


  config = lib.mkIf config.option.mac.aerospace.enable {
    home.packages = with pkgs; [
      aerospace
      choose-gui
    ];
    home.file = {
      ".config/aerospace/aerospace.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.sessionVariables.HM}/modules/mac/aerospace.toml";
    };
  };
}
