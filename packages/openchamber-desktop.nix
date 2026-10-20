# OpenChamber desktop from its flake, with the bun dependency hash it ships corrected.
# Drop for `openchamber.packages.<system>.openchamber-desktop` once upstream's
# nix/hashes.json matches again.
{ pkgs, openchamber }:

let
  inherit (pkgs.stdenv.hostPlatform) system;

  # Upstream's own pin builds the server: the bun dependency hash depends on its bun version.
  pinnedPkgs = openchamber.inputs.nixpkgs.legacyPackages.${system};

  bunDepsHash = "sha256-1FB+MoreZx6wc3Ku1ZBE5i5c3eSAEipmkx/5G7QjjRU=";

  hashExpression = "(builtins.fromJSON (builtins.readFile ./hashes.json)).bunDeps";

  upstreamPackage = builtins.readFile "${openchamber}/nix/package.nix";

  # `./hashes.json` is the file's only relative path, so a rewritten copy evaluates anywhere.
  package =
    assert pkgs.lib.assertMsg (pkgs.lib.hasInfix hashExpression upstreamPackage)
      "openchamber: nix/package.nix no longer reads the bun dependency hash from hashes.json";
    builtins.toFile "openchamber-package.nix" (
      builtins.replaceStrings [ hashExpression ] [ ''"${bunDepsHash}"'' ] upstreamPackage
    );

  inherit (builtins.fromJSON (builtins.readFile "${openchamber}/package.json")) version;

  opencodeCli = openchamber.packages.${system}.opencode-cli;

  # Only OpenChamber's Cloudflare tunnel uses it; `makeBinPath` skips null.
  cloudflared = null;

  openchamberServer = pinnedPkgs.callPackage package {
    inherit cloudflared opencodeCli version;
    self = openchamber;
  };
in
# The app itself uses the host's nixpkgs, so its glibc matches the system's graphics driver.
pkgs.callPackage "${openchamber}/nix/gui.nix" {
  inherit cloudflared opencodeCli version;
  self = openchamber;
  inherit (openchamberServer.passthru) src;
  openchamberCore = openchamberServer.passthru.core;

  # packages/electron/package.json asks for Electron 44; upstream's flake still passes 43.
  electron = pkgs.electron_44;
}
