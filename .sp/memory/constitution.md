<!--
Sync Impact Report
==================
Version change: 1.0.0 -> 1.0.1
Amendment: migrate to .sp constitution terminology, update the current formula name, and require Conventional Commits. The prior file was the
unfilled upstream template, so every Constitution Check passed vacuously.

Modified principles:
  template principle 1 → 1. Release Provenance (url + sha256)
  template principle 2 → 2. Vendored Resources Match Real Runtime Dependencies
  template principle 3 → 3. The Formula Is Generated, Not Hand-Written
  template principle 4 → 4. Hand Review Is the Only Gate
  template principle 5 → 5. Formula Prose Describes Present Behavior

Added sections:
  Relationship to the Workspace Constitution
  Repository Context
  Review Scope
  Review Output Format
  Governance

Removed sections:
  template section 2 and section 3 placeholder slots (folded into the
  concrete sections above).

Templates:
  ✅ .sp/templates/plan-template.md   - "Constitution Check" gate derives from
     this file ("[Gates determined based on constitution file]"); no edit needed.
  ✅ .sp/templates/spec-template.md   - no mandatory section added or removed.
  ✅ .sp/templates/tasks-template.md  - no new principle-driven task type.
  ✅ .claude/commands/constitution.md        - generic agent wording, no stale refs.
  ✅ README.md                           - Maintenance section already matches
     principle 3; no edit needed.

Deferred / omitted:
  Deliberately no pillar on test coverage, type safety, or UI. See "What This
  Constitution Does Not Cover".
-->

# Spare Parts Labs Homebrew Tap Constitution

This is the practical review standard for this repository: Homebrew formulae for
Spare Parts Labs command-line tools. It is a reviewer's working document.

## Relationship to the Workspace Constitution

The workspace constitution above this repo (`.sp/memory/constitution.md` at the
workspace root) holds the patterns shared across every Spare Parts repo: commit
hygiene, user-facing copy rules, docs tense, executor routing, and the review
findings format. Reference it for those shared patterns. Where it and this
constitution disagree, **this constitution takes precedence** for work in this repo.

This clause is load-bearing. The constitution commands are repo-scoped, so a Constitution
Check only ever reads this file. Without this section the shared patterns are
unreachable.

## Repository Context

A reviewer needs these facts before reading a diff here.

- The tap holds one formula today, `Formula/spareparts-cli.rb`. The repo has no application source or test suite. Its only CI is secret scanning; no workflow validates the formula.
- `main` is updated by a bot pushing **directly**, not by pull request. The
  `spareparts-cli` repo's `.github/workflows/homebrew.yml` bumps this formula on every
  `v*` tag using `HOMEBREW_TAP_TOKEN`. Twelve of the fifteen commits touching
  `Formula/` are `github-actions[bot]` release commits.
- `main` is branch-protected (1 review, linear history, no force-push). The bot's
  direct push works only because its token belongs to an admin and
  `enforce_admins` is off. That is the whole reason principle 3 exists: the
  protection that would stop a human does not stop the bot.
- The bot's release commits are subject-only, of the form `spareparts-cli 0.15.0`.
  They are machine-generated and predate the workspace commit convention. They
  are not a precedent for hand-written commits, which follow the workspace rule.

## Review Scope

Review the diff, not the whole repository. Judge what changed against the pillars
below. Do not file findings about pre-existing code the diff does not touch, with
one exception: if the diff edits a line that is adjacent to something already
broken, say so as a suggestion.

## Review Pillars

### 1. Release Provenance (url + sha256)

The `url` must point at a real published PyPI sdist and the `sha256` must be that
exact file's digest. Homebrew verifies the digest at install time, so a mismatch
is not a style problem, it is a broken `brew install` for every user.

- **Flag** any `url` or `sha256` changed without the other changing, any digest
  that is a placeholder or a repeat of the previous release's value, and any
  `url` whose version does not match the version elsewhere in the diff.
- **Flag** a `url` that is not a `files.pythonhosted.org` sdist path, or that
  points at a wheel or a git ref instead of the `.tar.gz` sdist.
- **Commend** a bump where `url` and `sha256` move together and the version in
  the path matches the release being cut.

### 2. Vendored Resources Match Real Runtime Dependencies

The formula installs into its own virtualenv via
`virtualenv_install_with_resources`, so every runtime dependency of the released
package, transitively, must appear as a `resource` block. Nothing is resolved at
install time. A missing resource means the tool imports a module that is not
there.

- **Flag** a version bump that changes the package's dependencies without adding,
  removing, or updating the matching `resource` blocks.
- **Flag** a `resource` block for a package that is not an actual runtime
  dependency, and any resource whose `url` and `sha256` are inconsistent with
  each other by the same rule as pillar 1.
