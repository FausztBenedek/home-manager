{ config, lib, ... }:
{
  imports = [
    ./k8s.nix
  ];
  option.cli.cloud.k8s.enable = lib.mkIf config.option.cli.cloud.enable true;
}
