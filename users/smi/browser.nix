{
  smi.system.users.users.smi.programs.browser = {
    zen = {
      enable = true;
      setAsDefaultBrowser = true;
      betterfox.enable = true;

      containers = {
        Personal = {
          color = "blue";
          icon = "circle";
        };

        School = {
          color = "orange";
          icon = "briefcase";
        };
      };

      spaces = {
        Personal = {
          icon = "people";
          container = "Personal";

          # Pinned rather than derived: Zen created this space long before the
          # id was config, and it keys the space's pinned tabs. Deriving one
          # here would read as a different space and start it empty.
          id = "b0b21938-b3e1-4d42-8766-b5c10368b80d";
        };

        School = {
          icon = "book";
          container = "School";
        };
      };
    };
  };
}
