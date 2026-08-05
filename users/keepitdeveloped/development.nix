{
  smi.system.users.users.keepitdeveloped.programs.development = {
    bun.enable = true;
    claude-code.enable = true;
    direnv.enable = true;
    gh.enable = true;
    nodejs.enable = true;
    pnpm.enable = true;

    git = {
      enable = true;
      userName = "Sami Arda Ünsay";
      userEmail = "sami.uensay@keepitdeveloped.com";

      providers.gitlab = {
        host = "gitlab.com";
        userName = "samiuensay.kid";
      };

      signing.enable = true;
    };
  };
}
