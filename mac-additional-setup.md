- Yabai

  - https://github.com/koekeishiya/yabai/wiki/Disabling-System-Integrity-Protection
  - I always miss step 6: sudo nvram boot-args=-arm64e_preview_abi
  - Under Desktop & Dock tab
    - Disable "Automatically rearrange Spaces based on most recent use" in the
      Mission Control pane
    - Enable "Show Items On Desktop"
    - "Click wallpaper to reveal Desktop" should be set to "Only in Stage
      Manager"

- Xcode utils

- Enable Magic Mouse right click

- Change key repeat rate and delay until repeat under keyboard settings

- Rancher desktop (installed from github release page
  https://github.com/rancher-sandbox/rancher-desktop/releases)

- IntelliJ

  - Remove cmd+shift+a shortcut from mac
    - System Preferences > Keyboard > Shortcuts > Services > Text > Search man
      Page Index in Terminal
  - Enable repeating keys: defaults write -g ApplePressAndHoldEnabled 0
  - Remove > to be assigned to clear context as shortcut
  - Disable the setting "Enable commit tool window"
  - Plugins
    - Vimidea
    - Astro

- sdkman

- copy keylayout:
  `cp $HM/mac/us-benedek-xkb-querty.keylayout ~/Library/Keyboard\ Layouts`

- karabiener-elements

  - Install karabiener elements
  - add Karabiner-Elements.app and Karabiner-EventViewer.app to "Open at login"
    setting in the settings app
  - Enable karabiener related software under "App Background Activity" in the settings
  - restart the computer, and after prompt appears to give some more rights to karabiener
  - Set virtual keyboard type to ansi (otherwise í and 0 are swapped)
  - Do the remaps:
    - swap right cmd <--> right options
    - swap left ctrl <--> fn (globe)
    - set caps lock to esc


