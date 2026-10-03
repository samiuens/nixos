{ lib, pkgs, ... }:

let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in
{
  smi.system.users.users.smi.programs.development = {
    bun.enable = true;
    claude-code.enable = true;
    codex.enable = true;
    direnv.enable = true;
    gh.enable = true;
    nodejs.enable = true;

    orbstack.enable = lib.mkIf isDarwin true;

    pnpm.enable = true;
    python.enable = true;
    t3-code.enable = true;
    uv.enable = true;

    git = {
      enable = true;
      userName = "Sami Arda Ünsay";
      userEmail = "192653549+samiuens@users.noreply.github.com";

      providers.github = {
        host = "github.com";
        userName = "samiuens";
      };

      signing.enable = true;
    };
  };
}
