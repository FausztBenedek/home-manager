{ config, lib, pkgs, ... }:
{
  options = {
    option.dev.js.enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enabled developer tools for javascript";
      default = false;
    };
  };
  config = lib.mkIf config.option.dev.js.enable {

    home.packages = with pkgs; [
      pnpm

    ];
    home.sessionVariables = {
      NVM_DIR = "${config.home.homeDirectory}/.nvm";
    };
    home.file = {
      ".zshrc.d/js.zsh" = {
        text = ''
          # init nvm
          [ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
          [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
        '';
      };
    };
  };

}
