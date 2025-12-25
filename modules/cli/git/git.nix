{ pkgs, lib, config, ... }:
{
  options = {
    git = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "Benedek Fauszt";
        description = "git name to use in commits";
      };
      email = lib.mkOption {
        type = lib.types.str;
        description = "git email to use in commits";
      };
    };
  };
  config =
    {
      programs = {
        git = {
          enable = true;
          settings.user = {
            name = config.git.name;
            email = config.git.email;
          };
        };
        delta = {
          enable = true;
          enableGitIntegration = true;
          options = {
            side-by-side = true;
          };
        };
      };
      # Additionally:
      # - oh-my-zsh plugin added
      # - added to eza
      home.packages = [
        (pkgs.writeShellScriptBin "gcof" ''
          if [ -z $1 ] 
          then
            git checkout $(git branch -a | sed "s/remotes\\/origin\\///" | sort | uniq | fzf)
          else
            git checkout $(git branch -a | sed "s/remotes\\/origin\\///" | sort | uniq | fzf --query $1)
          fi
        '')
      ];
      home.shellAliases = {
        git-cheatsheet = ''cat $HM/modules/cli/git/cheatsheet-git.txt|fzf|awk -F= '{print $1}'|while read -r line; do print -z "$line"; done'';
      };
      home.sessionVariables = {
        LESS = "-XR"; # Through this upon exiting git log command the content will not disappear from the terminal
      };
      home.file = {
        ".gitconfig".text = ''
          [user]
            name = ${config.git.name}
            email = ${config.git.email}
          [core]
            autocrlf = input
            editor = nvim
          [init]
            defaultBranch = main
        '';
      };
    };
}
