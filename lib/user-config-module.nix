{ lib }:

let
  inherit (lib) mkEnableOption mkOption types;

  attrsOption =
    description:
    mkOption {
      type = types.attrs;
      default = { };
      inherit description;
    };

  section =
    options:
    mkOption {
      type = types.submodule { inherit options; };
      default = { };
    };

  program =
    description: options:
    section (
      {
        enable = mkEnableOption description;
      }
      // options
    );
in
{
  options = {
    desktop = section {
      gnome = program "GNOME desktop preferences" { };
    };

    programs = section {
      raw = attrsOption "Home Manager program options passed through without translation.";

      audio = section {
        pulsemeeter = program "Pulsemeeter" { };
      };

      browser = section {
        firefox = program "Firefox" { };

        zen = program "Zen Browser" {
          setAsDefaultBrowser = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to use Zen Browser as the default browser.";
          };

          betterfox = program "Betterfox preferences for Zen Browser" { };
        };
      };

      development = section {
        codex = program "Codex" { };

        direnv = program "direnv" {
          "nix-direnv" = program "nix-direnv integration" { };
        };

        gh = program "GitHub CLI" { };

        git = program "Git" {
          userName = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Git author name.";
          };

          userEmail = mkOption {
            type = types.nullOr types.str;
            default = null;
            description = "Git author email address.";
          };

          extraConfig = attrsOption "Additional Git configuration.";

          providers = mkOption {
            type = types.attrsOf (
              types.submodule {
                options = {
                  host = mkOption {
                    type = types.str;
                    description = "SSH hostname for the Git provider.";
                  };

                  userName = mkOption {
                    type = types.str;
                    description = "Account username on the Git provider.";
                  };
                };
              }
            );
            default = { };
            description = "Git providers with dedicated SSH authentication keys.";
          };

          signing = program "SSH commit and tag signing" { };
        };
      };

      editor = section {
        vscodium = program "VSCodium" {
          profiles = attrsOption "VSCodium profiles.";
        };

        vscode = program "Visual Studio Code" {
          profiles = attrsOption "Visual Studio Code profiles.";
        };

        zed = program "Zed" { };
      };

      security = section {
        bitwarden = program "Bitwarden desktop client" { };
      };

      shell = section {
        eza = program "eza" { };

        fish = program "Fish" {
          interactiveShellInit = mkOption {
            type = types.lines;
            default = "";
            description = "Fish commands run when starting an interactive shell.";
          };

          plugins = section {
            autopair = program "Autopair Fish plugin" { };
            bang-bang = program "Bang Bang Fish plugin" { };
            done = program "Done Fish plugin" { };
            fzf = program "fzf Fish plugin" { };
            sponge = program "Sponge Fish plugin" { };
          };
        };

        starship = program "Starship" {
          settings = attrsOption "Starship configuration.";
        };

        tmux = program "tmux" {
          autoAttach = mkOption {
            type = types.bool;
            default = false;
            description = "Whether Ghostty should attach to tmux automatically.";
          };

          defaultSession = mkOption {
            type = types.strMatching "^[A-Za-z0-9_.-]+$";
            default = "main";
            description = "Session Ghostty creates or attaches to automatically.";
          };

          keyMode = mkOption {
            type = types.enum [
              "emacs"
              "vi"
            ];
            default = "emacs";
            description = "Key bindings used in tmux copy mode.";
          };

          prefix = mkOption {
            type = types.str;
            default = "C-b";
            description = "tmux command prefix.";
          };

          statusPosition = mkOption {
            type = types.enum [
              "top"
              "bottom"
              "hidden"
            ];
            default = "bottom";
            description = "Position of the tmux status bar.";
          };

          plugins = section {
            continuum = program "tmux Continuum plugin" { };
            resurrect = program "tmux Resurrect plugin" { };
            sessionx = program "tmux SessionX plugin" { };
          };
        };
      };

      sync = section {
        nextcloud-client = program "Nextcloud desktop client" { };
      };

      terminal = section {
        alacritty = program "Alacritty" {
          settings = attrsOption "Alacritty configuration.";
        };

        ghostty = program "Ghostty" {
          settings = attrsOption "Ghostty configuration.";
        };
      };
    };

    services = section {
      raw = attrsOption "Home Manager service options passed through without translation.";

      security = section {
        gpg-agent = program "GPG agent" {
          defaultCacheTtl = mkOption {
            type = types.nullOr types.ints.unsigned;
            default = null;
            description = "Default GPG agent cache lifetime in seconds.";
          };

          maxCacheTtl = mkOption {
            type = types.nullOr types.ints.unsigned;
            default = null;
            description = "Maximum GPG agent cache lifetime in seconds.";
          };
        };
      };

      sync = section {
        syncthing = program "Syncthing" {
          tray = program "Syncthing tray integration" { };
        };
      };
    };
  };
}
