---
name: nix-check
description: Use after editing any .nix file in this repo and before proposing a commit — runs the same four checks CI runs (nixfmt, nix-instantiate syntax, statix, deadnix), explains how to fix each failure, and covers which checks are cheap versus expensive.
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
