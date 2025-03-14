{ config, pkgs, lib, ... }:
{
  options = {
    additionalNvmCommands = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Commands to set up nvm, like installing another node version";
    };
  };
  config =
    let
      nvm = pkgs.callPackage ./nvm-derivation.nix {
        nvmCommands = [
          ''
            # This version is used by nvim's ts_ls for vue
            nvm install v20.11.0
            npm install -g @vue/typescript-plugin
            npm install -g @vue/language-server
            npm install -g prettier
          ''
        ] ++ config.additionalNvmCommands;
      };
    in
    {
      home.packages = [
        nvm
      ];

      home.sessionVariables = {
        #NVM
        NVM_DIR = "${nvm}/.nvm";
      };

      home.file = {
        ".zshrc.d/nvm.zsh" = {
          text = ''
            # init nvm
            source ${nvm}/nvm.sh
          '';
        };
      };
    };
}
