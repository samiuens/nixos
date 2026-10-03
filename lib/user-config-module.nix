# `hostName` names the host being built, after its directory in `hosts/`. It is
# what `programs.<...>.hosts` is matched against, and is required rather than
# defaulted so a missing argument fails loudly instead of quietly scoping every
# program to nothing.
{ lib }:

{ hostName }:

let
  inherit (lib) mkEnableOption mkOption types;
  flatpakPackageType = with types; either str attrs;

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
    mkOption {
      type = types.submodule (
        { config, ... }:
        {
          options = {
            enable = mkEnableOption description;

            hosts = mkOption {
              type = types.nullOr (types.listOf types.str);
              default = null;
              example = [ "smi-nix" ];
              description = ''
                Hosts this program is enabled on, named after their directory in
                `hosts/`. The default of `null` means every host; naming hosts
                turns the program off on all the others, whatever `enable` says
                there.

                This is for a program wanted on some machines but not others.
                A program that only exists on one platform belongs behind a
                `pkgs.stdenv.hostPlatform` check instead, so adding a second
                machine of that kind does not mean editing every list.
              '';
            };

            excludeHosts = mkOption {
              type = types.listOf types.str;
              default = [ ];
              example = [ "smi-mac" ];
              description = ''
                Hosts this program is turned off on, for when naming the hosts
                that keep it would be the longer list. A host named here loses
                the program even if `hosts` also names it.
              '';
            };
          }
          // options;

          config =
            lib.mkIf
              (
                (config.hosts != null && !(builtins.elem hostName config.hosts))
                || builtins.elem hostName config.excludeHosts
              )
              {
                enable = lib.mkForce false;
              };
        }
      );
      default = { };
    };
