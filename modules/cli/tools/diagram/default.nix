{ pkgs, ... }:
{
  config = {
    home.packages = [
      pkgs.mermaid-cli
      pkgs.fswatch
      (pkgs.writeShellScriptBin "start-mermaid-sketch" (builtins.readFile ./start-mermaid.sh))
    ];
    home.sessionVariables = {
      MMDC_PUPPETEER_CONFIG = ./mac-mmdc-puppeteer.json;
      MMDC_EXEMPLE_FILE = ./example.mermaid;
    };
  };
}
