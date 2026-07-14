---
description: Generate an actionable, dependency-ordered tasks.md for the feature based on available design artifacts.
---

## User Input

```text
$ARGUMENTS
```

You **MUST** consider the user input before proceeding (if not empty).

## Pre-Execution Checks

**Check for extension hooks (before tasks generation)**:
- Check if `.blitz/extensions.yml` exists in the project root.
- If it exists, read it and look for entries under the `hooks.before_tasks` key
- If the YAML cannot be parsed or is invalid, skip hook checking silently and continue normally
- Filter out hooks where `enabled` is explicitly `false`. Treat hooks without an `enabled` field as enabled by default.
- For each remaining hook, do **not** attempt to interpret or evaluate hook `condition` expressions:
  - If the hook has no `condition` field, or it is null/empty, treat the hook as executable
  - If the hook defines a non-empty `condition`, skip the hook and leave condition evaluation to the HookExecutor implementation
- For each executable hook, output the following based on its `optional` flag:
  - **Optional hook** (`optional: true`):
    ```
    ## Extension Hooks

    **Optional Pre-Hook**: {extension}
    Command: `/{command}`
    Description: {description}

    Prompt: {prompt}
    To execute: `/{command}`
    ```
  - **Mandatory hook** (`optional: false`):
    ```
    ## Extension Hooks

    **Automatic Pre-Hook**: {extension}
    Executing: `/{command}`
    EXECUTE_COMMAND: {command}

    Wait for the result of the hook command before proceeding to the Outline.
    ```
    After emitting the block above you MUST actually invoke the hook and wait for it to finish before continuing. Run it the same way you would run the command yourself in this agent/session (the invocation may differ from the literal `{command}` id shown above, e.g. a skills-mode agent runs it as `/skill:playbook-...` or `$playbook-...`). Emitting the block alone does not run the hook.
- If no hooks are registered or `.blitz/extensions.yml` does not exist, skip silently

## Outline

1. **Setup**: Run `.blitz/scripts/bash/setup-tasks.sh --json` from repo root and parse FEATURE_DIR, TASKS_TEMPLATE, and AVAILABLE_DOCS list. `FEATURE_DIR` and `TASKS_TEMPLATE` must be absolute paths when provided. `AVAILABLE_DOCS` is a list of document names/relative paths available under `FEATURE_DIR` (for example `research.md` or `contracts/`). For single quotes in args like "I'm Groot", use escape syntax: e.g 'I'\''m Groot' (or double-quote if possible: "I'm Groot").

2. **Load design documents**: Read from FEATURE_DIR:
   - **Required**: plan.md (tech stack, libraries, structure), spec.md (user stories with priorities)
   - **Optional**: data-model.md (entities), contracts/ (interface contracts), research.md (decisions), quickstart.md (test scenarios)
   - **IF EXISTS**: Load `/memory/playbook.md` for project principles and governance constraints
   - Note: Not all projects have all documents. Generate tasks based on what's available.

3. **Execute task generation workflow**:
   - Load plan.md and extract tech stack, libraries, project structure
   - Load spec.md and extract user stories with their priorities (P1, P2, P3, etc.)
   - If data-model.md exists: Extract entities and map to user stories
   - If contracts/ exists: Map interface contracts to user stories
   - If research.md exists: Extract decisions for setup tasks
   - Generate tasks organized by user story (see Task Generation Rules below)
   - Generate dependency graph showing user story completion order
   - Create parallel execution examples per user story
   - Validate task completeness (each user story has all needed tasks, independently testable)

4. **Generate tasks.md**: Read the tasks template from TASKS_TEMPLATE (from the JSON output above) and use it as structure. If TASKS_TEMPLATE is empty, fall back to `.blitz/templates/tasks-template.md`. Fill with:
   - Correct feature name from plan.md
   - Phase 1: Setup tasks (project initialization)
   - Phase 2: Foundational tasks (blocking prerequisites for all user stories)
   - Phase 3+: One phase per user story (in priority order from spec.md)
   - Each phase includes: story goal, independent test criteria, tests (if requested), implementation tasks
   - Final Phase: Polish & cross-cutting concerns
   - All tasks must follow the strict checklist format (see Task Generation Rules below)
   - Clear file paths for each task
   - Dependencies section showing story completion order
   - Parallel execution examples per story
   - Implementation strategy section (MVP first, incremental delivery)

## Mandatory Post-Execution Hooks

**You MUST complete this section before reporting completion to the user.**

