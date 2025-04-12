{ config, pkgs, lib, ... }:
{
  options = {
    option.vscode.enable = lib.mkEnableOption "Vscode";
  };

  config = lib.mkIf config.option.vscode.enable {
    home.packages = with pkgs; [
      (vscode-with-extensions.override {
        vscode = vscodium;
        vscodeExtensions = with vscode-extensions; [
          # Extensinos available in <nixpkgs>/nixos/pkgs/applications/editors/vscode/extensions/default.nix
          rust-lang.rust-analyzer
        ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
          {
            name = "vim";
            publisher = "vscodevim";
            version = "1.29.0";
            sha256 = "sha256-J3V8SZJZ2LSL8QfdoOtHI1ZDmGDVerTRYP4NZU17SeQ=";
          }

        ];
      })
    ];

  };
}
