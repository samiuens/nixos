---
name: commit
description: Plan and create clean, atomic Git commits from outstanding working-tree changes. Use when the user asks to inspect, organize, stage, or commit uncommitted changes and wants an approval-gated commit plan, English lowercase Conventional Commit subjects, gitmojis, no commit body or co-author trailers, and one logical change per repository area in each commit.
---

# Commit

Create a reviewable commit plan, wait for explicit approval, and then make only the approved commits.

## Workflow

1. Use a low-cost model when model selection is available and the repository's complexity or risk does not require a stronger model.
2. Inspect repository instructions and read-only Git state, including status, staged changes, unstaged changes, untracked files, and recent commit conventions. Do not modify the index or working tree during planning.
3. Identify logical changes and affected areas. Keep each proposed commit limited to one coherent change in one area. Include directly related tests, documentation, fixtures, generated files, or lockfile updates with that change when separating them would make the commit incomplete.
4. Split unrelated changes in the same file by staging individual hunks later. Do not rewrite the user's working-tree content merely to manufacture commit boundaries.
5. Read [references/gitmojis.md](references/gitmojis.md) and select the most specific gitmoji for each change.
6. Present the complete plan before staging or committing. For every proposed commit, show the exact subject, its purpose, and the files or hunks it will contain. Call out ambiguous boundaries, already-staged content, and changes that should remain uncommitted.
7. Ask for explicit user confirmation. Do not stage or commit before confirmation. Treat requested edits as a new plan and ask for confirmation again. If the working tree or index changes after approval, stop and present an updated plan.
8. After approval, stage only the approved paths or hunks. Preserve unrelated changes and pre-existing staged intent. Use patch staging when a file belongs to multiple commits.
9. Review the staged diff for scope, accidental secrets, generated noise, and message accuracy before every commit. Run focused checks when they are practical or requested; report skipped or failing checks without hiding them.
10. Commit with exactly one subject-line message. After every commit, verify the resulting commit and remaining status, then continue with the next approved commit. Do not push unless the user separately requests it.

## Commit Subjects

Use this exact structure:

```text
<emoji> <type>(<scope>): <subject>
```

Omit `(scope)` when it does not improve clarity. Add `!` immediately before `:` for a breaking change:

```text
💥 feat(api)!: remove legacy authentication
```

Apply all of these rules:

- Use a literal gitmoji from the bundled catalog, not its `:code:` form.
- Use a valid Conventional Commit type such as `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`, `chore`, or `revert`.
- Write the entire subject in English and lowercase, including the type, optional scope, and summary.
- Use an imperative, concise summary with no trailing period.
- Supply exactly one message argument to create a subject-only commit.
- Add no body, description, footer, attribution, or `Co-authored-by` trailer.
- Do not amend, squash, rebase, or otherwise rewrite existing commits unless the user explicitly requests it.

Examples:

```text
✨ feat(shell): add fish abbreviations
🐛 fix(networking): enable resolved fallback dns
📝 docs: document host bootstrap steps
♻️ refactor(lib): simplify module discovery
🔧 chore(nix): update formatter settings
```

## Approval Plan

Use a compact plan such as:

```text
1. ✨ feat(shell): add fish abbreviations
   area: home/shell
   includes: home/shell/fish.nix and the related assertion hunk in tests

2. 📝 docs: document shell aliases
   area: documentation
   includes: docs/shell.md
```

End the plan with a direct confirmation request. Approval applies only to the displayed messages and scopes.

## Safety Boundaries

- Never use broad staging such as `git add .`, `git add -A`, or `git commit -a` when unrelated changes exist.
- Never discard, overwrite, or clean outstanding changes.
- Never move already-staged changes out of the index without explicit permission.
- Never bypass hooks unless the user explicitly requests it and understands the consequence.
- Stop if a hook changes files or a commit contains content outside the approved scope; show the resulting state and ask how to proceed.
