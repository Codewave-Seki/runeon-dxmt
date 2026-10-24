# Runeon DXMT

[English](README.md) | [Chinese](README.zh-CN.md) | [Japanese](README.ja.md)

> This English document is authoritative. The Chinese and Japanese documents are complete translations for convenience.

Runeon DXMT is the public source-maintenance repository for the DXMT component that Runeon ships. It holds a pinned [DXMT](https://github.com/3Shain/dxmt) tag, upstream fixes backported onto it, Runeon's own changes, and the scripts that rebuild the exact corresponding source of every shipped component. It makes no general compatibility promise, and it does not contain the Runeon App, Steam, games or Apple private graphics components.

## Baseline and current release

- Upstream: DXMT `v0.80` (`589adb7`), with its pinned submodules, in [`base/dxmt-0.80.json`](base/dxmt-0.80.json)
- Current stable source: [`0.80-runeon.5`](https://github.com/Codewave-Seki/runeon-dxmt/releases/tag/0.80-runeon.5): 23 upstream fixes and 3 Runeon changes. Definition in [`patchsets/0.80-runeon.5`](patchsets/0.80-runeon.5/manifest.json)
- Upstream review records: [MAINTENANCE.md](MAINTENANCE.md#review-records)

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

`integration-check.sh` applies every patch with `git am` to a temporary worktree of the pinned tag and checks that the result is the tree recorded in the manifest. Building the DLLs and the Release bundles is described in [BUILDING.md](BUILDING.md).

## Release history

Each Release carries the patch-set bundle, the complete corresponding source and both SHA-256 files.

| Patch set | State | Status |
|---|---|---|
| [`0.80-runeon.5`](https://github.com/Codewave-Seki/runeon-dxmt/releases/tag/0.80-runeon.5) | stable, latest | Current; built and shipped before this repository existed |

## Documentation

- [BUILDING.md](BUILDING.md): building the DLLs and the source bundles
- [MAINTENANCE.md](MAINTENANCE.md): upstream review, patch gates and release policy
- [SECURITY.md](SECURITY.md): reporting security issues
- [docs/upstream-reviews.md](docs/upstream-reviews.md): review records

## License

DXMT changed its license from MIT to LGPL-2.1-or-later in upstream commit `ec357fd`, after `v0.80`. The backported fixes and Runeon's changes in this repository are licensed under LGPL-2.1-or-later; see [`LICENSE`](LICENSE). Code as of DXMT `v0.80` remains available under its MIT license. Upstream commits keep their original authorship. This repository does not change the license of the Runeon App.