in
{
  options = {
    desktop = section {
      gnome = program "GNOME desktop preferences" { };
      niri = program "Niri desktop preferences" {
        noctalia = section {
          plugins = mkOption {
            type = types.listOf types.str;
            default = [ ];
            description = "Noctalia plugin identifiers enabled for this user.";
          };
        };
      };
    };

    programs = section {
      raw = attrsOption "Home Manager program options passed through without translation.";

      ai = section {
        chatgpt = program "ChatGPT desktop app" { };

        claude = program "Claude desktop app" { };
      };

      audio = section {
        pulsemeeter = program "Pulsemeeter" { };
      };

      browser = section {
        chrome = program "Chrome" { };
        firefox = program "Firefox" { };

        zen = program "Zen Browser" {
          setAsDefaultBrowser = mkOption {
            type = types.bool;
            default = false;
            description = "Whether to use Zen Browser as the default browser.";
          };

          doh = program "DNS over HTTPS for Zen Browser" {
            uri = mkOption {
              type = types.str;
              default = "https://dns.quad9.net/dns-query";
              description = "DNS over HTTPS resolver URI used by Zen Browser.";
            };
          };

          betterfox = program "Betterfox preferences for Zen Browser" { };

          containers = mkOption {
            type = types.attrsOf (
              types.submodule {
                options = {
                  color = mkOption {
                    type = types.str;
                    default = "blue";
                    description = "Container colour shown in the tab strip.";
                  };

                  icon = mkOption {
                    type = types.str;
                    default = "circle";
                    description = "Container icon shown in the tab strip.";
                  };

                  id = mkOption {
                    type = types.nullOr types.ints.positive;
                    default = null;
                    description = ''
                      Container number, for one Zen has already written. The
                      default of `null` numbers containers in name order, which
                      is what Zen would have done itself.
                    '';
                  };
                };
              }
            );
            default = { };
            description = ''
              Cookie jars this user's spaces are bound to. Leaving this empty
              keeps the shared default of a single `Personal` container.
            '';
          };

          spaces = mkOption {
            type = types.attrsOf (
              types.submodule {
                options = {
                  icon = mkOption {
                    type = types.str;
                    default = "circle";
                    example = "book";
                    description = ''
                      Name of an icon Zen ships, or a full `chrome://` URL. The
                      bare name is expanded to Zen's selectable icon set.
                    '';
                  };

                  container = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                    example = "School";
                    description = ''
                      Container this space keeps its cookies in, named as
                      declared in `containers`. A name with no container fails
                      the build rather than silently sharing the default jar.
                    '';
                  };

                  position = mkOption {
                    type = types.nullOr types.ints.unsigned;
                    default = null;
                    description = ''
                      Sidebar position. The default of `null` orders spaces by
                      name, a thousand apart, so one can be slotted between two
                      others without renumbering them.
                    '';
                  };

                  id = mkOption {
                    type = types.nullOr types.str;
                    default = null;
                    description = ''
                      UUID of a space Zen has already created. The default of
                      `null` derives one from the name, so a space keeps its
                      pinned tabs when reordered but not when renamed. Pin the
                      existing value to adopt a space rather than replace it.
                    '';
                  };
                };
              }
            );
            default = { };
            description = ''
              Zen workspaces for this user. Leaving this empty keeps the shared
              default of a single `Personal` space.
            '';
          };
        };
      };

      cad = section {
        bambu-studio = program "Bambu Studio" { };
      };

      communication = section {
        signal-desktop = program "Signal Desktop" { };

        vesktop = program "Vesktop Discord client" { };
      };

      development = section {
        bun = program "Bun" { };

        claude-code = program "Claude Code" { };

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

        nodejs = program "Node.js and npm" { };

        orbstack = program "OrbStack container runtime" { };

        pnpm = program "pnpm" { };

        python = program "Python" { };

        t3-code = program "T3 Code" { };

        uv = program "uv" { };
      };

      editor = section {
        arduino-ide = program "Arduino IDE" { };

        datagrip = program "DataGrip" { };

        drawio = program "draw.io desktop" { };

        intellij-idea = program "IntelliJ IDEA Ultimate" { };

        obsidian = program "Obsidian" { };

        vscodium = program "VSCodium" {
          profiles = attrsOption "VSCodium profiles.";
        };

        vscode = program "Visual Studio Code" {
          profiles = attrsOption "Visual Studio Code profiles.";
        };

        zed = program "Zed" { };
      };

      education = section {
        anki = program "Anki" { };
      };

      media = section {
        iina = program "IINA media player" { };
      };

      office = section {
        excel = program "Microsoft Excel" { };
        powerpoint = program "Microsoft PowerPoint" { };
        word = program "Microsoft Word" { };
      };

      security = section {
        bitwarden = program "Bitwarden desktop client" { };
        gnupg = program "hardened GnuPG with YubiKey smart-card support" { };
        keepassxc = program "KeePassXC desktop client" { };
        sops = program "SOPS secrets editor" { };
        yubico-authenticator = program "Yubico Authenticator" { };
        yubikey-manager = program "YubiKey Manager and the ykman CLI" { };
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

          darwinSettings = attrsOption "Ghostty configuration applied on darwin only, layered over settings.";
        };
      };

      utility = section {
        aerospace = program "the AeroSpace tiling window manager" {
          settings = attrsOption "AeroSpace configuration, layered over the shared defaults.";
        };

        amphetamine = program "Amphetamine" { };
        keka = program "Keka file archiver" { };
        linearmouse = program "LinearMouse" { };
        monitorcontrol = program "MonitorControl" { };
        pearcleaner = program "Pearcleaner app uninstaller" { };
        radix = program "Radix disk space analyzer" { };
        raycast = program "Raycast launcher" { };
        rpi-imager = program "Raspberry Pi Imager" { };
        shottr = program "Shottr screenshot tool" { };
        thaw = program "Thaw menu bar manager" { };
      };
    };

    services = section {
      raw = attrsOption "Home Manager service options passed through without translation.";

      flatpak = program "user-scoped declarative Flatpak management" {
        packages = mkOption {
          type = types.listOf flatpakPackageType;
          default = [ ];
          description = "Flatpak applications to install for this user.";
        };

        autoUpdate = section {
          enable = mkEnableOption "automatic Flatpak updates" // {
            default = true;
          };

          onCalendar = mkOption {
            type = types.str;
            default = "weekly";
            description = "Systemd calendar expression for Flatpak updates.";
          };
        };
      };

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
