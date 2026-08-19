{ lib }:

{
  nix-darwin,
  hostsDir,
  inputModules ? [ ],
  specialArgs ? { },
}:

let
  discoverHosts = import ./discover-hosts.nix { inherit lib; };

  hosts = lib.filterAttrs (_: host: host.platform == "darwin") (discoverHosts hostsDir);

  mkHost =
    _: host:
    nix-darwin.lib.darwinSystem {
      inherit specialArgs;
      modules = inputModules ++ [
        { nixpkgs.hostPlatform = lib.mkDefault host.system; }
        host.configuration
      ];
    };
in
lib.mapAttrs mkHost hosts
