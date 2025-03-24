{ config, lib, ... }:
{
  options = {
    option.dev.js.enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enabled developer tools for javascript";
      default = false;
    };
  };

  imports = [
    ./nvm
  ];

  config = {
    option.dev.js.nvm.enable = lib.mkDefault config.option.dev.js.enable;
  };

}