Check if `.blitz/extensions.yml` exists in the project root.
- If it does not exist, or no hooks are registered under `hooks.after_tasks`, skip to the Completion Report.
- If it exists, read it and look for entries under the `hooks.after_tasks` key.
- If the YAML cannot be parsed or is invalid, skip hook checking silently and continue to the Completion Report.
- Filter out hooks where `enabled` is explicitly `false`. Treat hooks without an `enabled` field as enabled by default.
- For each remaining hook, do **not** attempt to interpret or evaluate hook `condition` expressions:
  - If the hook has no `condition` field, or it is null/empty, treat the hook as executable
  - If the hook defines a non-empty `condition`, skip the hook and leave condition evaluation to the HookExecutor implementation
- For each executable hook, output the following based on its `optional` flag:
  - **Mandatory hook** (`optional: false`) — **You MUST emit `EXECUTE_COMMAND:` for each mandatory hook**:
    ```
    ## Extension Hooks

    **Automatic Hook**: {extension}
    Executing: `/{command}`
    EXECUTE_COMMAND: {command}
    ```
    After emitting the block above you MUST actually invoke the hook and wait for it to finish before continuing. Run it the same way you would run the command yourself in this agent/session (the invocation may differ from the literal `{command}` id shown above, e.g. a skills-mode agent runs it as `/skill:playbook-...` or `$playbook-...`). Emitting the block alone does not run the hook.
  - **Optional hook** (`optional: true`):
    ```
    ## Extension Hooks

    **Optional Hook**: {extension}
    Command: `/{command}`
    Description: {description}

    Prompt: {prompt}
    To execute: `/{command}`
    ```

## Completion Report

Output path to generated tasks.md and summary:
- Total task count
- Task count per user story
- Parallel opportunities identified
- Independent test criteria for each story
- Suggested MVP scope (typically just User Story 1)
- Format validation: Confirm ALL tasks follow the checklist format (checkbox, ID, labels, file paths)

Context for task generation: $ARGUMENTS

The tasks.md should be immediately executable - each task must be specific enough that an LLM can complete it without additional context.

## Task Generation Rules

**CRITICAL**: Tasks MUST be organized by user story to enable independent implementation and testing.

**Tests are OPTIONAL**: Only generate test tasks if explicitly requested in the feature specification or if user requests TDD approach.

### Checklist Format (REQUIRED)

Every task MUST strictly follow this format:

```text
- [ ] [TaskID] [P?] [L?] [Story?] Description with file path
```

**Format Components**:

1. **Checkbox**: ALWAYS start with `- [ ]` (markdown checkbox)
2. **Task ID**: Sequential number (T001, T002, T003...) in execution order
3. **[P] marker**: Include ONLY if task is parallelizable (different files, no dependencies on incomplete tasks)
4. **[L] marker**: Include ONLY if the task is executable by the configured local model (see Executor Annotation below). Omit the marker entirely when no local model is configured.
5. **[Story] label**: REQUIRED for user story phase tasks only
   - Format: [US1], [US2], [US3], etc. (maps to user stories from spec.md)
   - Setup phase: NO story label
   - Foundational phase: NO story label
   - User Story phases: MUST have story label
   - Polish phase: NO story label
6. **Description**: Clear action with exact file path

**Examples**:

- ✅ CORRECT: `- [ ] T001 Create project structure per implementation plan`
- ✅ CORRECT: `- [ ] T005 [P] Implement authentication middleware in src/middleware/auth.py`
- ✅ CORRECT: `- [ ] T012 [P] [US1] Create User model in src/models/user.py`
- ✅ CORRECT: `- [ ] T003 [P] [L] CREATE `app/tsconfig.json` with EXACTLY this content (copy verbatim): ...` (fully-specified file → local-eligible)
- ✅ CORRECT: `- [ ] T009 [L] [US1] Run `pytest tests/test_ideas.py -k happy_path -v`. Expected: 2 passed.` (verify-by-exit-code command → local-eligible)
- ✅ CORRECT: `- [ ] T014 [US1] Implement UserService in src/services/user_service.py`
- ❌ WRONG: `- [ ] Create User model` (missing ID and Story label)
- ❌ WRONG: `T001 [US1] Create model` (missing checkbox)
- ❌ WRONG: `- [ ] [US1] Create User model` (missing Task ID)
- ❌ WRONG: `- [ ] T001 [US1] Create model` (missing file path)

### Embed literal content for machine-critical and exactly-specified files (REQUIRED)

A task list may be executed by a weak/local model that cannot infer omitted detail. Whenever a
CREATE/EDIT task targets a file whose exact contents matter and are already fully determined —
dependency manifests and lockfile-adjacent files (`package.json`, `pyproject.toml`,
`requirements.txt`, `go.mod`, `Cargo.toml`), CI/build/config (`Dockerfile`, `tsconfig.json`,
`*.config.js`, `.eslintrc*`), schema/migration DDL, and any file where a dropped or reordered
field silently breaks the build — DO NOT describe the contents in prose. Embed the FULL file
verbatim in a fenced code block inside the task, introduced by "with EXACTLY this content (copy
verbatim)". Prose like "add the pinned versions listed above" is a known failure mode: a weak
implementer writes `"dependencies": {}` and the whole downstream chain no-ops.

