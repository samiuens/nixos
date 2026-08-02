{ lib }:

users:
lib.unique (
  lib.mapAttrsToList (_: user: user.name) (
    lib.filterAttrs (_: user: user.permissionLevel == "admin") users
  )
)
