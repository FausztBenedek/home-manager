{ pkgs, config, lib, ... }: {
  options = {
    option.mac.enable = lib.mkEnableOption "Enables mac specific software";
  };
  config = lib.mkIf config.option.mac.enable {
    option.mac.aerospace.enable = lib.mkDefault true;
    option.mac.maccy.enable = lib.mkDefault true;

    home.packages = with pkgs; [
      utm
    ];
  };
}
