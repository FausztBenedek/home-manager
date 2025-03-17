{ config, pkgs, lib, ... }:
{
  options = {
    option.nvim.config-location = lib.mkOption {
      type = lib.types.path;
      description = ''
        The location of the neovim configuration. It defaults to copying the config to the store,
        and symlinking there. If it is set, chainging the nvim config has immediate effect.
        If it is left default, home-manager switch is needed beforehand.
      '';
      default = ./nvim-config;
    };

  };
  config = {
    programs.neovim.enable = true;
    home.file = {
      ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink config.option.nvim.config-location;
    };

    home.packages = with pkgs; [
      gcc
      fzf
      ripgrep #For nvim telescope grep_string to work
      fd # For nvim telescope to be faster

      # Formatters
      libxml2 # xmllint
      nixpkgs-fmt
      nodePackages.fixjson
      python312Packages.autopep8
      shfmt
      stylua
      taplo # TOML formatter

      #Language servers
      pyright # python
      jdt-language-server # For java, the eclipse language server
      lombok # For jdt-language-server's lombok support
      lua-language-server
      nixd
      nodePackages.bash-language-server
      nodePackages.typescript-language-server
      terraform-ls
      vscode-langservers-extracted # HTML/CSS/JSON/ESLint language servers extracted from vscode

      (pkgs.writeShellScriptBin "find-files-in-nvim" ''
        find ''${1:-'.'} \( -type d -name .idea -prune \) -o \
        \( -type d -name target -prune \) -o \
        \( -type d -name build -prune \) -o \
        \( -type d -name node_modules -prune \) -o \
        \( -type d -name .git -prune \) -o \
        \( -type d -name localonly -prune \) -o \
        \( -type d -name out -prune \) -o \
        \( -type d -name dist -prune \) -o \
        \( -type d -name .gradle -prune \) -o \
        \( -type f -name .factorypath -prune \) -o \
        -type f -print | while read -r line; do echo "{\"name\": \"''${line##*/}\", \"ref\": \"''$line\"}"; done
      '')
    ];
    home.sessionVariables = {
      EDITOR = "nvim";
      JDTLS_JVM_ARGS = "-javaagent:${pkgs.lombok}/share/java/lombok.jar"; # Needed for jdt-language-server
    };
  };
}
