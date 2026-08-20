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
    name: host:
    nixpkgs.lib.nixosSystem {
      specialArgs = specialArgs // {
        hostName = name;
      };
      inherit (host) system;
      modules = inputModules ++ [ host.configuration ];
    };
in
lib.mapAttrs mkHost hosts
