# runeon-dxmt — CLAUDE.md

Conventions for working in this public repository, complete on their own: they apply whether or not the work started from another repository. `AGENTS.md` is a symlink to this file; do not create a separate copy. User-facing documentation lives in [README.md](README.md), [BUILDING.md](BUILDING.md) and [MAINTENANCE.md](MAINTENANCE.md); review records are sections of `docs/upstream-reviews.md`.

## 0. Before you start

- Read the parts of `MAINTENANCE.md` that apply: what may enter a patch set, and the release policy.
- Find the newest patch set under `patchsets/` and check whether it is tagged (`git tag -l`). Tagged patch sets are frozen; new work goes into a new, untagged patch-set ID.
- For a backport, read the latest section of `docs/upstream-reviews.md` and follow the same rules.
- Enable the commit message hook once per clone: `git config core.hooksPath .githooks`.
- If a request conflicts with these rules, stop and ask the maintainer before doing anything.

## 1. Public repository boundary

This repository holds pinned DXMT source baselines plus ordered patch series, manifests and scripts. It never holds a DXMT source tree, build output, component archives, Wine prefixes or proprietary components.

Write every commit, patch, manifest entry, Release note and document in English, for an outside reader:

- Do not mention closed-source product internals: private repository paths, source files, internal task numbers or documents, release channels, accounts, services or credentials.
- Do not include diagnostics, logs, user data or machine-specific paths such as home directories.
- Never download, mirror or commit `D3DMetal.framework`, `libd3dshared.dylib`, GPTK overlays or other Apple private components.

## 2. Layout

| Path | Role |
|---|---|
| `base/<baseId>.json` | Pinned upstream repository, tag (or none), commit and submodule commits; each patch set names its base |
| `patchsets/<patch-set-id>/{series,manifest.json}` | One definition per patch set. New work goes into the newest untagged one |
| `patches/upstream/NNNN-<slug>.patch` | Commits cherry-picked from upstream DXMT |
| `patches/runeon/01NN-<slug>.patch` | Downstream changes |
| `docs/upstream-reviews.md` | Upstream review records, English only |
| `scripts/` | Bash tools; all load `scripts/common.sh` |
| `.githooks/commit-msg` | Rejects commit messages that are not English |

Scripts use the newest patch set unless `RUNEON_DXMT_PATCHSET_DEFINITION=patchsets/<id>` selects another. CI runs the static check for every patch set and the integration check for the newest.

## 3. Patch-set IDs and bases

- A patch-set ID is `<DXMT version>-runeon.<N>`, for example `0.80-runeon.5`, and equals the version of the component built from it. `N` only increases; it continues the numbering already used for components built before this repository existed.
- Moving to a new upstream tag adds a new `base/dxmt-<version>.json` and starts a new patch set. Existing base files stay, because earlier patch sets reference them.
- When upstream has published no release for a long time, a base may pin a commit on upstream `main` instead: `base/dxmt-main-<short commit>.json` with `"tag": null`. The patch-set ID keeps the version of the last upstream release (for example `0.80-runeon.6` on a commit after `v0.80`), and `N` still only increases. Such a move needs the full review that `MAINTENANCE.md` describes for a new base.
- A patch set's `resultTree` is the Git tree of the base after its whole series is applied. It is the patch set's identity check: recompute it after every series change.

## 4. What may enter a patch set

- Upstream DXMT fixes are the trusted source. Take them with `git cherry-pick -x` so each keeps its author and a `(cherry picked from commit …)` line. A fix from another fork is adopted only after its defect is reproduced on this base.
- Backport fixes in code the component builds. From `0.80-runeon.6` that is every file, including `winemetal` (with the `airconv` shader converter) and `nvngx`; up to `0.80-runeon.5` only `d3d10core`, `d3d11`, `dxgi` and `nvapi64` were rebuilt (`BUILDING.md`). D3D12 features, refactors, test-only commits and build-system changes stay out unless a fix depends on them, and that dependency is stated in the review.
- For every candidate, confirm the defect exists in the pinned base (same code, or a reachable path). A clean apply alone proves nothing.
- Record every review decision, including exclusions and why, in a new section of `docs/upstream-reviews.md`.
- Downstream changes fix API behaviour that applications observe on Windows. They never match game names, Steam AppIDs or executable names. A change that alters behaviour for reasons other than a fix must be opt-in through a value the caller sets explicitly, such as an environment variable, and without it behaviour is identical to the base.
- Port only code whose licence permits it, and keep original authorship and copyright headers.

## 5. Licence

- DXMT changed from MIT to LGPL-2.1-or-later in upstream commit `ec357fd`, after `v0.80`. Code at `v0.80` stays available under MIT; fixes written after that change, and every downstream change here, are LGPL-2.1-or-later.
- A patch set that contains any LGPL code is distributed with its complete corresponding source (§9).

