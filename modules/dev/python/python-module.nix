{ config, lib, pkgs, ... }: {
  options = {
    option.dev.python.enable = lib.mkEnableOption "Enabled developer tools for javascript";
  };
  config = lib.mkIf config.option.dev.python.enable {

    home.packages = with pkgs; [
      texliveSmall
      pandoc
      (python3.withPackages (python-pkgs: [
        python-pkgs.kubernetes
        python-pkgs.debugpy
        python-pkgs.tkinter
        python-pkgs.openai
        python-pkgs.pandas
        python-pkgs.openpyxl
        python-pkgs.xlsxwriter
        python-pkgs.sentence-transformers
      ]))
    ];
  };
}
