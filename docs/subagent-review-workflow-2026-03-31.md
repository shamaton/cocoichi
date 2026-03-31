# Subagent Review Workflow

This repository uses a subagent-based review gate by default.

Do not use `codex exec --sandbox read-only` as the primary review path in this repo. Nested sandboxing is known to fail here.

Do not rely on `/review` alone for the gate. `/review` is useful for ad hoc feedback, but it does not guarantee the structured output contract required for a review gate.

## Goal

Keep the existing review-gate discipline from `codex-review`, but run it through reviewer subagents instead of `codex exec`.

Main agent:

- prepares diff scope
- spawns reviewer subagent(s)
- waits for final JSON output
- fixes blocking issues
- reruns review until `ok: true` or stop conditions are hit

Reviewer subagent:

- inspects only the assigned scope
- returns JSON only
- does not make code changes

## Default Flow

1. Check scope size with:
   - `git diff <diff_range> --stat`
   - `git diff <diff_range> --name-status --find-renames`
2. Choose review strategy:
   - small: diff only
   - medium: arch -> diff
   - large: arch -> parallel diff -> cross-check
3. If `diff_range` is `HEAD`, run `git status --short` first.
4. If untracked files must be reviewed, stage them or use `git add -N`.
5. Spawn reviewer subagent(s) with explicit ownership of file groups.
6. Require JSON-only output using the schema below.
7. If any reviewer returns `ok: false`, fix only the blocking issues and rerun review.

## Size Rules

| Size | Threshold | Strategy |
| --- | --- | --- |
| small | <=3 files and <=100 lines | diff |
| medium | 4-10 files or 100-500 lines | arch -> diff |
| large | >10 files or >500 lines | arch -> parallel diff -> cross-check |

For large changes:

- split by directory or cohesive module
- keep each diff review to at most 5 files or about 300 lines
- use 3-5 reviewer subagents at most
- reserve cross-check for interface mismatch, error-handling drift, compatibility risk, and missing test coverage across groups

## Reviewer Contract

Reviewer subagents must return exactly one JSON object:

```json
{
  "ok": true,
  "phase": "arch|diff|cross-check",
  "summary": "レビューの要約",
  "issues": [
    {
      "severity": "blocking",
      "category": "security",
      "file": "src/auth.py",
      "lines": "42-45",
      "problem": "問題の説明",
      "recommendation": "修正案"
    }
  ],
  "notes_for_next_review": "メモ"
}
```

Rules:

- `ok` is `false` if any blocking issue exists
- `severity` is `blocking` or `advisory`
- `category` is one of `correctness`, `security`, `perf`, `maintainability`, `testing`, `style`
- `notes_for_next_review` is passed into the next loop unchanged unless it becomes obsolete

## Prompt Templates

Use these prompts as the initial message to the reviewer subagent. Add the relevant file list after the template when needed.

### Arch

```text
以下の変更のアーキテクチャ整合性をレビューせよ。出力はJSON1つのみ。スキーマは末尾参照。

これはレビューゲートとして実行されている。blocking が1件でもあれば ok: false とし、修正→再レビューで収束させる前提で指摘せよ。

diff_range: {diff_range}
観点: 依存関係、責務分割、破壊的変更、セキュリティ設計
前回メモ: {notes_for_next_review}
主要対象ファイル:
- {file_1}
- {file_2}
```

### Diff

```text
以下の変更をレビューせよ。出力はJSON1つのみ。スキーマは末尾参照。

これはレビューゲートとして実行されている。blocking が1件でもあれば ok: false とし、修正→再レビューで収束させる前提で指摘せよ。

diff_range: {diff_range}
対象: {target_files}
観点: {review_focus}
前回メモ: {notes_for_next_review}
```

### Cross-check

```text
並列レビュー結果を統合し横断レビューせよ。出力はJSON1つのみ。スキーマは末尾参照。

これはレビューゲートとして実行されている。横断的な blocking（例: interface不整合、認可漏れ、API互換破壊）があれば ok: false とせよ。

全体stat: {stat_output}
各グループ結果: {group_jsons}
観点: interface整合、error handling一貫性、認可、API互換、テスト網羅
```

## Subagent Guidance

When spawning reviewer subagents:

- prefer a non-writing reviewer role
- give each reviewer a bounded scope and file ownership
- tell the reviewer to inspect the repository state as-is and not propose speculative rewrites
- do not ask the reviewer to run `/review`
- do ask the reviewer to read the assigned files and return JSON only

Recommended wording:

```text
You are the reviewer for this change group. Do not edit files. Inspect the assigned scope and return exactly one JSON object that matches the provided schema. If you find any blocking issue, set ok to false. Do not include markdown fences or explanatory text.
```

## Retry Rules

If a reviewer subagent fails, times out, or returns malformed output:

1. Retry once with a narrower scope.
2. If it fails again, mark that scope as `unreviewed`.
3. Continue the remaining phases if possible.
4. Report unreviewed scopes explicitly in the final review summary.

## Stop Conditions

Stop the loop when one of these is true:

- `ok: true`
- max review iterations reached
- tests fail twice in a row and further review would not change the result

## Final Report Format

The main agent should leave a short report in the task summary:

```text
## Subagent review result
- size: medium
- reviewers: 2
- iterations: 2/5
- status: ok

### Fixed
- OrderFlowView.swift: navigation state mismatch corrected

### Advisory
- MenuDiscoveryView.swift: long function could be split later

### Unreviewed
- none
```
