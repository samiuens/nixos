{
  config,
  lib,
  pkgs,
  inputs,
  osConfig,
  userConfig,
  ...
}:

let
  smiLib = import ../../../lib { inherit lib; };
  cfg = userConfig.programs.development.openchamber or { };

  # A user's own value replaces the shared one as a whole; read both to layer them by key.
  shared = lib.attrByPath [
    "programs"
    "development"
    "openchamber"
  ] { } (osConfig.smi.system.users.shared or { });
  layered = name: (shared.${name} or { }) // (cfg.${name} or { });
  layeredSurfaces =
    name:
    lib.zipAttrsWith (_: lib.foldl (a: b: a // b) { }) [
      (shared.${name} or { })
      (cfg.${name} or { })
    ];
  catalogueKey = "programs.development.openchamber";
  entry = (smiLib.appCatalogue pkgs).${catalogueKey};
  useNixPackage = smiLib.preferNixPackage pkgs catalogueKey;

  enabled = path: lib.attrByPath (path ++ [ "enable" ]) false userConfig.programs;

  # Which file a key belongs in: `profile` keys go to preferences.json, the
  # rest to settings.json. Keys the registry lacks, such as `ghCliActive`, are
  # instance facts.
  registry =
    (builtins.fromJSON (
      builtins.readFile "${inputs.openchamber}/packages/web/server/lib/opencode/settings-registry.json"
    )).fields;
  scopeOf = key: registry.${key}.scope or "instance";
  surfaces = [
    "web"
    "desktop"
    "vscode"
    "mobile"
  ];

  baseSettings = {
    themeVariant = "dark";
    lightThemeId = "openchamber-light";
    darkThemeId = "openchamber-dark";
    monoFont = "jetbrains-mono";
    uiFont = "inter";

    defaultModel = "claude-code/claude-opus-5-5";
    defaultVariant = "medium";
    favoriteModels = [
      {
        providerID = "claude-code";
        modelID = "claude-opus-5-5";
      }
    ];
    walkthroughModelOverride = "claude-code/claude-haiku-5-5";
    usageSelectedModels.claude = [ "Fable" ];
    usageDisplayMode = "remaining";

    nativeNotificationsEnabled = true;
    notifyOnCompletion = true;
    notifyOnError = true;
    notifyOnQuestion = true;
    notifyOnSubtasks = true;
    notificationTemplates = {
      completion = {
        title = "{agent_name} is ready";
        message = "{model_name} completed the task";
      };
      error = {
        title = "Tool error";
        message = "{last_message}";
      };
      question = {
        title = "Input needed";
        message = "{last_message}";
      };
      subtask = {
        title = "{agent_name} is ready";
        message = "{model_name} completed the task";
      };
    };

    gitmojiEnabled = true;
    gitChangesViewMode = "tree";
    showReasoningTraces = true;
    workStatusPanelEnabled = true;
    showSplitAssistantMessageActions = false;
    sessionTabsEnabled = false;
    sessionGoalEnabled = false;
    showDeletionDialog = false;
    reportUsage = false;
    dictationEnabled = false;
    weekStartPreference = "monday";
    timeFormatPreference = "24h";

    desktopMinimizeToTrayEnabled = true;
    messageSearchEnabled = true;
    mergedWorktreeCleanupEnabled = true;
    autoDeleteEnabled = true;
    autoDeleteAfterDays = 7;
  }
  // lib.optionalAttrs (enabled [
    "development"
    "gh"
  ]) { ghCliActive = true; };

  baseSurfaceSettings.desktop = {
    lightThemeId = "github-light";
    darkThemeId = "github-dark";
  };

  # A value replaces the shared one whole; OpenChamber stores each key as one value.
  settings = baseSettings // layered "settings";
  surfaceSettings = lib.zipAttrsWith (_: lib.foldl (a: b: a // b) { }) [
    baseSurfaceSettings
    (layeredSurfaces "surfaceSettings")
  ];

  defaults = pkgs.writeText "openchamber-defaults.json" (
    builtins.toJSON {
      profileKeys = lib.attrNames (lib.filterAttrs (_: field: field.scope == "profile") registry);
      profile = lib.filterAttrs (key: _: scopeOf key == "profile") settings;
      instance = lib.filterAttrs (key: _: scopeOf key == "instance") settings;
      surfaces = surfaceSettings;
    }
  );

  seedSettings = pkgs.writeShellApplication {
    name = "openchamber-seed-settings";
    runtimeInputs = [ pkgs.jq ];
    text = builtins.readFile ./openchamber/seed-settings.sh;
  };

  deviceKeys = lib.filter (key: scopeOf key == "device") (lib.attrNames settings);
  unknownSurfaces = lib.subtractLists surfaces (lib.attrNames surfaceSettings);
  sharedSurfaceKeys = lib.filter (key: !(registry.${key}.perSurface or false)) (
    lib.concatMap lib.attrNames (lib.attrValues surfaceSettings)
  );
in
{
  config = lib.mkIf (cfg.enable or false) {
    home.packages = lib.optional useNixPackage entry.package;

    assertions = [
      {
        assertion = deviceKeys == [ ];
        message = "OpenChamber keeps ${lib.concatStringsSep ", " deviceKeys} per device; they cannot be seeded.";
      }
      {
        assertion = unknownSurfaces == [ ];
        message = "OpenChamber has no surface ${lib.concatStringsSep ", " unknownSurfaces}; use one of ${lib.concatStringsSep ", " surfaces}.";
      }
      {
        assertion = sharedSurfaceKeys == [ ];
        message = "OpenChamber stores ${lib.concatStringsSep ", " sharedSurfaceKeys} for every surface; set them in `settings`.";
      }
    ];

    # OpenChamber rewrites both files from its UI, so the declared values only
    # fill in keys a user has not set yet; later changes here do not reach them.
    home.activation.seedOpenChamberSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      run ${lib.getExe seedSettings} "${config.home.homeDirectory}/.config/openchamber" ${defaults}
    '';
  };
}
