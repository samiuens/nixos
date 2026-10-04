{
  smi.system.users.users.fittedgroup.programs.development = {
    bun.enable = true;
    claude-code.enable = true;
    direnv.enable = true;
    glab.enable = true;
    nodejs.enable = true;
    pnpm.enable = true;
    python.enable = true;
    uv.enable = true;

    git = {
      enable = true;
      userName = "Sami Arda Ünsay";
      userEmail = "sami.uensay@fitted.group";

      providers.gitlab = {
        host = "gitlab.com";
        userName = "sami.fittedgroup";
      };

      signing.enable = true;
    };
  };
}
