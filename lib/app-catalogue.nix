# Applications that come from Homebrew rather than nixpkgs on darwin. Each entry
# pairs the nixpkgs package with the Homebrew cask; `preferNixPackage` decides
# which one applies on a given platform, so an entry needs no change when nixpkgs
# gains support for a new system.
#
# Most entries are here because nixpkgs has no darwin build at all. Set
# `preferCask` for the ones where it does build but the cask is wanted anyway;
# the flag is ignored on Linux, where nixpkgs is the only source.
#
# A cask that does not live in homebrew-cask names its tap as `tap`, which is
# added for as long as the entry needs the cask.
#
# Keys are option paths inside a user's `programs`/`services` tree in users/.
pkgs:

{
  "programs.development.claude-code" = {
    # Repo-local rather than nixpkgs: upstream ships a prebuilt linux-x64 binary,
    # so the package is marked x86_64-linux only and darwin takes the cask.
    package = pkgs.callPackage ../packages/claude-code-bin.nix { };
    cask = "claude-code";
  };

  "programs.editor.zed" = {
    package = pkgs.zed-editor;
    cask = "zed";

    # nixpkgs does build this on darwin, but only as a source build that trails
    # the cask by several releases.
    preferCask = true;
  };

  "programs.network.netbird" = {
    package = pkgs.netbird-ui;
    cask = "netbirdio/tap/netbird-ui";
    tap = "netbirdio/tap";

    # nixpkgs does build this on darwin, but the client drives a privileged
    # daemon and a network extension that the cask installs alongside it.
    preferCask = true;
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

  "programs.sync.localsend" = {
    package = pkgs.localsend;
    cask = "localsend";

    # nixpkgs does build this on darwin; the cask keeps the app at a stable
    # path, so the local network permission survives an update.
    preferCask = true;
  };

  "programs.terminal.ghostty" = {
    package = pkgs.ghostty;
    cask = "ghostty";
  };

  "programs.utility.linearmouse" = {
    # Cask-only: LinearMouse ships as a signed application and nixpkgs has no
    # package for it at all, so there is nothing to fall back to off darwin.
    package = null;
    cask = "linearmouse";
  };

  "programs.utility.thaw" = {
    package = pkgs.thaw;
    cask = "thaw";

    # nixpkgs does build this on darwin; the cask keeps the app at a stable
    # path, so the accessibility permission survives an update.
    preferCask = true;
  };
}
