{ lib, pkgs, ... }:

let
  openVsx = pkgs.nix4vscode.forOpenVsx;
  Vscode = pkgs.nix4vscode.forVscode;
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
    "breadcrumbs.enabled" = false;
    "editor.cursorBlinking" = "smooth";
    "editor.cursorSmoothCaretAnimation" = "on";
    "editor.fontFamily" = "JetBrains Mono";
    "editor.fontLigatures" = true;
    "editor.fontSize" = 16;
    "editor.formatOnSave" = true;
    "editor.guides.indentation" = false;
    "editor.hideCursorInOverviewRuler" = true;
    "editor.lineHeight" = 1.8;
    "editor.minimap.enabled" = false;
    "editor.overviewRulerBorder" = false;
    "editor.renderWhitespace" = "none";
    "editor.smoothScrolling" = true;
    "editor.stickyScroll.enabled" = false;
    "extensions.autoCheckUpdates" = false;
    "extensions.autoUpdate" = "off";
    "files.autoSave" = "onFocusChange";
    "git.autofetch" = true;
    "git.confirmSync" = false;
    "telemetry.telemetryLevel" = "off";
    "terminal.integrated.fontFamily" = "JetBrainsMono Nerd Font";
    "terminal.integrated.fontLigatures.enabled" = true;
    "terminal.integrated.fontSize" = 14;
    "terminal.integrated.smoothScrolling" = true;
    "update.mode" = "none";
    "window.commandCenter" = false;
    "workbench.activityBar.location" = "default";
    "workbench.colorTheme" = "Vitesse Dark";
    "workbench.iconTheme" = "symbols";
    "workbench.layoutControl.enabled" = false;
    "workbench.list.smoothScrolling" = true;
    "workbench.sideBar.location" = "left";
    "workbench.startupEditor" = "none";
    "workbench.tips.enabled" = false;
  };
in
{
  smi.system.users.users.smi.programs.editor = {
    datagrip.enable = true;

    # Only wanted on the mac so far.
    drawio.enable = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin true;

    intellij-idea.enable = true;

    obsidian.enable = true;

    vscodium = {
      enable = true;

      profiles = {
        default = {
          extensions = commonVscodiumExtensions;
          userSettings = commonVscodiumSettings;
          enableExtensionUpdateCheck = false;
          enableUpdateCheck = false;
        };

        infrastructure = {
          extensions =
            commonVscodiumExtensions
            ++ (openVsx [
              "redhat.vscode-yaml"
              "redhat.ansible"
              "nefrob.vscode-just-syntax"
            ])
            ++ (Vscode [
              "pulumi.pulumi-vscode-tools"
              "ms-python.python"
              "ms-python.vscode-python-envs"
            ]);
          userSettings = commonVscodiumSettings // {
            "redhat.telemetry.enabled" = false;
          };
        };

        typst = {
          extensions =
            commonVscodiumExtensions
            ++ (openVsx [
              "myriad-dreamin.tinymist"
              "tomoki1207.pdf"
            ])
            ++ (Vscode [
              "hediet.vscode-drawio"
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
}
