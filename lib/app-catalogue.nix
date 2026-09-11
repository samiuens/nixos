# Applications that come from Homebrew rather than nixpkgs on darwin. Each entry
# pairs the nixpkgs package with the Homebrew cask; `preferNixPackage` decides
# which one applies on a given platform, so an entry needs no change when nixpkgs
# gains support for a new system.
#
# Most entries are here because nixpkgs has no darwin build at all. Set
# `preferCask` for the ones where it does build but the cask is wanted anyway;
# the flag is ignored on Linux, where nixpkgs is the only source.
#
# Keys are option paths inside a user's `programs`/`services` tree in users/.
pkgs:

{
  "programs.ai.chatgpt" = {
    # Cask-only: the ChatGPT desktop app is proprietary and ships for macOS
    # only, so nixpkgs has no package and there is nothing to fall back to off
    # darwin.
    package = null;
    cask = "chatgpt";
  };

  "programs.ai.claude" = {
    # Cask-only: the Claude desktop app is proprietary and ships for macOS
    # only, so nixpkgs has no package and there is nothing to fall back to off
    # darwin.
    package = null;
    cask = "claude";
  };

  "programs.cad.bambu-studio" = {
    # nixpkgs packages this for Linux only, so darwin has nothing to fall back
    # to and takes the cask.
    package = pkgs.bambu-studio;
    cask = "bambu-studio";
  };

  "programs.development.claude-code" = {
    # Repo-local rather than nixpkgs: upstream ships a prebuilt linux-x64 binary,
    # so the package is marked x86_64-linux only and darwin takes the cask.
    package = pkgs.callPackage ../packages/claude-code-bin.nix { };
    cask = "claude-code";
  };

  "programs.development.codex" = {
    # Repo-local rather than nixpkgs: upstream ships a prebuilt linux-x64
    # binary, so the package is marked x86_64-linux only and darwin takes the
    # cask.
    package = pkgs.callPackage ../packages/codex-bin.nix { };
    cask = "codex";
  };

  "programs.development.orbstack" = {
    # Cask-only: OrbStack is proprietary and macOS-only, so nixpkgs has no
    # package and there is nothing to fall back to off darwin.
    package = null;
    cask = "orbstack";
  };

  "programs.editor.datagrip" = {
    package = pkgs.jetbrains.datagrip;
    cask = "datagrip";

    # nixpkgs does build this on darwin, but JetBrains ships DataGrip with its
    # own updater and the cask is marked `auto_updates`; from the store it would
    # sit frozen between flake updates, as with the IDEA entry below.
    preferCask = true;
  };

  "programs.editor.drawio" = {
    package = pkgs.drawio;
    cask = "drawio";
  };

  "programs.editor.intellij-idea" = {
    # `jetbrains.idea` is the Ultimate edition; the community build is a separate
    # attribute and a separate cask (`intellij-idea-ce`).
    package = pkgs.jetbrains.idea;
    cask = "intellij-idea";
    preferCask = true;
  };

  "programs.editor.obsidian" = {
    package = pkgs.obsidian;
    cask = "obsidian";

    # nixpkgs does build this on darwin, by unpacking the same signed
    # application the cask installs. Obsidian updates itself in place, though,
    # which it cannot do from a read-only store path, so the cask keeps it
    # current between flake updates.
    preferCask = true;
  };

  "programs.editor.zed" = {
    package = pkgs.zed-editor;
    cask = "zed";

    # nixpkgs does build this on darwin, but only as a source build that trails
    # the cask by several releases.
    preferCask = true;
  };

  "programs.media.iina" = {
    package = pkgs.iina;
    cask = "iina";
  };

  # Cask-only: Microsoft ships Office for macOS only and nixpkgs has no package,
  # so there is nothing to fall back to off darwin. Each application is its own
  # cask; the `microsoft-office` bundle cask would install the rest as well.
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

    # nixpkgs does build this on darwin; the cask is preferred anyway so the app
    # is the signed build Bitwarden ships, installed into /Applications.
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
    # Cask-only: LinearMouse ships as a signed application and nixpkgs has no
    # package for it at all, so there is nothing to fall back to off darwin.
    package = null;
    cask = "linearmouse";
  };

  "programs.utility.monitorcontrol" = {
    package = pkgs.monitorcontrol;
    cask = "monitorcontrol";
  };

  "programs.utility.pearcleaner" = {
    # Cask-only: Pearcleaner is a macOS-only application and nixpkgs has no
    # package, so there is nothing to fall back to off darwin.
    package = null;
    cask = "pearcleaner";
  };

  "programs.utility.radix" = {
    # Cask-only: Radix is a signed application and nixpkgs has no package.
    package = null;
    cask = "radix";
  };

  "programs.utility.raycast" = {
    package = pkgs.raycast;
    cask = "raycast";

    # nixpkgs does build this on darwin, but Raycast ships its own updater and
    # expects to keep itself current; from the store it would sit frozen between
    # flake updates.
    preferCask = true;
  };

  "programs.utility.rpi-imager" = {
    package = pkgs.rpi-imager;
    cask = "raspberry-pi-imager";

    # nixpkgs does build this on darwin, but only from source and with no cache
    # hit, so a Qt application gets compiled locally for an SD card writer. The
    # cask is also the build Raspberry Pi signs, which is what macOS wants
    # before it hands an application raw disk access.
    preferCask = true;
  };

  "programs.utility.shottr" = {
    package = pkgs.shottr;
    cask = "shottr";
  };

  "programs.utility.thaw" = {
    package = pkgs.thaw;
    cask = "thaw";

    # nixpkgs does build this on darwin; the cask keeps the app at a stable
    # path, so the accessibility permission survives an update.
    preferCask = true;
  };
}
