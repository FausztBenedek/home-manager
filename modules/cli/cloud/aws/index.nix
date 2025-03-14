{ config, lib, ... }:
{
  imports = [
    ./aws.nix
  ];
  option.cli.cloud.aws.enable = lib.mkIf config.option.cli.cloud.enable true;
}
