# Turns the `spaces` and `containers` a user declared under
# `programs.browser.zen` into the shape Zen stores them in: containers
# numbered, spaces given a stable id and an ordering, and every space's
# container name turned back into that container's number.
#
# Both halves resolve together because a space names its container while Zen
# records the number. Working them out separately would mean repeating the
# numbering in two files and hoping the two never disagree.
{ lib }:

let
  # Zen keys a space's saved state — its pinned tabs and theme — by this id, so
  # it is derived from the name rather than the position: reordering spaces
  # leaves what is inside them alone. Renaming a space is a new space, which is
  # also why `id` can be pinned by hand for one that already exists.
  mkId =
    name:
    let
      hash = builtins.hashString "sha256" "zen-space:${name}";
      part = offset: length: builtins.substring offset length hash;
    in
    lib.concatStringsSep "-" [
      (part 0 8)
      (part 8 4)
      # Version 4 and the variant bits, so the value is a well formed UUID and
      # not just a hex string of the right length.
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

  # Lowest positive number not already taken. `used` grows by one per call, so
  # a range one longer than it always holds a free value.
  firstFree =
    used: lib.head (lib.filter (n: !(builtins.elem n used)) (lib.range 1 (builtins.length used + 1)));

  # Shared baseline, used by a user who declares neither, so enabling Zen
  # still gives a working space rather than an empty sidebar. A user who
  # declares spaces replaces this outright rather than merging with it: a
  # half-inherited sidebar is harder to reason about than a stated one.
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

  # Numbered in name order, leaving any hand-pinned id alone. A user who pins
  # nothing gets 1, 2, 3 … which is what Zen would have written itself.
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

          # Spaced a thousand apart so a space can be slotted between two
          # others by pinning a position, without renumbering the rest.
          position = if space.position != null then space.position else (index + 1) * 1000;

          icon = mkIcon space.icon;
          container = containerId name space.container;
        };
    }) (lib.attrNames spaces)
  );
}
