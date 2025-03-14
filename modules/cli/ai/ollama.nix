{ pkgs, ... }:
{

  services.ollama.enable = true;
  home.packages = [
    (pkgs.writeShellScriptBin "ollama-setup" ''
      ollama pull deepseek-r1:1.5b
      ollama pull deepseek-r1:14b
    '')
    (pkgs.writeShellScriptBin "_ask-grammar-check-from-nvim" ''
      ollama run deepseek-r1:14b $(echo "$2" | grammar-check) --nowordwrap > "$1"
    '')
    (pkgs.writeShellScriptBin "ask" ''
      ollama run deepseek-r1:14b "$1"
    '')
    (pkgs.stdenv.mkDerivation {
      pname = "grammar-check";
      version = "1.0";

      src = ./.;

      buildInputs = [ pkgs.python3 ];

      meta = with pkgs.lib; {
        description = "Prompt creation for ai prompting, replaces {{text}} in the prompt file";
        license = licenses.mit;
      };

      # Define the entry point for the script
      postInstall = ''
        mkdir -p $out/bin
        #cp $src/ollama.py $out/bin/$pname
        echo "#!${pkgs.python3}/bin/python" | cat - $src/ollama.py > $out/bin/$pname
        chmod +x $out/bin/$pname
      '';
    })

  ];
}
