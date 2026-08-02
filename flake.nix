{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-utils,
      ...
    }:
    let
      smiLib = import ./lib { inherit (nixpkgs) lib; };

      inputModules = [
        inputs.disko.nixosModules.disko
        inputs.home-manager.nixosModules.home-manager
        inputs.nix-index-database.nixosModules.default
      ];

      nixosConfigurations = smiLib.mkNixosConfigurations {
        inherit inputModules nixpkgs;
        hostsDir = ./hosts;
        specialArgs = {
          inherit inputs;
        };
      };
    in
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          packages = with pkgs; [
            deadnix
            nil
            nixd
            nixfmt
            statix
          ];
        };

        formatter = pkgs.nixfmt;

        checks = {
          format =
            pkgs.runCommand "nix-format-check"
              {
                nativeBuildInputs = [ pkgs.nixfmt ];
              }
              ''
                ${pkgs.lib.getExe pkgs.nixfmt} --check ${./.}
                touch $out
              '';

          statix =
            pkgs.runCommand "statix-check"
              {
                nativeBuildInputs = [ pkgs.statix ];
              }
              ''
                ${pkgs.lib.getExe pkgs.statix} check ${./.}
                touch $out
              '';

          deadnix =
            pkgs.runCommand "deadnix-check"
              {
                nativeBuildInputs = [ pkgs.deadnix ];
              }
              ''
                ${pkgs.lib.getExe pkgs.deadnix} --fail ${./.}
                touch $out
              '';
        }
        // nixpkgs.lib.optionalAttrs (system == "x86_64-linux") {
          nixos-smi-nix = nixosConfigurations.smi-nix.config.system.build.toplevel;
        };
      }
    )
    // {
      lib = smiLib;
      inherit nixosConfigurations;
    };
}
