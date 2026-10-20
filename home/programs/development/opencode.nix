{
  lib,
  pkgs,
  hostName,
  osConfig,
  userConfig,
  ...
}:

let
  smiLib = import ../../../lib { inherit lib; };
  cfg = userConfig.programs.development.opencode or { };
  catalogueKey = "programs.development.opencode";
  entry = (smiLib.appCatalogue pkgs).${catalogueKey};
  useNixPackage = smiLib.preferNixPackage pkgs catalogueKey;

  inherit (pkgs.stdenv.hostPlatform) isDarwin system;

  enabled = path: lib.attrByPath (path ++ [ "enable" ]) false userConfig.programs;

  # Pinned so a plugin release lands with a commit, not on the next launch.
  claudePlugin = "@openchamber/opencode-claude@1.4.2";

  # Pre-5 ids the Claude Code CLI may still report; listing one it lacks is harmless.
  legacyModels = [
    "claude-haiku-4-5"
    "claude-haiku-4-5-20251001"
    "claude-opus-4-1"
    "claude-opus-4-5"
    "claude-opus-4-6"
    "claude-opus-4-6[1m]"
    "claude-opus-4-7"
    "claude-opus-4-8"
    "claude-sonnet-4-5"
    "claude-sonnet-4-6"
    "claude-sonnet-4-6[1m]"
  ];

  terminals =
    lib.optional (enabled [
      "terminal"
      "ghostty"
    ]) "Ghostty"
    ++ lib.optional (enabled [
      "terminal"
      "alacritty"
    ]) "Alacritty";

  forgeClis =
    lib.optional (enabled [
      "development"
      "gh"
    ]) "`gh` for GitHub issues, pull requests and CI"
    ++ lib.optional (enabled [
      "development"
      "glab"
    ]) "`glab` for GitLab issues, merge requests and CI";

  hostNotes = ../../../hosts/${hostName}/opencode.md;

  context = lib.concatStringsSep "\n" (
    [
      "# Host"
      ""
      "- Host: `${hostName}`, ${
        if isDarwin then "macOS managed by nix-darwin" else "NixOS"
      } on `${system}`."
    ]
    ++ lib.optional (enabled [
      "shell"
      "fish"
    ]) "- Shell: fish. Write shell commands in fish syntax, not bash."
    ++ lib.optional (terminals != [ ]) "- Terminal: ${lib.concatStringsSep ", " terminals}."
    ++ lib.optional (forgeClis != [ ]) "- Use ${lib.concatStringsSep ", and " forgeClis}."
    ++ [
      "- Packages come from Nix. Never install tools globally; run a missing one with `nix shell nixpkgs#<package> -c <command>`${
        lib.optionalString (osConfig.smi.packages.comma.enable or false) " or comma: `, <command>`"
      }."
    ]
    ++ lib.optionals (builtins.pathExists hostNotes) [
      ""
      (lib.removeSuffix "\n" (builtins.readFile hostNotes))
    ]
  );

  baseSettings = {
    model = "claude-code/claude-opus-5-5[1m]";
    plugins = [ claudePlugin ];

    # Last match wins: block every provider, then allow the plugin's.
    policies = [
      {
        action = "provider.use";
        resource = "*";
        effect = "deny";
      }
      {
        action = "provider.use";
        resource = "claude-code";
        effect = "allow";
      }
    ];

    providers.claude-code.models = lib.genAttrs legacyModels (_: {
      disabled = true;
    });

    mcp.servers = {
      context7 = {
        type = "remote";
        url = "https://mcp.context7.com/mcp";
      };

      nixos = {
        type = "local";
        command = [ (lib.getExe pkgs.mcp-nixos) ];
      };

      # Headless keeps browser windows out of the way while an agent works.
      playwright = {
        type = "local";
        command = [
          (lib.getExe pkgs.playwright-mcp)
          "--headless"
        ];
      };
    };

    websearch.provider = "random";

    # Nix or Homebrew pins the version.
    update = "disable";
  };
in
{
  config = lib.mkIf (cfg.enable or false) {
    programs.opencode = {
      enable = true;

      # Homebrew installs it on darwin; the config is still written.
      package = if useNixPackage then entry.package else null;

      inherit context;
      settings = baseSettings;
    };
  };
}
