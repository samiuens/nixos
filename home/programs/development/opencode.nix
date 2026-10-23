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

  # A user's own `settings` replaces the shared one as a whole; read both to layer them by key.
  shared = lib.attrByPath [
    "programs"
    "development"
    "opencode"
  ] { } (osConfig.smi.system.users.shared or { });
  catalogueKey = "programs.development.opencode";
  entry = (smiLib.appCatalogue pkgs).${catalogueKey};
  useNixPackage = smiLib.preferNixPackage pkgs catalogueKey;

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

  context = smiLib.mkAgentContext {
    inherit hostName;
    inherit (pkgs.stdenv) hostPlatform;
    inherit (userConfig) programs;
    comma = osConfig.smi.packages.comma.enable or false;
  };

  shellRule = effect: resource: {
    action = "shell";
    inherit effect resource;
  };

  # Opt-in: picked in the agent selector; Build stays the default.
  coordinator = {
    mode = "primary";
    description = "Splits a request into tasks, runs each in its own worktree session and merges the results.";
    system =
      builtins.replaceStrings
        [ "{{workerRules}}" ]
        [ (lib.removeSuffix "\n" (builtins.readFile ./opencode/worker-rules.md)) ]
        (builtins.readFile ./opencode/coordinator.md);

    # Layered over the shared rules; the merge prompt is the user's approval.
    permissions = [
      {
        action = "edit";
        resource = "*";
        effect = "deny";
      }
    ]
    ++ map (shellRule "ask") [
      "git merge *"
      "git commit *"
      "git reset *"
      "git branch -D *"
    ];
  };

  baseSettings = {
    model = "claude-code/claude-opus-5-5";
    agents = { inherit coordinator; };
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

    # None built in: server instructions ride along in every session and
    # prompt extra calls. Declare them in users/shared.nix or per user.
    mcp.servers = (shared.mcpServers or { }) // (cfg.mcpServers or { });

    websearch.provider = "random";

    # Nix or Homebrew pins the version.
    update = "disable";
    share = "disabled";

    # Last match wins over OpenCode's defaults.
    permissions =
      map
        (resource: {
          action = "read";
          inherit resource;
          effect = "deny";
        })
        [
          "*.env"
          "*.env.*"
          "*.pem"
          "*.key"
          "*.ssh/*"
          "*sops/age/*"
        ]
      ++ [
        {
          action = "read";
          resource = "*.env.example";
          effect = "allow";
        }
      ]
      ++ map (shellRule "ask") [
        "sudo *"
        "git push *"
        "rm -rf *"
        "nixos-rebuild *"
        "darwin-rebuild *"
      ];

    # Store paths keep both working outside a devShell.
    lsp.nixd = {
      command = [ (lib.getExe pkgs.nixd) ];
      extensions = [ ".nix" ];
    };

    formatter.nixfmt = {
      command = [
        (lib.getExe pkgs.nixfmt)
        "$FILE"
      ];
      extensions = [ ".nix" ];
    };

    watcher.ignore = [
      "result"
      ".direnv"
      "node_modules"
    ];
  };
in
{
  config = lib.mkIf (cfg.enable or false) {
    programs.opencode = {
      enable = true;

      # Homebrew installs it on darwin; the config is still written.
      package = if useNixPackage then entry.package else null;

      inherit context;
      settings = lib.foldl lib.recursiveUpdate baseSettings [
        (shared.settings or { })
        (cfg.settings or { })
      ];
    };

    # Leftover Claude Code skills would load on top of the declared ones.
    home.sessionVariables.OPENCODE_DISABLE_CLAUDE_CODE = "1";
  };
}
