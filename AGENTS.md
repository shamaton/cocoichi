# AGENTS.md

## Purpose

This repository is currently used to design and prepare a PoC for a new CoCo壱番屋 mobile app.

The main goal is not backend delivery. The main goal is to improve the native mobile UX/UI around ordering.

Use this file as the entry point for understanding which document to read first for a given task.

## Current Scope

- New mobile app PoC
- iOS-first
- Native-first interaction
- No backend service required for the PoC
- No WebView-centered implementation
- Focus on the ordering experience, saved combinations, coupon suggestion, and clear completion feedback

## Source Of Truth Order

When multiple docs overlap, use this order of precedence:

1. `docs/poc-app-direction-2026-03-28.md`
2. `docs/poc-screen-flow-2026-03-28.md`
3. `docs/poc-home-tab-architecture-2026-04-12.md`
4. `docs/poc-wireframes-home-tabs-2026-04-12.md`
5. `docs/poc-wireframes-s2-s3-2026-03-28.md`
6. `docs/poc-wireframes-s5-s6-2026-03-28.md`
7. `docs/poc-wireframes-s8-2026-03-28.md`
8. `docs/poc-visual-toneboard-2026-03-28.md`
9. `docs/poc-design-tokens-2026-03-28.md`
10. `docs/app-renewal-planning-611124786-jp-2026-03-28.md`
11. `docs/appstore-review-analysis-611124786-jp-2026-03-23.md`

If you find a conflict, prefer the higher item and then update the lower one later if needed.

## Derived Design Aid

- `DESIGN.md`

`DESIGN.md` is a derived AI-facing design system summary that complements the canonical PoC design docs above and must not override them.

## Fast Doc Index

### If you are defining product intent

Read:

- `docs/poc-app-direction-2026-03-28.md`

This is the main PoC brief.

Key points:

- backend-less PoC
- native-first UX
- guest-first main flow
- saved combos
- coupon suggestion at the end
- clear order completion

### If you are working on navigation or app structure

Read:

- `docs/poc-app-direction-2026-03-28.md`
- `docs/poc-screen-flow-2026-03-28.md`
- `docs/poc-home-tab-architecture-2026-04-12.md`

This defines:

- the app-level home/tab shell
- the primary flow
- push vs sheet responsibilities
- screen IDs
- P0/P1 screen priorities

Primary flow:

`Store Select -> Menu Discovery -> Curry Detail / Customize -> Order Review -> Coupon Suggestion -> Order Complete`

### If you are working on screen UX

Read the relevant wireframe doc first:

- `docs/poc-wireframes-home-tabs-2026-04-12.md`
- `docs/poc-wireframes-s2-s3-2026-03-28.md`
- `docs/poc-wireframes-s5-s6-2026-03-28.md`
- `docs/poc-wireframes-s8-2026-03-28.md`

Use these docs for:

- information hierarchy
- CTA priority
- state differences
- animation requirements
- accessibility notes

### If you are working on visual design

Read first:

- `docs/poc-visual-toneboard-2026-03-28.md`
- `docs/poc-design-tokens-2026-03-28.md`

Use the canonical docs above for:

- visual direction
- color system
- typography roles
- material usage
- motion principles
- semantic tokens by screen role

Then consult:

- `DESIGN.md`

Use `DESIGN.md` only for:

- AI-facing screen generation guidance
- summarized visual prompts derived from the canonical docs

### If you are planning implementation work

Read:

- `docs/poc-app-direction-2026-03-28.md`
- `docs/poc-screen-flow-2026-03-28.md`
- `docs/poc-home-tab-architecture-2026-04-12.md`
- `docs/poc-implementation-tasks-2026-03-29.md`

Use these docs for:

- implementation scope and non-goals
- task ordering and dependencies
- milestone acceptance criteria

### If you are running the review gate

Read:

- `docs/subagent-review-workflow-2026-03-31.md`

Use this doc for:

- the default review-gate flow for this repo
- reviewer subagent prompt templates
- large-diff splitting rules
- required JSON output contract

### If you are trying to understand why this PoC exists

Read:

- `docs/appstore-review-analysis-611124786-jp-2026-03-23.md`
- `docs/app-renewal-planning-611124786-jp-2026-03-28.md`

These explain:

- the failures in the current app
- what needed to be fixed
- why the PoC focuses on native ordering UX instead of backend integration

## Working Rules

### Product Rules

- Do not reintroduce Web-like flows unless there is a strong reason.
- Do not require login to complete the PoC’s main order flow.
- Do not let coupon UX overpower the order flow.
- Do not optimize for backend realism over experience quality.
- Do optimize for a clear, enjoyable, native ordering journey.

### Design Rules

- Keep the app warm, layered, and native.
- Avoid purple-heavy, futuristic, or overly transparent UI.
- Use glass/material sparingly and only where it helps hierarchy.
- Keep the primary CTA visually consistent across screens.
- Keep price emphasis visually consistent across screens.

### UX Rules

- The user should always know:
  - what store they are ordering from
  - what they are building
  - how much it costs
  - what happens next
- The order flow must not be blocked by account setup.
- Completion must feel explicit, not implied.

### Implementation Rules

