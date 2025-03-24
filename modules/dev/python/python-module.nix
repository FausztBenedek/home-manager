{ config, lib, pkgs, ... }: {
  options = {
    option.dev.python.enable = lib.mkEnableOption "Enabled developer tools for javascript";
  };
  config = lib.mkIf config.option.dev.python.enable {

    home.packages = with pkgs; [
      (python3.withPackages (python-pkgs: [
        python-pkgs.kubernetes
      ]))
    ];
  };
}
