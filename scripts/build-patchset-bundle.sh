#!/usr/bin/env bash
# Builds the patch-set bundle: base pin, series, manifest and patches, which
# `git am` applies in series order on top of the pinned DXMT tag or commit.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$script_dir/common.sh"

[[ $# -eq 1 ]] || die "usage: $0 OUTPUT_DIR"
mkdir -p "$1"
out_dir="$(cd "$1" && pwd)"

load_manifests
require_release_tag_checkout_if_published
[[ -z "$(git -C "$repo_root" status --porcelain -- base patchsets patches LICENSE README.md BUILDING.md)" ]] \
  || die "bundle inputs have uncommitted changes"

name="runeon-dxmt-$patch_set_id-patchset"
staging="$(mktemp -d "${TMPDIR:-/tmp}/runeon-dxmt-patchset.XXXXXX")"
trap 'rm -rf "$staging"' EXIT
mkdir -p "$staging/$name/base"

cp "$base_manifest" "$staging/$name/base/"
cp "$series_file" "$patch_manifest" "$repo_root/LICENSE" "$repo_root/README.md" "$repo_root/BUILDING.md" "$staging/$name/"
while IFS= read -r relative_patch; do
  mkdir -p "$staging/$name/$(dirname "$relative_patch")"
  cp "$repo_root/$relative_patch" "$staging/$name/$relative_patch"
done < <(series_paths)

archive="$out_dir/$name.tar.gz"
create_reproducible_tar_gz "$staging/$name" "$archive"
(cd "$out_dir" && printf '%s  %s\n' "$(sha256_file "$archive")" "$name.tar.gz" >"$name.tar.gz.sha256")
printf '%s\n' "$archive"
