{
  description = "NixOS and nix-darwin configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";

    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak/v0.7.0";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    noctalia-greeter = {
      url = "github:noctalia-dev/noctalia-greeter";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix4vscode = {
      url = "github:nix-community/nix4vscode";
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
        inputs.nix-flatpak.nixosModules.nix-flatpak
        inputs.noctalia-greeter.nixosModules.default
        inputs.sops-nix.nixosModules.sops
      ];

      nixosConfigurations = smiLib.mkNixosConfigurations {
        inherit inputModules nixpkgs;
        hostsDir = ./hosts;
        specialArgs = {
          inherit inputs;
        };
      };

      darwinInputModules = [
        inputs.home-manager.darwinModules.home-manager
        inputs.nix-homebrew.darwinModules.nix-homebrew
        inputs.sops-nix.darwinModules.sops
      ];

      darwinConfigurations = smiLib.mkDarwinConfigurations {
        inherit (inputs) nix-darwin;
        inputModules = darwinInputModules;
        hostsDir = ./hosts;
        specialArgs = {
          inherit inputs;
        };
      };
    in
    # Only the systems this repository targets: nixpkgs 26.11 dropped x86_64-darwin,
    # and aarch64-linux is unused. Narrowing the list keeps `nix flake check
    # --all-systems` usable as the CI gate for the darwin configuration.
    flake-utils.lib.eachSystem
      [
        "aarch64-darwin"
        "x86_64-linux"
      ]
      (
        system:
        let
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfreePredicate = pkg: nixpkgs.lib.getName pkg == "claude-code-bin";
          };

          checkedSource = nixpkgs.lib.cleanSourceWith {
            src = ./.;
            filter = path: type: type == "directory" || baseNameOf path != "hardware-configuration.nix";
          };

          hardwareConfigurationRegex = "(^|/)hardware-configuration\\.nix$";

          checkNixSyntax = pkgs.writeShellScript "check-nix-syntax" ''
            set -eu

            export NIX_STATE_DIR="''${TMPDIR:-/tmp}/nix-syntax-state-$$"
            mkdir -p "$NIX_STATE_DIR"

            for file in "$@"; do
              ${pkgs.nix}/bin/nix-instantiate --eval-store dummy:// --parse "$file" >/dev/null
            done
          '';

          preCommitCheck = inputs.git-hooks.lib.${system}.run {
            src = checkedSource;
            hooks = {
              nixfmt = {
                enable = true;
                excludes = [ hardwareConfigurationRegex ];
              };

              nix-syntax = {
                enable = true;
                name = "Nix syntax";
                entry = "${checkNixSyntax}";
                files = "\\.nix$";
                excludes = [ hardwareConfigurationRegex ];
                require_serial = true;
              };
            };
          };
        in
        {
          devShells.default = pkgs.mkShell {
            inherit (preCommitCheck) shellHook;

            packages =
              preCommitCheck.enabledPackages
              ++ (with pkgs; [
                deadnix
                nil
                nixd
                nixfmt
                statix
              ]);
          };

          formatter = pkgs.nixfmt;

          packages = {
            graphify = pkgs.callPackage ./packages/graphify/default.nix { };
          }
          # Prebuilt Linux-only binaries; darwin installs these through Homebrew.
          // nixpkgs.lib.optionalAttrs (system == "x86_64-linux") {
            claude-code-bin = pkgs.callPackage ./packages/claude-code-bin.nix { };
            codex-bin = pkgs.callPackage ./packages/codex-bin.nix { };
          };

          checks = {
            pre-commit = preCommitCheck;

            format =
              pkgs.runCommand "nix-format-check"
                {
                  nativeBuildInputs = [ pkgs.nixfmt ];
                }
                ''
                  ${pkgs.lib.getExe pkgs.nixfmt} --check ${checkedSource}
                  touch $out
                '';

            syntax =
              pkgs.runCommand "nix-syntax-check"
                {
                  nativeBuildInputs = [ pkgs.nix ];
                }
                ''
                  export NIX_STATE_DIR="$TMPDIR/nix-state"
                  mkdir -p "$NIX_STATE_DIR"

                  find ${checkedSource} -type f -name '*.nix' \
                    -exec nix-instantiate --eval-store dummy:// --parse {} + >/dev/null
                  touch $out
                '';

            statix =
              pkgs.runCommand "statix-check"
                {
                  nativeBuildInputs = [ pkgs.statix ];
                }
                ''
                  ${pkgs.lib.getExe pkgs.statix} check ${checkedSource}
                  touch $out
                '';

            deadnix =
              pkgs.runCommand "deadnix-check"
                {
                  nativeBuildInputs = [ pkgs.deadnix ];
                }
                ''
                  ${pkgs.lib.getExe pkgs.deadnix} --fail ${checkedSource}
                  touch $out
                '';
          }
          // nixpkgs.lib.optionalAttrs (system == "x86_64-linux") {
            nixos-smi-nix = nixosConfigurations.smi-nix.config.system.build.toplevel;
          }
          // nixpkgs.lib.optionalAttrs (system == "aarch64-darwin") {
            darwin-smi-mac = darwinConfigurations.smi-mac.system;
          };
        }
      )
    // {
      lib = smiLib;
      inherit darwinConfigurations nixosConfigurations;
    };
}
