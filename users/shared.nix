{ lib, pkgs, ... }:

let
  context7Url = "https://mcp.context7.com/mcp";

  # Headless keeps browser windows out of the way while an agent works.
  playwright = [
    (lib.getExe pkgs.playwright-mcp)
    "--headless"
  ];
in
{
  smi.system.users.shared.programs.development = {
    # Forced so users seeded with the 1M-context model move off it.
    openchamber.overrideSettings.defaultModel = "claude-code/claude-opus-5-5";

    opencode.mcpServers = {
      context7 = {
        type = "remote";
        url = context7Url;
      };

      playwright = {
        type = "local";
        command = playwright;
      };
    };

    claude-code.mcpServers = {
      context7 = {
        type = "http";
        url = context7Url;
      };

      playwright = {
        type = "stdio";
        command = lib.head playwright;
        args = lib.tail playwright;
      };
    };
  };
}
