# OpenChamber desktop from its flake, with the bun dependency hash it ships corrected.
# Drop for `openchamber.packages.<system>.openchamber-desktop` once upstream's
# nix/hashes.json matches again.
{ openchamber, system }:

let
  # Upstream's own pin: the bun dependency hash depends on its bun version.
  pkgs = openchamber.inputs.nixpkgs.legacyPackages.${system};

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

  openchamberServer = pkgs.callPackage package {
    inherit cloudflared opencodeCli version;
    self = openchamber;
  };
in
pkgs.callPackage "${openchamber}/nix/gui.nix" {
  inherit cloudflared opencodeCli version;
  self = openchamber;
  inherit (openchamberServer.passthru) src;
  openchamberCore = openchamberServer.passthru.core;

  # Matches the electron major upstream's flake passes.
  electron = pkgs.electron_43;
}
