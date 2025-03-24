{ config, lib, ... }: {
  options = {
    option.dev.js.enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enabled developer tools for javascript";
      default = false;
    };
  };
  config = lib.mkIf config.option.dev.js.enable {
    option.dev.js.nvm.enable = lib.mkDefault true;
  };

}
