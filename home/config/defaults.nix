{
  lib,
  pkgs,
  ...
}:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in
{
  config = lib.mkIf isDarwin {
    targets.darwin.defaults = {
      NSGlobalDomain = {
        AppleInterfaceStyle = "Dark";

        # macOS stores the inverse: this keeps window backgrounds off the
        # wallpaper's colour.
        AppleReduceDesktopTinting = true;

        AppleKeyboardUIMode = 3;

        # Menu bar stays hidden until the pointer reaches the top of the
        # screen. Takes effect after the next login.
        _HIHideMenuBar = true;

        KeyRepeat = 2;
        InitialKeyRepeat = 15;
        NSNavPanelExpandedStateForSaveMode = true;
        NSNavPanelExpandedStateForSaveMode2 = true;
        NSWindowShouldDragOnGesture = true;
        NSAutomaticCapitalizationEnabled = false;
        NSAutomaticSpellingCorrectionEnabled = false;
        NSAutomaticQuoteSubstitutionEnabled = false;
        NSAutomaticPeriodSubstitutionEnabled = false;
      };

      "com.apple.dock" = {
        autohide = true;
        autohide-delay = 0.0;
        tilesize = 28;
        minimize-to-application = true;
        orientation = "bottom";
        expose-group-apps = true;
        mru-spaces = false;

        # 1 disables the corner, keeping Quick Note off the bottom-right.
        wvous-bl-corner = 1;
        wvous-br-corner = 1;
        wvous-tl-corner = 1;
        wvous-tr-corner = 1;
      };

      "com.apple.finder" = {
        _FXSortFoldersFirst = true;
        FXDefaultSearchScope = "SCcf";
        FXPreferredViewStyle = "clmv";

        # Open folders in windows rather than adding a tab to the current one.
        FinderSpawnTab = false;

        # Home Manager's typed option is misspelled `ShowPathBar`; this is the
        # key macOS actually reads, and freeform passes it through untouched.
        ShowPathbar = true;
      };

      "com.apple.WindowManager" = {
        EnableStandardClickToShowDesktop = false;
        EnableTiledWindowMargins = false;
        EnableTilingByEdgeDrag = false;
        StageManagerHideWidgets = false;
        StandardHideWidgets = false;
      };
    };
  };
}