Pair every such task with a **machine-runnable self-check** the driver can run (a `node -e`/
`python -c`/`grep`/`test` one-liner that exits non-zero if the file is wrong — e.g. asserts the
expected dependency count), so a bad write fails the task instead of passing silently.

- ✅ CORRECT: `- [ ] T001 CREATE `app/package.json` with EXACTLY this content (copy verbatim):` followed by a ```json fenced block containing the complete file, then a VERIFY one-liner.
- ❌ WRONG: `- [ ] T001 Create package.json with the dependencies from the pinned-versions block above` (weak models emit empty objects).

For files whose content is genuinely open-ended (application source a capable model must author),
prose + exact symbols/signatures + file path remains correct; reserve full-verbatim embedding for
files that are exactly specified and unforgiving of drift.

### Executor Annotation ([L] marker)

Task lists can be executed by a mix of a frontier agent and the user's own local model (via
`blitz implement --local-only`). Whether a local model is available — and what it can handle —
is configured, not guessed:

1. Read `.blitz/config.json` in the repo root. If it has no `local_model` key, read
   `.blitz/config.json` in the nearest ancestor directory that has one (the workspace root).
2. If NO `local_model` block is found anywhere: do not emit any `[L]` markers. Stop here.
3. If found, the block looks like:

   ```json
   {
     "local_model": {
       "model": "qwen2.5-14b-28k",
       "capabilities": "free-text description of what the model handles reliably and what it does not"
     }
   }
   ```

   Use the `capabilities` text as the authority on what to mark. In addition to it, apply these
   baseline rules — mark a task `[L]` ONLY when ALL of its work is one of:

   - **Verbatim writes**: CREATE/EDIT where the full file content (or the exact appended block)
     is embedded in the task in a fenced code block ("with EXACTLY this content").
   - **Fully-determined edits**: an EDIT whose anchor line(s) and replacement text are both
     quoted exactly in the task.
   - **Command execution**: run a given shell command where success = exit code 0 (installs,
     mkdir, pytest/lint/build invocations, grep checks).

   NEVER mark `[L]` when the task requires: authoring open-ended application logic, reasoning
   across multiple files, choosing between approaches, debugging a failure, or interpreting
   prose requirements into code. When in doubt, leave the marker off — a frontier agent can
   always execute an `[L]` task, but a local model cannot recover from an over-optimistic marker.

4. Place `[L]` after `[P]` and before the `[Story]` label:
   `- [ ] T003 [P] [L] [US1] CREATE ...`
5. The marker is load-bearing and machine-parsed: `blitz implement --local-only` executes
   consecutive `[L]` tasks and stops at the first task without the marker, handing control back
   to the orchestrating agent. Keep runs of local-eligible tasks contiguous where dependencies
   allow — interleaving one frontier task between local ones forces a round-trip per task.

Note that the "Embed literal content" rule above directly increases how many tasks qualify for
`[L]`: the more exactly a task is specified, the more of the list the local model can execute.

### Task Organization

1. **From User Stories (spec.md)** - PRIMARY ORGANIZATION:
   - Each user story (P1, P2, P3...) gets its own phase
   - Map all related components to their story:
     - Models needed for that story
     - Services needed for that story
     - Interfaces/UI needed for that story
     - If tests requested: Tests specific to that story
   - Mark story dependencies (most stories should be independent)

2. **From Contracts**:
   - Map each interface contract → to the user story it serves
   - If tests requested: Each interface contract → contract test task [P] before implementation in that story's phase

3. **From Data Model**:
   - Map each entity to the user story(ies) that need it
   - If entity serves multiple stories: Put in earliest story or Setup phase
   - Relationships → service layer tasks in appropriate story phase

4. **From Setup/Infrastructure**:
   - Shared infrastructure → Setup phase (Phase 1)
   - Foundational/blocking tasks → Foundational phase (Phase 2)
   - Story-specific setup → within that story's phase

### Phase Structure

- **Phase 1**: Setup (project initialization)
- **Phase 2**: Foundational (blocking prerequisites - MUST complete before user stories)
- **Phase 3+**: User Stories in priority order (P1, P2, P3...)
  - Within each story: Tests (if requested) → Models → Services → Endpoints → Integration
  - Each phase should be a complete, independently testable increment
- **Final Phase**: Polish & Cross-Cutting Concerns

## Done When

- [ ] tasks.md generated with all phases, task IDs, and file paths
- [ ] Extension hooks dispatched or skipped according to the rules in Mandatory Post-Execution Hooks above
- [ ] Completion reported to user with task count, story breakdown, and MVP scope
