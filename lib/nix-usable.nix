{ lib }:

pkgs: package:
package != null
&& lib.meta.availableOn pkgs.stdenv.hostPlatform package
&& !(package.meta.broken or false)
