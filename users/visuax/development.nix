{
  smi.system.users.users.visuax.programs.development = {
    ansible.enable = true;
    bun.enable = true;
    claude-code.enable = true;
    direnv.enable = true;
    glab.enable = true;
    nodejs.enable = true;
    openchamber.enable = true;
    opencode.enable = true;
    opentofu.enable = true;
    pnpm.enable = true;
    python.enable = true;
    t3-code.enable = true;
    uv.enable = true;

    git = {
      enable = true;
      userName = "Sami Arda Ünsay";
      userEmail = "sami@visuax.com";

      providers.gitlab = {
        host = "gitlab.com";
        userName = "sami.visuax";
      };

      signing.enable = true;
    };
  };
}
