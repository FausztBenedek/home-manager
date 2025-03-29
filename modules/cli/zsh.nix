{ lib, pkgs, self, ... }:

{
  nix = {
    package = pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
  home.stateVersion = "23.11";

  home.sessionVariables = {
    HM = lib.mkDefault "${self}";
  };

  home.file = {
    ".zshrc.d/vi-cursor-setter.zsh" = {
      text = ''
        # Change cursor shape for different vi modes.
        function zle-keymap-select {
          if [[ ''${KEYMAP} == vicmd ]] ||
             [[ $1 = 'block' ]]; then
            echo -ne '\e[1 q'
          elif [[ ''${KEYMAP} == main ]] ||
               [[ ''${KEYMAP} == viins ]] ||
               [[ ''${KEYMAP} = \'\' ]] ||
               [[ $1 = 'beam' ]];
          then
            echo -ne '\e[5 q'
          fi
        }
        zle -N zle-keymap-select
        zle-line-init() {
          #zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
          echo -ne "\e[5 q"
        }
        zle -N zle-line-init
        echo -ne '\e[5 q' # Use beam shape cursor on startup.
        preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.
      '';
    };
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
          name = "zsh-fzf-history-search"; # WORKAROUND in the zshrc for keybinds
          src = pkgs.zsh-fzf-history-search;
          file = "share/zsh-fzf-history-search/zsh-fzf-history-search.plugin.zsh";
        }
        {
          name = "zsh-autosuggestions";
          src = pkgs.zsh-autosuggestions;
          file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
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

        # vi mode
        bindkey -v
        export KEYTIMEOUT=1
        # Use vim keys in tab complete menu:
        bindkey -M menuselect 'h' vi-backward-char
        bindkey -M menuselect 'k' vi-up-line-or-history
        bindkey -M menuselect '^p' vi-up-line-or-history
        bindkey -M menuselect 'l' vi-forward-char
        bindkey -M menuselect 'j' vi-down-line-or-history
        bindkey -M menuselect '^n' vi-down-line-or-history
        bindkey -v '^?' backward-delete-char

        for config in ~/.zshrc.d/*.zsh; do
          source $config
        done

        # Workaround for zsh-fzf-history-search plugin, because the default keymap was only available for emacs mode
        bindkey -M emacs '^R' fzf_history_search
        bindkey -M vicmd '^R' fzf_history_search
        bindkey -M viins '^R' fzf_history_search

        # Edit line in vim with ctrl-e:
        bindkey -M emacs '^e' edit-command-line
        bindkey -M vicmd '^e' edit-command-line
        bindkey -M viins '^e' edit-command-line
      '';
    };
  };

}
