# Runeon DXMT

[English](README.md) | [Chinese](README.zh-CN.md) | [Japanese](README.ja.md)

> This English document is authoritative. The Chinese and Japanese documents are complete translations for convenience.

Runeon DXMT is the public source-maintenance repository for the DXMT component that Runeon ships. It holds a pinned [DXMT](https://github.com/3Shain/dxmt) tag or commit, upstream fixes backported onto it, Runeon's own changes, and the scripts that rebuild the exact corresponding source of every shipped component. It makes no general compatibility promise, and it does not contain the Runeon App, Steam, games or Apple private graphics components.

## Baseline and current release

- Upstream base: DXMT `main` at `3b25259` (no upstream release since `v0.80`), pinned in [`base/dxmt-main-3b252590.json`](base/dxmt-main-3b252590.json); `0.80-runeon.5` uses `v0.80` (`589adb7`), pinned in [`base/dxmt-0.80.json`](base/dxmt-0.80.json)
- Current stable source: [`0.80-runeon.6`](https://github.com/Codewave-Seki/runeon-dxmt/releases/tag/0.80-runeon.6): upstream `main` `3b25259` and 1 Runeon change, delivered to App `>=1.13 (10)`. Definition in [`patchsets/0.80-runeon.6`](patchsets/0.80-runeon.6/manifest.json)
- Upstream reviewed through: `3b25259`; see [MAINTENANCE.md](MAINTENANCE.md#review-records)

## Repository layout

| Path | Contents |
|---|---|
| `base/` | Pinned upstream repository, tag, commit and submodule commits |
| `patchsets/<id>/` | `series` and `manifest.json` for one patch set; scripts use the newest unless `RUNEON_DXMT_PATCHSET_DEFINITION=patchsets/<id>` selects another |
| `patches/upstream/`, `patches/runeon/` | Upstream DXMT backports and Runeon changes, one commit per file |
| `scripts/` | Fetch, apply, check and bundle scripts |
| `docs/` | Upstream review records (English) |

## Scope and boundaries

- No DXMT source trees, build output, component archives, prefixes, user data or diagnostics are committed.
- `D3DMetal.framework`, `libd3dshared.dylib` and GPTK private overlays are never downloaded, mirrored or distributed.
- A clean apply does not put an upstream commit into a patch set; every commit is reviewed first.
- Runeon changes never match game names, Steam AppIDs or executable names.
- Every component shipped to Production gets an immutable stable Release with the exact patch-set bundle, complete corresponding source and SHA-256 files. Candidates stay Pre-releases. Tags and Release assets are never moved, replaced or deleted.
- Packaging, signing and distribution of the component are done by the Runeon product repository.

## Verify and build

```bash
scripts/static-check.sh
source_root="$(scripts/fetch-source.sh)"
scripts/integration-check.sh "$source_root"
```

`integration-check.sh` applies every patch with `git am` to a temporary worktree of the pinned base and checks that the result is the tree recorded in the manifest. Building the component and the Release bundles is described in [BUILDING.md](BUILDING.md).

## Release history

Each Release carries the patch-set bundle, the complete corresponding source and both SHA-256 files; its notes describe what the patch set adds.

| Patch set | State | Status |
|---|---|---|
| [`0.80-runeon.6`](https://github.com/Codewave-Seki/runeon-dxmt/releases/tag/0.80-runeon.6) | stable, latest | Current; delivered to App `>=1.13 (10)` |
| [`0.80-runeon.5`](https://github.com/Codewave-Seki/runeon-dxmt/releases/tag/0.80-runeon.5) | stable | Superseded, retained; built and shipped before this repository existed |

## Documentation

- [BUILDING.md](BUILDING.md): building the component and the Release bundles
- [MAINTENANCE.md](MAINTENANCE.md): upstream review, patch gates and release policy
- [SECURITY.md](SECURITY.md): reporting security issues
- [docs/upstream-reviews.md](docs/upstream-reviews.md): review records

## License

DXMT changed its license from MIT to LGPL-2.1-or-later in upstream commit `ec357fd`, after `v0.80`. Bases after that commit, the backported fixes and Runeon's changes are licensed under LGPL-2.1-or-later; see [`LICENSE`](LICENSE). Code as of DXMT `v0.80` remains available under its MIT license. Upstream commits keep their original authorship. This repository does not change the license of the Runeon App.
