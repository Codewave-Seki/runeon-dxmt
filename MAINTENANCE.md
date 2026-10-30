# Maintenance Policy

Runeon DXMT carries upstream DXMT fixes and a few downstream changes on top of a pinned DXMT tag. Upstream audits and diagnostics-driven investigations pass the same gates.

## Upstream audits

1. List the upstream commits that no review covers yet: `git log --reverse <boundary>..origin/main` in a DXMT clone, where the boundary is the upstream commit the latest review records. The first review recorded none, so the next audit starts at the base tag and skips commits already listed there.
2. Review each commit against the scope in `CLAUDE.md` §4: does the defect exist in the base, what does the fix depend on, and does the shipped component build that code.
3. Record the decisions, including exclusions, as a new section of [docs/upstream-reviews.md](docs/upstream-reviews.md), naming the upstream commit it reviewed through.
4. Cherry-pick the selected commits with `git cherry-pick -x` onto the base plus the current series, then export them with `git format-patch` into a new patch set.

Moving to a newer base is an alternative to backporting. The base is a newer upstream tag or, while upstream publishes no release, a commit on upstream `main` (`CLAUDE.md` §3). It needs a new base file and a full review of what changes, including D3D12 code the component does not use but still links.

## Review records

Release status lives in the [README](README.md) table and the GitHub Releases; this file does not repeat it.

| Record | Scope | First patch set |
|---|---|---|
| [BACKPORTS-0.80-20261020](docs/upstream-reviews.md#backports-0.80-20261020) | Fixes after `v0.80` on upstream `main`, and the downstream changes before them | `0.80-runeon.5` |

## Gates for entering a patch set

- Record the full upstream commit SHA and keep the original author.
- Apply with `git am` and no conflict; describe any adaptation in the commit message.
- Build both `x86_64` and `i386` DLLs.
- Run a probe for each fix an application can observe through the API, before and after.
- Compare a game routed to DXMT against the previous patch set; only new failures are regressions.
- Update the Runeon component's notices to name the patch set and its licence.

## Downstream changes

A downstream change fixes behaviour an application observes on Windows, or is opt-in (`CLAUDE.md` §4). It is written so it could be submitted upstream. Once upstream carries an equivalent fix, a later patch set replaces it with the backport.

## Release policy

Patch-set IDs such as `0.80-runeon.5` are immutable once tagged, and equal the component version built from them. Publish a candidate as a GitHub Pre-release with the patch-set bundle, the complete corresponding source and both `.sha256` files. Mark the same Release stable only after its component reaches Production. Tags and Release assets are retained permanently and never moved, replaced or deleted.

The repository and its bundles contain only DXMT-derived source, patches and scripts. The Runeon App, user diagnostics, Steam or game files, signing identities, service secrets and Apple private components never enter Git history, Actions artifacts or Release assets.
