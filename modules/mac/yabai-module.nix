{ config, pkgs, lib, ... }:
let
  cfg = config.option.mac.yabai;

  # ---------------------------------------------------------------------------
  # Helper scripts
  #
  # Bodies live as real .sh files in ./wm so they can be shellchecked and edited
  # normally; here they are wrapped into executables on PATH.
  #
  # yabai and skhd come from Homebrew, and both skhd bindings and yabai signals
  # run under launchd with a minimal environment, so the runtime dependencies are
  # made explicit rather than inherited.
  # ---------------------------------------------------------------------------

  wmLib = pkgs.writeTextFile {
    name = "wm-lib.sh";
    text = builtins.readFile ./wm/wm-lib.sh;
  };

  mkWmScript = name: pkgs.writeShellScriptBin name ''
    export PATH="/opt/homebrew/bin:${lib.makeBinPath [ pkgs.jq pkgs.coreutils ]}:$PATH"
    WM_LIB="${wmLib}"
    ${builtins.readFile (./wm + "/${name}.sh")}
  '';

  wmScriptNames = [
    "wm-workspace-focus" # C2
    "wm-focus-dir" # C3
    "wm-move-dir" # C4
    "wm-window-send" # C5
    "wm-sticky-toggle" # C6
    "wm-place-new-window" # C7
    "wm-reconcile" # 3.3
    "wm-adapt" # C10
    "wm-display-priority" # C11
    "wm-status" # debugging aid
  ];

  # ---------------------------------------------------------------------------
  # skhdrc
  #
  # Generated rather than hand-written: section 5 of the spec is 18 workspace keys x 4
  # variants plus the directional and toggle families, and the previous
  # hand-maintained file had drifted (the `t` block sent windows to space 7 while
  # focusing space 6).
  # ---------------------------------------------------------------------------

  mode = "windowmanager";

  # C1: every command has a variant that acts and leaves the mode in one
  # keypress. skhd has no "run and pop mode" primitive, so the mode is left by
  # synthesising the exit key.
  leaveMode = ''skhd -k "escape" ; '';

  bind = keys: cmd: "${mode} < ${keys} : ${cmd}";
  bindExit = keys: cmd: "${mode} < ${keys} : ${leaveMode}${cmd}";

  # Directional families. hjkl are vi directions; yabai names them by compass
  # point. The resize handles are the reserved alt-hjkl binding.
  directions = [
    { key = "h"; dir = "west"; resize = "left:-20:0"; }
    { key = "j"; dir = "south"; resize = "bottom:0:20"; }
    { key = "k"; dir = "north"; resize = "top:0:-20"; }
    { key = "l"; dir = "east"; resize = "right:20:0"; }
  ];

  directionalBindings = lib.concatMapStringsSep "\n\n"
    ({ key, dir, resize }: lib.concatStringsSep "\n" [
      (bind key "wm-focus-dir ${dir}")
      (bindExit "ctrl - ${key}" "wm-focus-dir ${dir}")
      (bind "shift - ${key}" "wm-move-dir ${dir}")
      (bindExit "ctrl + shift - ${key}" "wm-move-dir ${dir}")
      (bind "alt - ${key}" "yabai -m window --resize ${resize}")
      (bindExit "ctrl + alt - ${key}" "yabai -m window --resize ${resize}")
    ])
    directions;

  globalDirectionalBindings = lib.concatMapStringsSep "\n"
    ({ key, dir, ... }: "ctrl + cmd - ${key} : wm-focus-dir ${dir}")
    directions;

  workspaceBindings = lib.concatMapStringsSep "\n\n"
    ({ ws, key }: lib.concatStringsSep "\n" [
      "# workspace ${ws}"
      (bind key "wm-workspace-focus ${ws}")
      (bindExit "ctrl - ${key}" "wm-workspace-focus ${ws}")
      (bind "shift - ${key}" "wm-window-send ${ws}")
      (bindExit "ctrl + shift - ${key}" "wm-window-send ${ws} --follow")
    ])
    cfg.workspaceKeys;

  # A toggle plus its do-and-exit twin.
  toggle = keys: cmd: lib.concatStringsSep "\n" [
    (bind keys cmd)
    (bindExit "ctrl - ${keys}" cmd)
  ];

  skhdrc = ''
    # GENERATED FILE -- edit modules/mac/yabai-module.nix instead.
    #
    # This is the yabai + skhd implementation of the key mapping in section 5 of
    # modules/window-manager-spec.md, which is normative: the same keypress must
    # do the same thing here, on Hyprland and on GlazeWM.
    #
    # DEVIATIONS FROM SECTION 5: none.
    #
    # Notes that are notation, not deviation (section 5 "Notation versus deviation"):
    #   * Digits are written as hex keycodes because skhd matches physical keys.
    #     On mac/us-benedek-xkb-querty.keylayout: 0=0x0A, 1=0x12, 2=0x13, 3=0x14,
    #     4=0x15, 5=0x17, 7=0x1A, 9=0x19.
    #   * "act and leave the mode" is spelled by synthesising escape, since skhd
    #     cannot pop a mode as part of a command.
    #
    # Two things here are outside the spec rather than in conflict with it:
    #   * the border colours on mode entry -- section 7 puts mode indication out of scope;
    #   * the gaps-off mode on ctrl-` -- section 7 puts that out of scope too.
    # The bare 9 / f / z / i / shift-7 bindings are the in-mode halves of the
    # ctrl-prefixed pairs C1 requires; section 5 lists the ctrl variant.

    :: default : paint-borders-yabai-main-mode
    :: ${mode} @ : paint-borders-yabai-window-manager-mode
    :: disable_skhd : yabai -m config top_padding 0 bottom_padding 0 left_padding 0 right_padding 0 window_gap 0

    # ---------------------------------------------------------------------------
    # C1 -- modal layer. Entering must not alter window state, and the mode is
    # left by escape or by the entry key.
    #
    # The extra entry keys below are additions, not deviations: section 5's own key
    # is present and unchanged, nothing in the table is remapped, and none of these
    # keys means anything else in the scheme.
    # ---------------------------------------------------------------------------
    ${lib.concatMapStringsSep "\n"
      (key: "${key} ; ${mode}\n${mode} < ${key} ; default")
      ([ cfg.modeEntryKey ] ++ cfg.modeEntryKeyAliases)}
    ${mode} < escape ; default

    # ---------------------------------------------------------------------------
    # Out of scope (section 7): suspend gaps and padding.
    # ---------------------------------------------------------------------------
    ctrl - 0x29 ; disable_skhd
    disable_skhd < ctrl - 0x2A ; default
    disable_skhd < ctrl - 0x29 : skhd -k "ctrl - 0x2A" ; yabai -m config top_padding 5 bottom_padding 5 left_padding 5 right_padding 5 window_gap 15

    # ---------------------------------------------------------------------------
    # Section 5 -- the one permitted addition: directional focus outside the mode.
    # It does not replace the in-mode bindings.
    # ---------------------------------------------------------------------------
    ${globalDirectionalBindings}

    # ---------------------------------------------------------------------------
    # C3 directional focus, C4 directional move, and the reserved alt-hjkl resize.
    # Both focus and move cross display boundaries; see wm-focus-dir/wm-move-dir.
    # ---------------------------------------------------------------------------
    ${directionalBindings}

    # ---------------------------------------------------------------------------
    # C2 workspace switching and C5 send-to-workspace, for all 18 workspaces.
    # ---------------------------------------------------------------------------
    ${workspaceBindings}

    # ---------------------------------------------------------------------------
    # C6 -- display stickiness. Section 5 binds this to ctrl-9.
    # ---------------------------------------------------------------------------
    ${toggle "0x19" "wm-sticky-toggle"}

    # ---------------------------------------------------------------------------
    # C8 -- fullscreen, confined to the pane. Deliberately not macOS native
    # fullscreen, which would create a surface outside the pane model.
    # ---------------------------------------------------------------------------
    ${toggle "f" "yabai -m window --toggle zoom-fullscreen"}

    # ---------------------------------------------------------------------------
    # C9 -- float toggle. A floating window stays subject to C2, C4 and C5.
    # ---------------------------------------------------------------------------
    ${toggle "z" "yabai -m window --toggle float"}

    # ---------------------------------------------------------------------------
    # Reserved bindings for the optional capabilities we do implement. Section 5
    # requires these exact keys; anything unimplemented must stay unbound.
    # ---------------------------------------------------------------------------

    # toggle split direction
    ${toggle "i" "yabai -m window --toggle split"}

    # balance panes -- shift-7
    ${bind "shift - 0x1A" "yabai -m space --balance"}
    ${bindExit "ctrl + shift - 0x1A" "yabai -m space --balance"}
  '';
