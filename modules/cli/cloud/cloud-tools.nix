{ lib, ... }:
{
  options = {
    option.cli.cloud.enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enable tools cloud";
      default = false;
    };
  };
}
