{ self, lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    gnumake
    wget
    yq-go
    fzf
    unixtools.watch
    jq # to apply JSON path on stdout
    hwatch
    findutils
    tealdeer
    lnav
    utm
    podman
    podman-desktop # The podman binary has to be set explicitly. It must be the nix-store one, but by selecting the symlink in `~/.nix-profile/`, it resolves to the nix store.
    gnugrep
    (pkgs.writeShellScriptBin "openports" ''
      # Facher's solution lsof -i -P | grep -i "listen"
      (echo 'port pid app' && netstat -anvp tcp  | awk '/LISTEN/ {sub(/^.*\./, "", $4); print $4"|"$9}' | uniq | sort --numeric-sort | column -t -s "|" | while read port pid; do echo "$port $(ps -e -o pid,comm | awk "/$pid / {print $2}")" | grep $pid | head -n 1; done) | column -t
    '')

  ];
  home.shellAliases = {
    history = "print -z $(sort ~/.zsh_history | sort | uniq | fzf)";
  };
  home.sessionVariables = {
    HOME_MANAGER_LOCATION = lib.mkDefault "${self}";
  };
  programs = {
    eza = {
      enable = true;
      icons = "auto";
      git = true;
    };
    tmux = {
      enable = true;
      clock24 = true;
      mouse = true;
      terminal = "xterm-256color"; #Solves the M-arrow problem on mac
      prefix = "C-Space";
      plugins = [
        # List of available plugins https://github.com/NixOS/nixpkgs/blob/master/pkgs/misc/tmux-plugins/default.nix
        pkgs.tmuxPlugins.vim-tmux-navigator
        pkgs.tmuxPlugins.onedark-theme
      ];
      extraConfig = '' # used for less common options, intelligently combines if defined in multiple places.
        # I followed this video for initial setup https://www.youtube.com/watch?v=DzNmUNvnB04
        set-option -sa
        terminal-overrides
        ",xterm*:Tc" #For colors
        bind -n
        M-H
        previous-window
        bind -n
        M-L
        next-window

        # Opens new panes in directory that I am splitting from
        bind '"' split-window -v -c " #{pane_current_path}"
        bind % split-window -h -c
        "#{pane_current_path}"
        '';
    };
  };
}
