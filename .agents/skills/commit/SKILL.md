---
name: commit
description: Use when creating git commits in this repo — defines the required message format (Conventional Commits + gitmoji), granularity, and the plan-then-confirm gate before any commit is made.
---

# commit

House rules for git commits in this repo. **These are hard requirements, not suggestions.**

## The gate (never skip)

1. **Only commit when explicitly asked.** Never auto-commit.
2. **Plan first, then show the user.** Before running any `git commit`, write out the
   full commit plan — the grouping of changes and the exact message for each commit —
   and present it to the user.
3. **Wait for confirmation.** Only after the user confirms may you run the `git add` /
   `git commit` commands. If they ask for changes, revise the plan and show it again.

**Violating the letter of these rules is violating the spirit.** "It's obviously fine" /
"they clearly want it committed" / "just this once" are not confirmations. No confirmation → no commit.

## Message format

```
<emoji> <type>(<scope>): <subject>
```

- `<scope>` is optional; use it when it adds clarity (`hero`, `nav`, `i18n`).
- **Subject:** lowercase, English, imperative mood, no trailing period.
- **No body.** Subject line only — pass exactly one message argument to `git commit`.
- **No co-author trailer.** No `Co-Authored-By`, no "Generated with" line.
- Add `!` immediately before `:` for a breaking change (`💥 feat(api)!: drop legacy auth`).

Examples:

```
✨ feat(hero): add video playback rate control
🐛 fix(nav): correct logo scaling on mobile
💄 style(services): refine bullet spacing
📝 docs: document i18n page-adding workflow
```

## Granularity

**Very granular — one logical change per commit.** If a diff mixes two concerns, split
it into two commits (stage with pathspecs or hunks). Prefer more, smaller commits over
fewer large ones. A commit's subject should describe one thing without needing "and".

Include directly related tests, docs, fixtures, generated files, or lockfile updates with
the change when separating them would leave the commit incomplete.

## Type → gitmoji

Common defaults for this repo. **The full, verified gitmoji list is in
[references/gitmojis.md](references/gitmojis.md)** — consult it when none of these fit.

| type       | emoji | when                                   |
|------------|-------|----------------------------------------|
| `feat`     | ✨    | new feature / capability               |
| `fix`      | 🐛    | bug fix                                |
| `docs`     | 📝    | documentation only                     |
| `style`    | 🎨    | code formatting / structure, no logic  |
| `style`    | 💄    | UI / visual design / styling           |
| `refactor` | ♻️    | restructure without behavior change    |
| `perf`     | ⚡️   | performance                            |
| `test`     | ✅    | tests                                  |
| `build`    | 👷    | build system / tooling / deps config   |
| `ci`       | 💚    | CI config / pipelines                  |
| `chore`    | 🔧    | config, housekeeping                   |
| `chore`    | 🔥    | remove code or files                   |
| `chore`    | 🚚    | move / rename files                    |
| `chore`    | ⬆️    | upgrade dependencies                   |
| `revert`   | ⏪️   | revert a previous commit               |

Pick the emoji that best fits the *intent* of the change; the table gives the default
per type plus common situational choices. Commit the literal emoji character, never the
`:shortcode:` form.

## Workflow

1. **Plan.** Inspect read-only git state — `git status`, staged diff, unstaged diff,
   untracked files, and `git log --oneline` for local convention. Do not touch the index
   or working tree while planning. Produce a very granular plan: for each commit, the
   `git add` pathspec(s) or hunks and the exact subject line. Call out ambiguous
   boundaries, already-staged content, and anything that should stay uncommitted.
2. **Show & confirm.** Present the plan as a numbered list and stop. Nothing is staged or
   committed yet. If the user wants changes, revise and show it again. If the working tree
   or index changes after approval, stop and re-present.
3. **Execute.** Only after confirmation: stage the approved paths or hunks (patch staging
   when a file spans multiple commits), review the staged diff for scope, secrets, and
   generated noise, then commit — one commit per approved group. Report the resulting
   `git log --oneline`. Do not push unless separately asked.

If the runtime supports model selection, run the plan and execute steps on a low-cost
model (subagent) — this workflow is mechanical and does not need a stronger one.

## Safety boundaries

- Never use broad staging (`git add .`, `git add -A`, `git commit -a`) when unrelated
  changes exist.
- Never discard, overwrite, or clean outstanding changes.
- Never unstage already-staged work without explicit permission.
- Never amend, squash, rebase, or otherwise rewrite existing commits unless asked.
- Never bypass hooks unless the user asks and understands the consequence. If a hook
  rewrites files, stop, show the resulting state, and ask how to proceed.

## Red flags — stop

- About to `git commit` without having shown a plan → stop, show the plan first.
- Bundling unrelated changes into one commit → split them.
- Reaching for a body, a scope you're unsure of, or a co-author line → drop it.
- Capitalized or non-English subject → rewrite lowercase English imperative.
