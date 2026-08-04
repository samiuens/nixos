{
  smi.system.users.users.fittedgroup.programs.development = {
    claude-code.enable = true;
    direnv.enable = true;
    gh.enable = true;

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
