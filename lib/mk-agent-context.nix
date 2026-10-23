{ lib }:

# Host notes for coding agents, shared by OpenCode's AGENTS.md and Claude Code's CLAUDE.md.
{
  hostName,
  hostPlatform,
  programs,
  comma ? false,
}:

let
  enabled = path: lib.attrByPath (path ++ [ "enable" ]) false programs;

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

  hostNotes = ../hosts/${hostName}/opencode.md;
in
lib.concatStringsSep "\n" (
  [
    "# Host"
    ""
    "- Host: `${hostName}`, ${
      if hostPlatform.isDarwin then "macOS managed by nix-darwin" else "NixOS"
    } on `${hostPlatform.system}`."
  ]
  ++ lib.optional (enabled [
    "shell"
    "fish"
  ]) "- Shell: fish. Write shell commands in fish syntax, not bash."
  ++ lib.optional (terminals != [ ]) "- Terminal: ${lib.concatStringsSep ", " terminals}."
  ++ lib.optional (forgeClis != [ ]) "- Use ${lib.concatStringsSep ", and " forgeClis}."
  ++ [
    "- Packages come from Nix. Never install tools globally; run a missing one with `nix shell nixpkgs#<package> -c <command>`${lib.optionalString comma " or comma: `, <command>`"}."
  ]
  ++ lib.optionals (builtins.pathExists hostNotes) [
    ""
    (lib.removeSuffix "\n" (builtins.readFile hostNotes))
  ]
)
