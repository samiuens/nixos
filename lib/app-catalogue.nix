# nixpkgs package paired with a Homebrew cask (or `masApp`), keyed by option path.
# `preferCask` takes the cask on darwin even when nixpkgs builds it.
pkgs:

{
  "programs.ai.chatgpt" = {
    package = null;
    cask = "chatgpt";
  };

  "programs.ai.claude" = {
    package = null;
    cask = "claude";
  };

  "programs.ai.codexbar" = {
    package = null;
    cask = "codexbar";
  };

  "programs.cad.bambu-studio" = {
    package = pkgs.bambu-studio;
    cask = "bambu-studio";
  };

  "programs.development.claude-code" = {
    package = pkgs.callPackage ../packages/claude-code-bin.nix { };

    # The plain cask conflicts with `@latest` over the `claude` binary.
    cask = "claude-code@latest";
  };

  "programs.development.codex" = {
    package = pkgs.callPackage ../packages/codex-bin.nix { };
    cask = "codex";
  };

  "programs.development.orbstack" = {
    package = null;
    cask = "orbstack";
  };

  "programs.development.t3-code" = {
    package = pkgs.t3code;
    cask = "t3-code";

    preferCask = true;
  };

  "programs.editor.arduino-ide" = {
    package = pkgs.arduino-ide;
    cask = "arduino-ide";
  };

  "programs.editor.datagrip" = {
    package = pkgs.jetbrains.datagrip;
    cask = "datagrip";

    preferCask = true;
  };

  "programs.editor.drawio" = {
    package = pkgs.drawio;
    cask = "drawio";
  };

  "programs.editor.intellij-idea" = {
    # Ultimate edition; Community is `intellij-idea-ce`.
    package = pkgs.jetbrains.idea;
    cask = "intellij-idea";
    preferCask = true;
  };

  "programs.editor.obsidian" = {
    package = pkgs.obsidian;
    cask = "obsidian";

    preferCask = true;
  };

  "programs.editor.zed" = {
    package = pkgs.zed-editor;
    cask = "zed";

    preferCask = true;
  };

  "programs.education.anki" = {
    package = pkgs.anki;
    cask = "anki";

    preferCask = true;
  };

  "programs.media.ente-photos" = {
    package = pkgs.ente-desktop;
    cask = "ente";

    preferCask = true;
  };

  "programs.media.iina" = {
    package = pkgs.iina;
    cask = "iina";
  };

  "programs.office.excel" = {
    package = null;
    cask = "microsoft-excel";
  };

  "programs.office.powerpoint" = {
    package = null;
    cask = "microsoft-powerpoint";
  };

  "programs.office.word" = {
    package = null;
    cask = "microsoft-word";
  };

  "programs.security.bitwarden" = {
    package = pkgs.bitwarden-desktop;
    cask = "bitwarden";

    preferCask = true;
  };

  "programs.security.yubico-authenticator" = {
    package = pkgs.yubioath-flutter;
    cask = "yubico-authenticator";
  };

  "programs.sync.nextcloud-client" = {
    package = pkgs.nextcloud-client;
    cask = "nextcloud";
  };

  "programs.terminal.ghostty" = {
    package = pkgs.ghostty;
    cask = "ghostty";
  };

  "programs.utility.keka" = {
    package = pkgs.keka;
    cask = "keka";
  };

  "programs.utility.linearmouse" = {
    package = null;
    cask = "linearmouse";
  };

  "programs.utility.monitorcontrol" = {
    package = pkgs.monitorcontrol;
    cask = "monitorcontrol";
  };

  "programs.utility.pearcleaner" = {
    package = null;
    cask = "pearcleaner";
  };

  "programs.utility.radix" = {
    package = null;
    cask = "radix";
  };

  "programs.utility.raycast" = {
    package = pkgs.raycast;
    cask = "raycast";

    preferCask = true;
  };

  "programs.utility.rpi-imager" = {
    package = pkgs.rpi-imager;
    cask = "raspberry-pi-imager";

    preferCask = true;
  };

  "programs.utility.shottr" = {
    package = pkgs.shottr;
    cask = "shottr";
  };

  "programs.utility.thaw" = {
    package = pkgs.thaw;
    cask = "thaw";

    # A stable path keeps the accessibility permission across updates.
    preferCask = true;
  };
}
