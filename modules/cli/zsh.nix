{ lib, config, pkgs, self, ... }:

{
  home.stateVersion = "23.11";

  home.sessionVariables = {
    HM = lib.mkDefault "${self}";
  };

  programs = {
    home-manager.enable = true;
    zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      history = {
        size = 10000;
      };
      plugins = [
        {
          # will source zsh-autosuggestions.plugin.zsh
          name = "zsh-autosuggestions";
          src = pkgs.fetchFromGitHub {
            owner = "zsh-users";
            repo = "zsh-autosuggestions";
            rev = "v0.4.0";
            sha256 = "0z6i9wjjklb4lvr7zjhbphibsyx51psv50gm07mbb0kj9058j6kc";
          };
        }
      ];
      oh-my-zsh = {
        enable = true;
        plugins = [ "git" ];
        theme = "agnoster";
      };
      initExtra = ''
        # Unbind control + right and left arrow coming from oh-my-zsh in $ZSH/lib/key-bindings.zsh
        bindkey -r '^[[1;5C'
        bindkey -r '^[[1;5D'
        # Rebind keys correctly
        bindkey -M emacs ';3C' forward-word
        bindkey -M viins ';3C' forward-word
        bindkey -M vicmd ';3C' forward-word
        bindkey -M emacs ';3D' backward-word
        bindkey -M viins ';3D' backward-word
        bindkey -M vicmd ';3D' backward-word

        for config in ~/.zshrc.d/*.zsh; do
          source $config
        done
      '';
    };
  };

}
