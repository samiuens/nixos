{
  smi.system.users.users.smi.programs.development = {
    bun.enable = true;
    claude-code.enable = true;
    #codex.enable = true;
    direnv.enable = true;
    gh.enable = true;
    nodejs.enable = true;
    pnpm.enable = true;
    python.enable = true;
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
