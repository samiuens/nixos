{
  smi.system.users.users.smi.programs.development = {
    codex.enable = true;
    direnv.enable = true;
    gh.enable = true;

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
