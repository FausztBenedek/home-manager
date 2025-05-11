{ config, pkgs, lib, ... }: {
  options = {
    option.mac.yabai.enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enable yabai on mac";
      default = false;
    };

  };
  config = lib.mkIf config.option.mac.yabai.enable {
    # Setup:
    # skhd --install-service
    # Set a bunch of options in the system settings, based on the docs
    # Disable crutils, see https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)#configure-scripting-addition
    home.packages = with pkgs; [
      yabai
      skhd
      jankyborders
      (pkgs.writeShellScriptBin "_aerospace_jump_to_window_after_fuzzy_search" ''
        aerospace list-windows \
            --all \
            --format "%{app-name}%{right-padding}ǁ%{window-title}%{right-padding}ǁ%{window-id}%{right-padding}ǁ%{workspace}%{right-padding}ǁ%{monitor-name}%{right-padding}" \
            | choose -w 95  \
            | awk -F 'ǁ' '{print $3}'  \
            | xargs aerospace focus --window-id
      '')
      (pkgs.writeShellScriptBin "paint-borders-aerospace-window-manager-mode" ''
        borders active_color=0xFF5F9EA0 inactive_color=0xFFE3B95D width=5.0 &
      '')
      (pkgs.writeShellScriptBin "paint-borders-aerospace-main-mode" ''
        borders active_color=0xFF5A73C4 inactive_color=0xFFCCD4E1 width=5.0 &
      '')
    ];
    home.file = {
      ".config/yabai/yabairc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.sessionVariables.HM}/modules/mac/yabairc.sh";
      ".config/skhd/skhdrc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.sessionVariables.HM}/modules/mac/skhdrc";
    };
  };
}
