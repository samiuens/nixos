{ lib }:

{
  config,
  permissionLevel,
  extraGroups ? [ ],
}:

let
  enabled = path: lib.attrByPath path false config;

  staticGroups = [
    "audio"
    "video"
  ];

  conditionalGroups = [
    {
      group = "wheel";
      condition = permissionLevel == "admin";
    }
    {
      group = "networkmanager";
      condition = enabled [
        "smi"
        "networking"
        "networkmanager"
        "enable"
      ];
    }
    {
      group = "docker";
      condition = enabled [
        "smi"
        "virtualization"
        "docker"
        "enable"
      ];
    }
    {
      group = "podman";
      condition = enabled [
        "smi"
        "virtualization"
        "podman"
        "enable"
      ];
    }
  ];
in
lib.unique (
  staticGroups
  ++ extraGroups
  ++ map (entry: entry.group) (lib.filter (entry: entry.condition) conditionalGroups)
)
