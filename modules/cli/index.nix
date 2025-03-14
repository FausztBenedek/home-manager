{ ... }:
{
  imports = [
    ./cloud/index.nix
    ./commands/index.nix
    ./git/index.nix
    ./tools/index.nix
    ./ai/index.nix

    ./tools.nix
    ./zsh.nix
  ];
}
