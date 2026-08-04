{ pkgs, ... }:

let
  openVsx = pkgs.nix4vscode.forOpenVsx;
in
{
  smi.system.users.users.smi = {
    description = "Sami Arda Ünsay";
    permissionLevel = "admin";

    packages = with pkgs; [ ];

    desktop = {
      niri.enable = true;
    };

    programs = {
      browser = {
        firefox.enable = true;

        zen = {
          enable = true;
          setAsDefaultBrowser = true;
          betterfox.enable = true;
        };
      };

      development = {
        codex.enable = true;
        direnv.enable = true;
        gh.enable = true;

        git = {
          enable = true;
          userName = "Sami Arda Ünsay";
          userEmail = "192653549+samiuens@users.noreply.github.com";

          providers = {
            github = {
              host = "github.com";
              userName = "samiuens";
            };
          };

          signing.enable = true;
        };
      };

      editor = {
        vscodium =
          let
            commonVscodiumExtensions = openVsx [
              "antfu.theme-vitesse"
              "miguelsolorio.symbols"
              "editorconfig.editorconfig"
              "aaron-bond.better-comments"
              "eamodio.gitlens"
              "seatonjiang.gitmoji-vscode"
              "usernamehw.errorlens"
              "mkhl.direnv"
            ];
            commonVscodiumSettings = {
              "editor.fontFamily" = "JetBrains Mono";
              "editor.fontSize" = 16;
              "editor.lineHeight" = 1.8;
              "editor.fontLigatures" = true;

              "editor.formatOnSave" = true;
              "editor.smoothScrolling" = true;
              "editor.cursorSmoothCaretAnimation" = "on";
              "editor.cursorBlinking" = "smooth";

              "workbench.colorTheme" = "Vitesse Dark";
              "workbench.iconTheme" = "symbols";
              "workbench.sideBar.location" = "left";
              "workbench.activityBar.location" = "default";
              "workbench.list.smoothScrolling" = true;

              "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font";
              "terminal.integrated.fontSize" = 14;
              "terminal.integrated.smoothScrolling" = true;
              "terminal.integrated.fontLigatures.enabled" = true;

              "files.autoSave" = "onFocusChange";

              "git.autofetch" = true;
              "git.confirmSync" = false;
              "telemetry.telemetryLevel" = "off";
              "update.mode" = "none";
              "extensions.autoUpdate" = false;

              "editor.minimap.enabled" = false;
              "breadcrumbs.enabled" = false;
              "editor.stickyScroll.enabled" = false;
              "editor.guides.indentation" = false;
              "editor.renderWhitespace" = "none";
              "editor.overviewRulerBorder" = false;
              "editor.hideCursorInOverviewRuler" = true;
              "window.commandCenter" = false;
              "workbench.layoutControl.enabled" = false;
              "workbench.startupEditor" = "none";
              "workbench.tips.enabled" = false;
            };
          in
          {
            enable = true;

            profiles = {
              default = {
                extensions = commonVscodiumExtensions;
                userSettings = commonVscodiumSettings;
                enableExtensionUpdateCheck = false;
                enableUpdateCheck = false;
              };

              typst = {
                extensions =
                  commonVscodiumExtensions
                  ++ (openVsx [
                    "myriad-dreamin.tinymist"
                    "tomoki1207.pdf"
                  ]);
                userSettings = commonVscodiumSettings // {
                  "[typst]"."editor.defaultFormatter" = "myriad-dreamin.tinymist";
                  "tinymist.formatterMode" = "typstyle";
                };
              };
            };
          };

        zed.enable = true;
      };

      security = {
        bitwarden.enable = true;
      };

      shell = {
        eza.enable = true;

        fish = {
          enable = true;
          interactiveShellInit = ''
            set -g fish_greeting
          '';
          plugins = {
            autopair.enable = true;
            bang-bang.enable = true;
            done.enable = true;
            fzf.enable = true;
            sponge.enable = true;
          };
        };

        starship = {
          enable = true;
          settings = {
            add_newline = false;
            format = "$username$hostname$directory$git_branch$git_status$character";
            right_format = "$cmd_duration$nix_shell$nodejs$python$rust$golang$zig";
            username = {
              format = "[$user]($style)@";
              style_root = "bold red";
              style_user = "blue";
            };

            hostname = {
              format = "[$hostname]($style) ";
              ssh_only = true;
              style = "blue";
            };

            directory = {
              format = "[$path]($style) ";
              style = "bold blue";
              truncation_length = 3;
              truncation_symbol = "…/";
            };

            git_branch = {
              format = "[$symbol$branch]($style) ";
              style = "purple";
              symbol = " ";
            };

            git_status = {
              ahead = "⇡";
              behind = "⇣";
              conflicted = "=";
              deleted = "-";
              diverged = "⇕";
              format = "[($all_status$ahead_behind)]($style) ";
              modified = "~";
              renamed = "»";
              staged = "+";
              stashed = "*";
              style = "yellow";
              untracked = "?";
            };

            character = {
              error_symbol = "[❯](bold red) ";
              success_symbol = "[❯](bold green) ";
            };

            cmd_duration = {
              format = "[$duration]($style) ";
              min_time = 2000;
              style = "muted";
            };

            nix_shell = {
              format = "[$symbol$state]($style) ";
              style = "blue";
              symbol = " ";
            };

            nodejs = {
              format = "[$symbol$version]($style) ";
              style = "green";
              symbol = " ";
            };

            python = {
              format = "[$symbol$version]($style) ";
              style = "yellow";
              symbol = " ";
            };

            rust = {
              format = "[$symbol$version]($style) ";
              style = "red";
              symbol = " ";
            };

            golang = {
              format = "[$symbol$version]($style) ";
              style = "blue";
              symbol = " ";
            };

            zig = {
              format = "[$symbol$version]($style) ";
              style = "yellow";
              symbol = " ";
            };
          };
        };

        tmux = {
          enable = true;
          autoAttach = true;
          defaultSession = "main";
          keyMode = "vi";
          prefix = "C-b";
          statusPosition = "bottom";
          plugins = {
            continuum.enable = true;
            resurrect.enable = true;
            sessionx.enable = true;
          };
        };
      };

      terminal.ghostty = {
        enable = true;
        settings = {
          font-family = "JetBrainsMono Nerd Font";
          font-size = 12;

          window-padding-x = 10;
          window-padding-y = 10;
          window-padding-balance = true;
          gtk-titlebar = false;
        };
      };

      sync = {
        nextcloud-client.enable = true;
      };
    };

    services = { };
  };
}
