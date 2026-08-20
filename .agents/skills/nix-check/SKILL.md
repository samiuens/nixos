---
name: nix-check
description: Use after editing any .nix file in this repo and before proposing a commit — runs the same checks CI runs (nixfmt, nix-instantiate syntax, statix, deadnix, plus evaluation of the aarch64-darwin host), explains how to fix each failure, and covers which checks are cheap versus expensive.
---

# nix-check

CI runs four checks on every push and pull request. All four are reproducible locally.
**Run them after editing any `.nix` file and before presenting a commit plan** — a red CI
run on this repo is almost always one of these four, and all of them are cheap to catch
here.

## The fast loop (use this while iterating)

`.envrc` is `use flake`, so with direnv allowed the devShell tools are already on `$PATH`
inside the repo — `nixfmt`, `statix`, `deadnix`, plus `nil` and `nixd`. Running them
directly is seconds, not minutes.

**Every one of these must exclude `hosts/smi-nix/hardware-configuration.nix`.** CI filters
that file out of the source tree it checks; run the tools bare on `.` and you get failures
CI will never report, on a file you must not touch:

```bash
# formatting — nixfmt has no exclude flag, so pass the file list
nixfmt --check $(find . -name '*.nix' -not -name hardware-configuration.nix -not -path './.direnv/*')

statix check -i hardware-configuration.nix .

deadnix --fail --exclude ./hosts/smi-nix/hardware-configuration.nix .
```

All three exit non-zero on failure, so they work in a `&&` chain. For syntax, run
`nix-instantiate --eval-store dummy:// --parse <file>` on the files you touched. If direnv
is not active, `nix develop -c <cmd>` gets the same tools.

## The authoritative check (use this before committing)

These are the exact derivations CI builds, one workflow each:

```bash
nix build .#checks.x86_64-linux.format    # .github/workflows/nixfmt.yaml
nix build .#checks.x86_64-linux.syntax    # .github/workflows/nix-instantiate.yaml
nix build .#checks.x86_64-linux.statix    # .github/workflows/statix.yaml
nix build .#checks.x86_64-linux.deadnix   # .github/workflows/deadnix.yaml
```

They run against a cleaned source tree, so they see committed *and* uncommitted files but
never `hardware-configuration.nix` (filtered out in `flake.nix`).

**Do not reach for `nix flake check` as the default.** It also builds the
`nixos-smi-nix` check — the full system toplevel — which is a complete system build, not a
lint. Run it only when you actually want to verify the system evaluates and builds.
`nix flake check --no-build --all-systems` is the cheap variant: it evaluates everything
for both `x86_64-linux` and `aarch64-darwin` without building, and is what the
`update flake lock` workflow runs.

## The darwin configuration

`hosts/smi-mac` is an `aarch64-darwin` nix-darwin host. It cannot be *built* on a Linux
machine, but it does evaluate on one, and that evaluation is what CI checks
(`.github/workflows/darwin.yaml`):

```bash
nix eval .#checks.aarch64-darwin.darwin-smi-mac.drvPath
```

**Run it after touching anything under `home/`, `lib/`, `users/`, or `modules/darwin/`.**
The first three are shared between both hosts, so it is easy to break the Mac from a file
that looks Linux-only — and none of the four lint checks above will notice.

A new module that is still untracked is invisible to the flake, so the check happily passes
over a file it never read. If a change appears to have no effect, `git add -N` it before
concluding anything.

## Getting an application from Homebrew

The usual darwin failure is a package with no `aarch64-darwin` support. The fix is not to
drop the package — route it through `lib/app-catalogue.nix`, which pairs each nixpkgs
package with a Homebrew cask. `modules/darwin/system/homebrew.nix` and the home modules
both read that one catalogue, so the two never drift.

```nix
# lib/app-catalogue.nix — keyed by the option path in users/
"programs.sync.nextcloud-client" = {
  package = pkgs.nextcloud-client;
  cask = "nextcloud";
};
```

Then gate the home module on the catalogue rather than on the package — see
`home/programs/security/bitwarden.nix` or `home/programs/editor/zed.nix`:

```nix
useNixPackage = smiLib.preferNixPackage pkgs "programs.security.bitwarden";
```

`preferNixPackage` takes the **option path, not the package**, and throws on a path the
catalogue does not define, so a typo fails the darwin check instead of silently installing
nothing.

Entries added this way need no further change: the cask appears on darwin, and disappears
again once nixpkgs gains support upstream.

`smiLib.nixUsable` is the underlying predicate. Call it directly only for a package with no
catalogue entry, as `home/programs/development/claude-code.nix` does — it cannot see
`preferCask`. The three older catalogue entries (`yubico-authenticator`, `nextcloud-client`,
`ghostty`) still call it and name their package twice; move them to `preferNixPackage` when
you next touch them.

### When nixpkgs *does* build it

Set `preferCask` to take the cask anyway — for a signed `/Applications` bundle, or because
nixpkgs trails the cask by several releases. It is ignored on Linux, where nixpkgs is the
only source:

```nix
"programs.editor.zed" = {
  package = pkgs.zed-editor;
  cask = "zed";
  preferCask = true;
};
```

Without a `preferCask` entry the fallback will not fire, because `nixUsable` reports the
package as perfectly usable on darwin.

### When there is no nixpkgs package at all

Skip the catalogue — there is nothing to pair. Use `smi.system.homebrew.extraCasks` in
`hosts/smi-mac/configuration.nix`, plus `extraTaps` when the cask is not in `homebrew/cask`.

Verify any of the above with:

```bash
nix eval .#darwinConfigurations.smi-mac.config.homebrew.casks --apply 'cs: map (c: c.name) cs' --json
```

Casks are not pinned by `flake.lock`, so this tells you *which* casks, never which versions.

## Fixing each failure

| check | fix |
|---|---|
| `format` | `nix fmt` (the flake's formatter is `nixfmt`), or `nixfmt <file>` for one file |
| `syntax` | Real parse error — read the reported line; usually a missing `;`, brace, or paren |
| `statix` | `statix fix .` handles the auto-fixable lints; read the rest, they're usually genuine simplifications |
| `deadnix` | Remove the unused binding by hand. `deadnix --edit` works but edits aggressively — inspect its diff before keeping it |

## Rules

- **Never edit or format `hardware-configuration.nix`.** It is deliberately excluded from
  every check and is machine-generated.
- Re-run the relevant check after applying a fix. `statix fix` and `nix fmt` change files,
  which can in turn affect the format check.
- **Report failures honestly.** If a check fails and the fix is unclear, say so and show
  the output — do not present a commit plan that will turn CI red.
- If a check fails on code you did not touch, say that explicitly rather than silently
  fixing unrelated files into your commit.
