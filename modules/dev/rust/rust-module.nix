{ config, lib, ... }:
{
  options = {
    option.dev.rust.enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enabled developer tools for javascript";
      default = false;
    };
  };
  config = lib.mkIf config.option.dev.rust.enable {
    # I installed rust with the script on their website, for now, because I am new to it
    # The rust-analyzer was missing, suggested fix is `rustup component add rust-analyzer`
    home.sessionPath = [
      "${config.home.homeDirectory}/.cargo/bin"
    ];
    home.file.".zshrc.d/rust.zsh" = {
      # Sourcing rust related stuff
      text = ''
        . "$HOME/.cargo/env"
      '';
    };
  };

}
