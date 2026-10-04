{ lib }:

let
  # Zen keys a space's pinned tabs by this id: renaming a space makes a new one.
  mkId =
    name:
    let
      hash = builtins.hashString "sha256" "zen-space:${name}";
      part = offset: length: builtins.substring offset length hash;
    in
    lib.concatStringsSep "-" [
      (part 0 8)
      (part 8 4)
      "4${part 13 3}"
      "a${part 17 3}"
      (part 20 12)
    ];

  mkIcon =
    icon:
    if lib.hasPrefix "chrome://" icon then
      icon
    else
      "chrome://browser/skin/zen-icons/selectable/${icon}.svg";

  firstFree =
    used: lib.head (lib.filter (n: !(builtins.elem n used)) (lib.range 1 (builtins.length used + 1)));

  defaults = {
    containers = {
      Personal = {
        color = "blue";
        icon = "circle";
        id = null;
      };
    };

    spaces = {
      Personal = {
        icon = "people";
        container = "Personal";
        position = null;
        id = null;
      };
    };
  };
in

cfg:

let
  declaredSpaces = cfg.spaces or { };
  declaredContainers = cfg.containers or { };

  spaces = if declaredSpaces == { } then defaults.spaces else declaredSpaces;
  containers = if declaredContainers == { } then defaults.containers else declaredContainers;

  containerNames = lib.attrNames containers;

  pinned = lib.filter (id: id != null) (map (name: containers.${name}.id) containerNames);

  numbered =
    (lib.foldl'
      (
        state: name:
        let
          id = if containers.${name}.id != null then containers.${name}.id else firstFree state.used;
        in
        {
          used = state.used ++ [ id ];
          ids = state.ids // {
            ${name} = id;
          };
        }
      )
      {
        used = pinned;
        ids = { };
      }
      containerNames
    ).ids;

  containerId =
    space: name:
    if name == null then
      # Zen's own value for a space that is not bound to a container.
      0
    else
      numbered.${name}
        or (throw "zen space '${space}' names container '${name}', which is not declared in programs.browser.zen.containers");
in
{
  containers = lib.mapAttrs (name: container: {
    inherit (container) color icon;
    id = numbered.${name};
  }) containers;

  spaces = lib.listToAttrs (
    lib.imap0 (index: name: {
      inherit name;
      value =
        let
          space = spaces.${name};
        in
        {
          id = if space.id != null then space.id else mkId name;

          position = if space.position != null then space.position else (index + 1) * 1000;

          icon = mkIcon space.icon;
          container = containerId name space.container;
        };
    }) (lib.attrNames spaces)
  );
}
