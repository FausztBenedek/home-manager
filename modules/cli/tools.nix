{ pkgs, system, inputs, ... }:
{
  home.packages = with pkgs; [
    inputs.benedek-neovim-flake.packages.${system}.default
    coreutils
    ripgrep
    fd
    gnused
    (
      curl.override
        {
          opensslSupport = true;
        }
    )
    gnumake
    wget
    rsync
    go
    gh
    act
    editorconfig-checker
    tesseract
    yq-go
    fzf
    unixtools.watch
    jq # to apply JSON path on stdout
    postgresql
    codex
    claude-code
    entr
    bat
    qemu
    hwatch
    findutils
    ant
    maven
    trivy
    graphviz
    poetry
    allure
    tealdeer
    poppler-utils
    lnav
    podman
    gnugrep
    (pkgs.writeShellScriptBin "openports" ''
      # Facher's solution lsof -i -P | grep -i "listen"
      (echo 'port pid app' && netstat -anvp tcp  | awk '/LISTEN/ {sub(/^.*\./, "", $4); print $4"|"$9}' | uniq | sort --numeric-sort | column -t -s "|" | while read port pid; do echo "$port $(ps -e -o pid,comm | awk "/$pid / {print $2}")" | grep $pid | head -n 1; done) | column -t
    '')

  ];
  home.shellAliases = {
    cat = "${pkgs.bat}/bin/bat";
  };
  programs = {
    bat = {
      enable = true;
    };
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