- When adding code comments, write them in Japanese.
- Add comments only where the intent, constraint, or reason is not obvious from the code itself.
- Prefer comments that explain `why this structure exists` or `what PoC assumption it depends on`, not comments that restate the code.

## Suggested Read Order By Task

### Task: implement or refine `S2 Menu Discovery`

Read in order:

1. `docs/poc-screen-flow-2026-03-28.md`
2. `docs/poc-home-tab-architecture-2026-04-12.md`
3. `docs/poc-wireframes-home-tabs-2026-04-12.md`
4. `docs/poc-wireframes-s2-s3-2026-03-28.md`
5. `docs/poc-visual-toneboard-2026-03-28.md`
6. `docs/poc-design-tokens-2026-03-28.md`

### Task: implement or refine `Home` / app tab shell

Read in order:

1. `docs/poc-app-direction-2026-03-28.md`
2. `docs/poc-screen-flow-2026-03-28.md`
3. `docs/poc-home-tab-architecture-2026-04-12.md`
4. `docs/poc-wireframes-home-tabs-2026-04-12.md`
5. `docs/poc-visual-toneboard-2026-03-28.md`
6. `docs/poc-design-tokens-2026-03-28.md`

### Task: implement or refine `S3 Curry Detail / Customize`

Read in order:

1. `docs/poc-screen-flow-2026-03-28.md`
2. `docs/poc-wireframes-s2-s3-2026-03-28.md`
3. `docs/poc-visual-toneboard-2026-03-28.md`
4. `docs/poc-design-tokens-2026-03-28.md`

### Task: implement or refine `S5 Order Review` / `S6 Coupon Suggestion`

Read in order:

1. `docs/poc-screen-flow-2026-03-28.md`
2. `docs/poc-wireframes-s5-s6-2026-03-28.md`
3. `docs/poc-visual-toneboard-2026-03-28.md`
4. `docs/poc-design-tokens-2026-03-28.md`

### Task: implement or refine `S8 Order Complete`

Read in order:

1. `docs/poc-screen-flow-2026-03-28.md`
2. `docs/poc-wireframes-s8-2026-03-28.md`
3. `docs/poc-visual-toneboard-2026-03-28.md`
4. `docs/poc-design-tokens-2026-03-28.md`

### Task: revisit PoC scope or feature priority

Read in order:

1. `docs/poc-app-direction-2026-03-28.md`
2. `docs/app-renewal-planning-611124786-jp-2026-03-28.md`
3. `docs/appstore-review-analysis-611124786-jp-2026-03-23.md`

### Task: break PoC into implementation tasks or pick the next task

Read in order:

1. `docs/poc-app-direction-2026-03-28.md`
2. `docs/poc-screen-flow-2026-03-28.md`
3. `docs/poc-home-tab-architecture-2026-04-12.md`
4. `docs/poc-implementation-tasks-2026-03-29.md`

## Repository Notes

- There is a Go CLI in `cmd/appstore-reviews`, but the current PoC planning work is document-driven.
- The `docs/` directory is the main working area for product and design decisions.
- `DESIGN.md` is the root-level AI-facing design summary derived from the active PoC design docs.
- `docs/poc-implementation-tasks-2026-03-29.md` is the execution breakdown for the active PoC docs.
- `docs/poc-home-tab-architecture-2026-04-12.md` defines how app launch, home, tabs, and store-context gating relate to the order flow.
- `docs/poc-wireframes-home-tabs-2026-04-12.md` defines the app-level home, menu, order empty state, and tab bar wireframes.
- Treat the PoC documents as the active workstream.

## Tooling Notes

- In this repo, nested sandboxing can break `codex exec --sandbox read-only` with `sandbox-exec: sandbox_apply: Operation not permitted`.
- Do not use `codex exec`-based review as the default review gate in this repo.
- Prefer the subagent-based review flow documented in `docs/subagent-review-workflow-2026-03-31.md`.
- Do not use `/review` as a gate by itself. Use a reviewer subagent with an explicit JSON output contract instead.
- `scripts/run-codex-review.sh` is legacy-only. Keep it only for reference or exceptional manual use, not as the standard path.
- Before a review that uses `diff_range: HEAD`, check `git status --short` for untracked files. If a new file must be reviewed before commit, stage it first or use `git add -N` so it is visible to the diff-based review flow.
- Prefer the repo `Makefile` for local iOS verification instead of ad-hoc `xcodebuild` commands.
- Standard entry points are `make diagnose`, `make build`, `make run`, `make test`, and `make agent-verify`.
- Build artifacts and logs are written under `build/`, separated by `AGENT_NAME`.
- If you need per-agent isolation, set `AGENT_NAME=<name>` before running `make`.

## When Adding New Docs

If you add a new canonical design or product doc:

1. Link it from this file.
2. Place it in the relevant priority order.
3. Mention which existing doc it supersedes or complements.
4. Keep names date-stamped like the current docs for traceability.

## Minimal Startup Checklist For Agents

Before starting substantial work:

1. Read `AGENTS.md`
2. Read the doc group relevant to your task
3. Confirm whether your task is product, flow, wireframe, visual-token, or implementation-planning work
4. Avoid making assumptions that contradict the current PoC docs
