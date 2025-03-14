{ config, lib, ... }: {

  options = {
    option.editor.jetbrains.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
  };
  config = lib.mkIf config.option.editor.jetbrains.enable {
    home.file = {
      ".ideavimrc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.sessionVariables.HOME_MANAGER_LOCATION}/modules/editor/ideavim/ideavim-config/ideavimrc.vim";
    };
  };
}
