{ pkgs, config, lib, ... }: {
  options = {
    option.mac.enable = lib.mkEnableOption "Enables mac specific software";
  };
  config = lib.mkIf config.option.mac.enable {
    option.mac.yabai.enable = lib.mkDefault true;
    option.mac.maccy.enable = lib.mkDefault true;

    home.file = {
      "notes".source = config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/Library/Mobile\ Documents/iCloud~md~obsidian/Documents/Icloud\ notes";
    };

    home.packages = with pkgs; [
      utm
      podman-desktop # The podman binary has to be set explicitly. It must be the nix-store one, but by selecting the symlink in `~/.nix-profile/`, it resolves to the nix store.
    ];
  };
}
