{ config, lib, pkgs, self, ... }:

{
  options = {
    option.starship.config-location = lib.mkOption {
      type = lib.types.path;
      description = ''
        The location of the starship configuration. It defaults to copying the config to the store,
        and symlinking there. If it is set, chainging the starship config has immediate effect.
        If it is left default, home-manager switch is needed beforehand.
      '';
      default = ./starship.toml;
    };
  };

  config = {
    nix = {
      package = pkgs.nix;
      settings.experimental-features = [ "nix-command" "flakes" ];
    };
    home.stateVersion = "23.11";

    home.sessionVariables = {
      HM = lib.mkDefault "${self}";
    };

    home.file = {
      ".zshrc.d/vi-cursor-setter.zsh".text = ''
        # Always starting with insert mode for each command line
        ZVM_LINE_INIT_MODE=$ZVM_MODE_INSERT
      '';
      ".config/starship.toml".source = config.lib.file.mkOutOfStoreSymlink config.option.starship.config-location;
    };

    programs = {
      home-manager.enable = true;
      starship.enable = true;
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
          {
            # I missed the surruond feature in the built in vi mode
            name = "zsh-vi-mode";
            src = pkgs.zsh-vi-mode;
            file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
          }
          # TODO https://github.com/softmoth/zsh-vim-mode
        ];
        oh-my-zsh = {
          enable = true;
          plugins = [ "git" ];
          theme = "agnoster";
        };
        initContent = ''
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

          export KEYTIMEOUT=1
          # Use vim keys in tab complete menu:
          bindkey -M menuselect 'h' vi-backward-char
          bindkey -M menuselect 'k' vi-up-line-or-history
          bindkey -M menuselect '^p' vi-up-line-or-history
          bindkey -M menuselect 'l' vi-forward-char
          bindkey -M menuselect 'j' vi-down-line-or-history
          bindkey -M menuselect '^n' vi-down-line-or-history

          # vi mode: Use the system clipboard when yanking commands:
          # Whatch out for https://github.com/jeffreytse/zsh-vi-mode/issues/19
          function zvm_vi_yank() {
            zvm_yank
            echo ''${CUTBUFFER} | pbcopy
            zvm_exit_visual_mode
          }


          for config in ~/.zshrc.d/*.zsh; do
            source $config
          done

          # Workaround for zsh-fzf-history-search plugin, because the default keymap was only available for emacs mode
          bindkey -M emacs '^R' fzf_history_search
          bindkey -M vicmd '^R' fzf_history_search
          bindkey -M viins '^R' fzf_history_search

          # Edit line in vim with ctrl-x then ctrl-e:
          bindkey -M emacs '^x^e' edit-command-line
          bindkey -M vicmd '^x^e' edit-command-line
          bindkey -M viins '^x^e' edit-command-line
        '';
      };
    };
  };

}
