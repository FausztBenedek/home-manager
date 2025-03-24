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
      jankyborders
      choose-gui
      (pkgs.writeShellScriptBin "_aerospace_jump_to_window_after_fuzzy_search" ''
        aerospace list-windows \
            --all \
            --format "%{app-name}%{right-padding}ǁ%{window-title}%{right-padding}ǁ%{window-id}%{right-padding}ǁ%{workspace}%{right-padding}ǁ%{monitor-name}%{right-padding}" \
            | choose -w 95  \
            | awk -F 'ǁ' '{print $3}'  \
            | xargs aerospace focus --window-id
      '')
      (pkgs.writeShellScriptBin "paint-borders-aerospace-window-manager-mode" ''
        borders active_color=0xFFE52020 inactive_color=0xFFFFA725 width=5.0 &
      '')
      (pkgs.writeShellScriptBin "paint-borders-aerospace-main-mode" ''
        borders active_color=0xffe1e3e4 inactive_color=0xff494d64 width=5.0 &
      '')
    ];
    home.file = {
      ".config/aerospace/aerospace.toml".source = config.lib.file.mkOutOfStoreSymlink "${config.home.sessionVariables.HM}/modules/mac/aerospace.toml";
    };
  };
}
