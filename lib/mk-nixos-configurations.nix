{ lib }:

{
  nixpkgs,
  hostsDir,
  inputModules ? [ ],
  specialArgs ? { },
}:

let
  discoverHosts = import ./discover-hosts.nix { inherit lib; };

  hosts = lib.filterAttrs (_: host: host.platform == "nixos") (discoverHosts hostsDir);

  mkHost =
    _: host:
    nixpkgs.lib.nixosSystem {
      inherit specialArgs;
      inherit (host) system;
      modules = inputModules ++ [ host.configuration ];
    };
in
lib.mapAttrs mkHost hosts
