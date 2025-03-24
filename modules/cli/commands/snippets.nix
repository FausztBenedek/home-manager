{ config, pkgs, ... }:
{

  home.file.".zshrc.d/my-snippet-engine-setup.zsh" = {
    text = ''
      snip() { 
        TEMPORARY_FILE="$(mktemp).sh"; 
        my-snippet-engine > $TEMPORARY_FILE; 
        nvim $TEMPORARY_FILE
        print -z $(cat $TEMPORARY_FILE)
        rm $TEMPORARY_FILE
      }
    '';
  };
  home.packages = [
    (pkgs.writeShellScriptBin "my-snippet-engine" ''
      template_dir="${config.home.sessionVariables.HM}/modules/cli/commands/snippets/"
      selected_file=$(grep -H '^#' "$template_dir"* | sed 's/:# /: /' | fzf --delimiter=: --with-nth=2.. | cut -d: -f1)
      if [ -z "$selected_file" ]; then
          exit 1
      fi

      cat $selected_file | sed 1d
    '')
  ];

  home.sessionVariables = {
    SNIPPETS = "${config.home.sessionVariables.HM}/modules/cli/commands/snippets/";
  };

}