## 6. C++ and Metal code in patches

- Follow DXMT's style and its `.clang-format`: naming, brace placement and the existing COM and Metal helper patterns. Do not reformat surrounding code.
- Use DXMT's facilities rather than new ones: its logging (`WARN`, `ERR`, `UNIMPLEMENTED` only where upstream would abort too), `Com<>` smart pointers and existing headers. Add no external dependencies. Every symbol you use must exist in the pinned base.
- Comments are in English and explain why, not what.
- Preserve API contracts: HRESULT values, reference counting, and output-pointer initialisation on failure paths. Prefer a failing HRESULT the caller can handle to an abort.
- Keep each patch small and focused on one behaviour. Changes must build for both `x86_64` and `i386` as described in `BUILDING.md`.

## 7. Patch files and manifests

- Each patch is one commit in `git format-patch` form. It must apply with `git am` and no conflict on top of the base plus every earlier entry in its series.
- Keep `series` order and manifest `order` identical. Every entry records `order`, `path`, `sha256`, `kind` (`upstream-backport` or `runeon`), `author` and `summary`. Upstream backports also record full 40-character `upstreamCommits`; an adapted backport says how it differs in its commit message.
- After editing a patch, update its `sha256` and the patch set's `resultTree`. Never edit a patch or manifest that belongs to a tagged patch set.

## 8. Validation and evidence

Before every commit:

```bash
scripts/static-check.sh
scripts/integration-check.sh "$(scripts/fetch-source.sh)"
for d in patchsets/*/; do RUNEON_DXMT_PATCHSET_DEFINITION="${d%/}" scripts/static-check.sh; done   # as CI runs it
```

These checks prove that the series applies and produces the recorded tree, nothing more:

- A patch set must pass a complete `x86_64` and `i386` build (`BUILDING.md`) before it is tagged.
- Check runtime behaviour against the previous patch set, not in isolation, and treat only new failures as regressions. A probe that fails before and passes after confirms a fix.
- Say what was not verified. A fix checked only by code review, or a probe that did not reproduce the original defect, is reported as such.
- Without local evidence a cause is a hypothesis. Online reports and other projects' discussions are leads, not evidence about this base.

## 9. Releases

- A patch-set ID is immutable once tagged. The tag is an annotated tag named after the patch-set ID and points to the exact commit the component was built from.
- A Release carries the patch-set bundle, the complete corresponding source and both `.sha256` files. Build bundles of a published patch set from its tag checkout; the bundle scripts refuse otherwise.
- A Release stays a Pre-release until its component is in Production. Marking it stable or latest is a maintainer decision and changes only its state and notes; the tag, commit, asset names, sizes and digests never change.
- After publishing, confirm that an anonymous download reproduces the SHA-256 files.
- Record the Release in the README current line and release table, in one commit.

## 10. Documentation

- The root holds only `README.md` and its two translations, `BUILDING.md`, `MAINTENANCE.md`, `SECURITY.md`, this file and its `AGENTS.md` symlink. Do not add another document, at the root or under `docs/`; `static-check.sh` rejects it.
- Only the README is translated. `README.md` is authoritative; `README.zh-CN.md` and `README.ja.md` are complete translations, updated in the same commit. Everything else is English only.
- A new upstream review is a new section at the end of `docs/upstream-reviews.md`, with an `<a id>` anchor, and one row of the "Review records" table in `MAINTENANCE.md`. A downstream patch's rationale goes into its commit message, not into a new document.
- Keep lines readable: one fact per bullet or table row. State validation limits plainly.

## 11. Git

- **Commit messages are in English**, enforced by `.githooks/commit-msg` and by `static-check.sh` over the whole history. Use an imperative subject of 72 characters or fewer and a body wrapped at about 72 columns that explains what and why. Keep trailers such as `Co-Authored-By` at the end.
- One topic per commit. Run `git status --short` and `git diff --check` before committing, and stage specific paths.
- Published history is never rewritten. An unpushed commit may be amended. Never force-push `main`, and never move, recreate or delete a tag, Release or Release asset. Fix mistakes with a new commit or a new patch-set ID.
- Pushing, tagging and publishing or promoting Releases are explicit maintainer decisions, taken one at a time.
- After a push, check that CI ran and passed, and that the workflow's `paths` filter covers what you changed.

## 12. Working practice

- Change only what the task needs; do not refactor or tidy unrelated files.
- Keep `.work/`, `dist/` and build trees out of Git, and remove them when the work is done.
- Report results as they are: failed checks with their output, skipped steps as skipped, and completed work without hedging.