in
{
  options = {
    option.mac.yabai.enable = lib.mkOption {
      type = lib.types.bool;
      description = "Enable yabai on mac";
      default = false;
    };

    option.mac.yabai.modeEntryKey = lib.mkOption {
      type = lib.types.str;
      default = "ctrl - m";
      description = ''
        skhd binding that enters the window management mode, and also leaves it.

        Section 5 of modules/window-manager-spec.md makes this ctrl-m on a host and
        ctrl-n inside a guest session, and those are the only two conforming
        values. Note that ctrl-m is Return, so skhd will shadow Ctrl-M globally.
      '';
    };

    option.mac.yabai.modeEntryKeyAliases = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "ctrl - a" ];
      description = ''
        Extra skhd bindings that also enter and leave the window management mode,
        alongside modeEntryKey.

        Section 5 of the spec is satisfied as long as its own entry key is bound and
        nothing in its table is remapped, so additional aliases are permitted.
        ctrl-a is here because it was the entry key before the spec existed, and
        because ctrl-m is Return.

        An alias must not collide with anything bound inside the mode -- in
        particular not with a workspace key, `h`/`j`/`k`/`l`, `f`, `z`, `i`, `9` or
        `7`.
      '';
    };

    option.mac.yabai.workspaceKeys = lib.mkOption {
      type = with lib.types; listOf (submodule {
        options = {
          ws = lib.mkOption {
            type = str;
            description = "Workspace key from section 3.1 of the spec. Opaque; never reassign.";
          };
          key = lib.mkOption {
            type = str;
            description = "How skhd spells that key on this keyboard layout.";
          };
        };
      });
      description = ''
        The 18 workspaces of section 3.1, in the order panes are iterated.

        `ws` is the identifier the spec fixes and must not change between
        machines; `key` is only how skhd names the physical key, which is
        layout-dependent. The digit keycodes below are the keys that produce those
        digits on mac/us-benedek-xkb-querty.keylayout.
      '';
      default = [
        { ws = "q"; key = "q"; }
        { ws = "w"; key = "w"; }
        { ws = "e"; key = "e"; }
        { ws = "r"; key = "r"; }
        { ws = "t"; key = "t"; }
        { ws = "s"; key = "s"; }
        { ws = "d"; key = "d"; }
        { ws = "g"; key = "g"; }
        { ws = "y"; key = "y"; }
        { ws = "x"; key = "x"; }
        { ws = "c"; key = "c"; }
        { ws = "v"; key = "v"; }
        { ws = "0"; key = "0x0A"; }
        { ws = "1"; key = "0x12"; }
        { ws = "2"; key = "0x13"; }
        { ws = "3"; key = "0x14"; }
        { ws = "4"; key = "0x15"; }
        { ws = "5"; key = "0x17"; }
      ];
    };
  };

  config = lib.mkIf cfg.enable {
    # Setup:
    # sudo nvram boot-args=-arm64e_preview_abi
    # skhd --install-service
    # Set a bunch of options in the system settings, based on the docs
    # Disable crutils, see https://github.com/koekeishiya/yabai/wiki/Installing-yabai-(latest-release)#configure-scripting-addition
    #
    # Then, once per machine: run `wm-display-priority` to say which monitor is
    # primary, and `wm-reconcile` to create the panes.
    # See modules/mac/window-manager-README.md.

    assertions = [
      {
        assertion = builtins.length cfg.workspaceKeys == 18;
        message = "option.mac.yabai.workspaceKeys must list exactly 18 workspaces (spec 3.1).";
      }
      {
        assertion =
          let keys = map (w: w.ws) cfg.workspaceKeys;
          in lib.sort (a: b: a < b) keys == lib.sort (a: b: a < b) (lib.unique keys);
        message = "option.mac.yabai.workspaceKeys contains a duplicate workspace identifier.";
      }
    ];

    home.packages = with pkgs; [
      # yabai
      # skhd # Installed with brew, because it messes things up somehow
      jankyborders
      # Mode indication is out of scope per section 7 of the spec, so these are free
      # to stay as they are.
      (pkgs.writeShellScriptBin "paint-borders-yabai-window-manager-mode" ''
        borders active_color=0xFF5F9EA0 inactive_color=0xFFE3B95D width=5.0 &
      '')
      (pkgs.writeShellScriptBin "paint-borders-yabai-main-mode" ''
        borders active_color=0xFF5A73C4 inactive_color=0xFFCCD4E1 width=5.0 &
      '')
    ] ++ map mkWmScript wmScriptNames;

    home.file = {
      ".config/yabai/yabairc".source = config.lib.file.mkOutOfStoreSymlink "${config.home.sessionVariables.HM}/modules/mac/yabairc.sh";
      # Generated from the option values above rather than symlinked out of store,
      # because the section 5 table is too repetitive to maintain by hand.
      ".config/skhd/skhdrc".text = skhdrc;
    };
  };
}
