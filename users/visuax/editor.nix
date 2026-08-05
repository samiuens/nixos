{ pkgs, ... }:

let
  openVsx = pkgs.nix4vscode.forOpenVsx;
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
  smi.system.users.users.visuax.programs.editor = {
    vscodium = {
      enable = true;

      profiles = {
        default = {
          extensions = commonVscodiumExtensions;
          userSettings = commonVscodiumSettings;
          enableExtensionUpdateCheck = false;
          enableUpdateCheck = false;
        };

        web = {
          extensions =
            commonVscodiumExtensions
            ++ (openVsx [
              "dbaeumer.vscode-eslint"
              "esbenp.prettier-vscode"
              "bradlc.vscode-tailwindcss"
              "astro-build.astro-vscode"
              "Vue.volar"
              "Nuxtr.nuxtr-vscode"
            ]);
          userSettings = commonVscodiumSettings // {
            "[javascript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
            "[javascriptreact]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
            "[typescript]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
            "[typescriptreact]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
            "[json]"."editor.defaultFormatter" = "esbenp.prettier-vscode";
          };
        };
      };
    };

    zed.enable = true;
  };
}
