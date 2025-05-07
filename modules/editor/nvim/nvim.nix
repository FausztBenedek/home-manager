{ config, pkgs, lib, ... }:
let
  nodeDependencies = (pkgs.callPackage ./node-packages/default.nix { }).nodeDependencies;
in
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
    # At first launch `nvim --headless "+Lazy! restore" "+Lazy! clean" +qa`
    home.file = {
      ".config/nvim".source = config.lib.file.mkOutOfStoreSymlink config.option.nvim.config-location;
      # Used by java.lua, when jdtls starts. Details in java.lua.
      ".local/share/nvim/jdtls-workspace/config_mac/config.ini".source = config.lib.file.mkOutOfStoreSymlink "${pkgs.jdt-language-server}/share/java/jdtls/config_mac/config.ini";
    };
    home.sessionVariables = {
      NODE_DEPENDENCIES_INSTALLED_BY_NIX = nodeDependencies;
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
      nodePackages.prettier
      google-java-format
      mdformat

      #Language servers
      pyright # python
      jdt-language-server # For java, the eclipse language server
      lombok # For jdt-language-server's lombok support
      lua-language-server
      nixd
      nodePackages.bash-language-server
      nodePackages.typescript-language-server
      terraform-ls
      astro-language-server
      vscode-langservers-extracted # HTML/CSS/JSON/ESLint language servers extracted from vscode
      tailwindcss-language-server

      # For typescript-language-server
      (pkgs.callPackage ./node-packages/default.nix { }).nodeDependencies

      (pkgs.writeShellScriptBin "find-files-in-nvim" ''
        find ''${1:-'.'} \
        \( -type d -name .git -prune \) -o \
        \( -type d -name .gradle -prune \) -o \
        \( -type d -name .idea -prune \) -o \
        \( -type d -name bin -prune \) -o \
        \( -type d -name build -prune \) -o \
        \( -type d -name dist -prune \) -o \
        \( -type d -name localonly -prune \) -o \
        \( -type d -name node_modules -prune \) -o \
        \( -type d -name out -prune \) -o \
        \( -type d -name target -prune \) -o \
        \( -type f -name .factorypath -prune \) -o \
        -type f -print | while read -r line; do echo "{\"name\": \"''${line##*/}\", \"ref\": \"''$line\"}"; done
      '')
    ];
    home.sessionVariables = {
      EDITOR = "nvim";
      _NVIM_HELPER_LOCATION_OF_JAVA_JDTLS = pkgs.jdt-language-server;
      _NVIM_HELPER_LOCATION_OF_LOMBOK = "${pkgs.lombok}/share/java/lombok.jar"; # Needed for jdt-language-server
    };
  };
}