- **Flag** a new dependency added to `spareparts-cli` with no corresponding resource
  here. This has happened: 0.8.0 shipped without the `rich` tree and needed a
  follow-up commit vendoring `rich`, `markdown-it-py`, `mdurl`, and `pygments`.
- **Commend** a bump that lists the full transitive set and keeps
  `depends_on "python@3.12"` consistent with what the package supports.

### 3. The Formula Is Generated, Not Hand-Written

`Formula/spareparts-cli.rb` is output, not source. The generator lives in the
`spareparts-cli` repo's `homebrew.yml`. A hand edit to a generated field survives only
until the next `v*` tag, and it disappears silently, with no PR and no review.
The 0.9.0 release commit rewrote the resource ordering a human had just
committed by hand.

- **Flag** any hand edit to `url`, `sha256`, or `resource` blocks. Recommend the
  fix land in `spareparts-cli`'s `homebrew.yml` instead, so the next release keeps it.
- **Flag** a hand edit that "fixes" a release. If the release is wrong, the fix is
  a new release, not a patch to the tap.
- **Accept** hand edits to fields the generator does not own, such as `desc`,
  `homepage`, `license`, the `test do` block, and repo files outside `Formula/`.
  Say plainly which category the change falls in.
- **Commend** a change to the generator referenced from the diff, rather than a
  local patch.

### 4. Hand Review Is the Only Gate

Nothing in this repo runs `brew audit`, `brew install`, or `brew test`. There is
no CI. Whatever a reviewer misses ships to users on the next `brew install`.

- **Flag** a formula change whose author does not state that they installed it
  locally. `brew install --build-from-source ./Formula/spareparts-cli.rb` and
  `brew audit --strict` are the checks that would otherwise be automated.
- **Flag** a change to the `test do` block that weakens it, for example dropping
  the `assert_match` so the test asserts nothing.
- **Commend** a diff that adds real CI for the formula. That would retire this
  pillar, which is the point.

### 5. Formula Prose Describes Present Behavior

Comments and README text state how the formula works now. They do not narrate how
it got here or predict a future that has already passed.

- **Flag** comment or README prose that describes a transition, a placeholder, or
  a "for now" state that is no longer true. Live example:
  `Formula/spareparts-cli.rb:6-9` still says the `sha256` is a placeholder that "will
  not install" until the first release, fifteen releases in. Any diff touching
  that comment should correct it.
- **Flag** user-facing copy in the README that violates the workspace copy rule.
  Code comments are exempt from that rule.
- **Commend** a comment that explains why a resource is pinned or why a
  dependency is vendored, since that is knowledge the generator cannot carry.

## What This Constitution Does Not Cover

Named so nobody adds these back without evidence.

- **No test-coverage pillar.** There is no test suite to cover. The formula's
  `test do` block is addressed under pillar 4.
- **No type-safety, DRY, or UI pillar.** There is no application code, no shared
  abstraction to duplicate, and no interface. The `core` repo's pillars were
  written for a FastAPI and React monolith and do not transfer.
- **No multi-formula conventions.** One formula exists. Write those rules when a
  second formula arrives and the real pattern is visible.

## Review Output Format

Follow the workspace findings format. Group findings under these headings, most
severe first, and omit any heading with nothing under it.

- ✅ **Passed** - pillars the diff satisfies, named explicitly.
- 🔴 **Critical (must fix)** - a broken install, a wrong digest, a missing
  resource, a hand edit that the next release erases.
- 🟡 **Warnings (may merge with justification)**
- 💡 **Suggestions**

Each finding cites `file:line | issue | recommended fix`. Propose targeted diffs,
never whole-file rewrites. Flag stray debug output. Skip pure style nits unless
they violate a rule stated here.

## Governance

This constitution governs review in this repo and takes precedence over the workspace
constitution on conflict, per the clause above.

- **Amendment**: open a PR editing this file. State which pillar changes and what
  evidence in the repo motivates it. A pillar needs something a reader can point
  at. If the evidence is gone, remove the pillar.
- **Versioning**: semantic. MAJOR removes or redefines a pillar. MINOR adds a
  pillar or materially expands guidance. PATCH clarifies wording.
- **Compliance**: the review runs as a `general-purpose` agent over
  `git --no-pager diff --cached origin/main`, staging new files first. There is
  no `pr-standards-reviewer` subagent type. Do not introduce one.
- **Bot commits are out of scope for review.** They land on `main` without a PR
  by design. If a release commit is wrong, the correction belongs in `spareparts-cli`,
  per pillar 3.

- **Commits**: all commits, including generated formula bumps, MUST use Conventional Commits. Release automation MUST generate a valid type and scope. No AI or tool attribution is allowed.

**Version**: 1.0.1 | **Ratified**: 2026-07-15 | **Last Amended**: 2026-08-09
