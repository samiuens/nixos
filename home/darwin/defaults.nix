{ lib, userConfig, ... }:

let
  cfg = userConfig.desktop.macos;

  disabledCorner.action = "-";

  baseSettings = {
    finder = {
      menuBar.view.showPathBar = true;

      settings = {
        advanced = {
          keepFoldersOnTop.inWindowsWhenSortingByName = true;
          whenPerformingASearch = "Search the Current Folder";
        };

        general.openFoldersInTabsInsteadOfNewWindows = false;
      };
    };

    systemSettings = {
      appearance = {
        appearance = "Dark";
        allowWallpaperTintingInWindows = false;
      };

      desktopAndDock = {
        desktopAndStageManager.clickWallpaperToRevealDesktop = "Only in Stage Manager";

        dock = {
          automaticallyHideAndShowTheDock = {
            enabled = true;
            delay = 0.0;
          };
          dockPositionOnScreen = "Bottom";
          minimizeWindowsIntoApplicationIcon = true;
          size = 28;
        };

        hotCorners = {
          bottomLeft = disabledCorner;
          bottomRight = disabledCorner;
          topLeft = disabledCorner;
          topRight = disabledCorner;
        };

        missionControl = {
          automaticallyRearrangeSpacesBasedOnMostRecentUse = false;
          groupWindowsByApplication = true;
        };

        widgets.showWidgets = {
          inStageManager = true;
          onDesktop = true;
        };

        windows = {
          dragWindowsToLeftOrRightEdgeOfScreenToTile = false;
          tiledWindowsHaveMargins = false;
        };
      };

      keyboard = {
        delayUntilRepeat = 15;
        keyRepeatRate = 2;
        keyboardNavigation = true;

        textInput = {
          addPeriodWithDoubleSpace = false;
          capitalizeWordsAutomatically = false;
          correctSpellingAutomatically = false;
          useSmartQuotesAndDashes = false;
        };
      };

      menuBar.autoHideAndShowTheMenuBar = "Always";
    };
  };

  # Not covered by nix-plist-manager.
  baseDefaults = {
    NSGlobalDomain = {
      NSNavPanelExpandedStateForSaveMode = true;
      NSNavPanelExpandedStateForSaveMode2 = true;
      NSWindowShouldDragOnGesture = true;
    };

    "com.apple.finder".FXPreferredViewStyle = "clmv";
  };
in
{
  programs.nix-plist-manager = {
    enable = true;
    options.applications = lib.recursiveUpdate baseSettings cfg.settings;
  };

  targets.darwin.defaults = lib.recursiveUpdate baseDefaults cfg.defaults;
}
