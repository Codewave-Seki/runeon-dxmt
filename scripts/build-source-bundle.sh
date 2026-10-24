#!/usr/bin/env bash
# Builds the complete corresponding source of a patch set: the patched DXMT
# tree, including its pinned submodules, from a checkout prepared with
# apply-series.sh.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$script_dir/common.sh"

[[ $# -eq 2 && -n "$1" ]] || die "usage: $0 PATCHED_DXMT_SOURCE_ROOT OUTPUT_DIR"
source_root="$(cd "$1" && pwd)"
mkdir -p "$2"
out_dir="$(cd "$2" && pwd)"

load_manifests
require_command git
require_release_tag_checkout_if_published
[[ "$(git -C "$source_root" rev-parse 'HEAD^{tree}')" == "$result_tree" ]] \
  || die "$source_root is not patched with $patch_set_id"
[[ -z "$(git -C "$source_root" status --porcelain --ignore-submodules=none)" ]] \
  || die "$source_root has local changes"

name="runeon-dxmt-$patch_set_id-source"
staging="$(mktemp -d "${TMPDIR:-/tmp}/runeon-dxmt-source.XXXXXX")"
trap 'rm -rf "$staging"' EXIT
mkdir "$staging/$name"

git -C "$source_root" archive HEAD | tar -xf - -C "$staging/$name"
while IFS= read -r submodule; do
  mkdir -p "$staging/$name/$submodule"
  git -C "$source_root/$submodule" archive HEAD | tar -xf - -C "$staging/$name/$submodule"
done < <(jq -r '.submodules | keys[]' "$base_manifest")

jq -n --arg patchSetId "$patch_set_id" --arg repository "$base_repository" \
  --arg tag "$base_tag" --arg commit "$base_commit" --arg tree "$result_tree" \
  --slurpfile base "$base_manifest" \
  '{schemaVersion: 1, patchSetId: $patchSetId, base: {repository: $repository, tag: $tag, commit: $commit, submodules: $base[0].submodules}, resultTree: $tree}' \
  >"$staging/$name/RUNEON-SOURCE.json"

archive="$out_dir/$name.tar.gz"
create_reproducible_tar_gz "$staging/$name" "$archive"
(cd "$out_dir" && printf '%s  %s\n' "$(sha256_file "$archive")" "$name.tar.gz" >"$name.tar.gz.sha256")
printf '%s\n' "$archive"
