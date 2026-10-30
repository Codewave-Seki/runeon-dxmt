#!/usr/bin/env bash

set -euo pipefail
umask 022

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "$script_dir/.." && pwd)"
work_root="${RUNEON_DXMT_WORK_ROOT:-$repo_root/.work}"
# The newest patch set unless RUNEON_DXMT_PATCHSET_DEFINITION selects another.
patchset_definition="${RUNEON_DXMT_PATCHSET_DEFINITION:-}"
if [[ -z "$patchset_definition" ]]; then
  patchset_definition="$(cd "$repo_root" && ls -d patchsets/*/ 2>/dev/null | sort -V | tail -n 1 || true)"
  patchset_definition="${patchset_definition%/}"
fi
[[ -n "$patchset_definition" ]] || { printf 'error: no patch set under patchsets/\n' >&2; exit 1; }
patchset_definition="$(cd "$repo_root" && cd "$patchset_definition" && pwd)"
patch_manifest="$patchset_definition/manifest.json"
series_file="$patchset_definition/series"
# Each patch set names its base; earlier patch sets keep theirs.
base_manifest="$repo_root/base/$(jq -r '.baseId' "$patch_manifest" 2>/dev/null || true).json"

# git am needs a committer; manifests record the resulting tree, not commit IDs.
export GIT_COMMITTER_NAME="Runeon DXMT" GIT_COMMITTER_EMAIL="support@runeon.app"

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "required command not found: $1"
}

require_file() {
  [[ -f "$1" ]] || die "required file not found: $1"
}

json_value() {
  require_command jq
  jq -er "$2" "$1"
}

sha256_file() {
  if command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    sha256sum "$1" | awk '{print $1}'
  fi
}

series_paths() {
  sed -e '/^[[:space:]]*#/d' -e '/^[[:space:]]*$/d' "$series_file"
}

load_manifests() {
  require_file "$base_manifest"
  require_file "$patch_manifest"
  require_file "$series_file"

  base_id="$(json_value "$base_manifest" '.baseId')"
  base_repository="$(json_value "$base_manifest" '.repository')"
  # A base is an upstream tag or, while upstream has no newer release, a commit.
  base_tag="$(jq -r '.tag // empty' "$base_manifest")"
  base_commit="$(json_value "$base_manifest" '.commit')"
  base_ref="${base_tag:-$base_commit}"
  bundle_timestamp="$(json_value "$base_manifest" '.bundleTimestamp')"
  patch_set_id="$(json_value "$patch_manifest" '.patchSetId')"
  result_tree="$(json_value "$patch_manifest" '.resultTree')"
}

# A checkout is a valid base when HEAD is the pinned commit, every submodule is
# at its pinned commit, and nothing is modified.
assert_base_checkout() {
  local root="$1" path expected actual

  [[ "$(git -C "$root" rev-parse HEAD)" == "$base_commit" ]] \
    || die "$root is not at $base_ref ($base_commit)"
  while IFS=$'\t' read -r path expected; do
    actual="$(git -C "$root/$path" rev-parse HEAD 2>/dev/null)" \
      || die "submodule not checked out: $path"
    [[ "$actual" == "$expected" ]] || die "submodule $path is at $actual, expected $expected"
  done < <(jq -r '.submodules | to_entries[] | [.key, .value] | @tsv' "$base_manifest")
  [[ -z "$(git -C "$root" status --porcelain --ignore-submodules=none)" ]] \
    || die "$root has local changes"
}

# Applies the series with git am onto the checkout and checks the resulting
# tree against the manifest.
apply_series_to() {
  local root="$1" relative_patch expected

  while IFS= read -r relative_patch; do
    expected="$(jq -er --arg path "$relative_patch" '.patches[] | select(.path == $path) | .sha256' "$patch_manifest")" \
      || die "patch not in manifest: $relative_patch"
    [[ "$(sha256_file "$repo_root/$relative_patch")" == "$expected" ]] \
      || die "patch SHA-256 mismatch: $relative_patch"
    git -C "$root" am --quiet --committer-date-is-author-date "$repo_root/$relative_patch" \
      || { git -C "$root" am --abort; die "patch does not apply: $relative_patch"; }
  done < <(series_paths)
  [[ "$(git -C "$root" rev-parse 'HEAD^{tree}')" == "$result_tree" ]] \
    || die "patched tree differs from resultTree in $patch_manifest"
}

require_release_tag_checkout_if_published() {
  local tag_commit

  tag_commit="$(git -C "$repo_root" rev-parse --verify --quiet "refs/tags/$patch_set_id^{commit}")" || return 0
  [[ "$(git -C "$repo_root" rev-parse HEAD)" == "$tag_commit" ]] \
    || die "published patch set $patch_set_id must be built from its tag checkout"
}

create_reproducible_tar_gz() {
  local bundle_root="$1" archive="$2" parent name list

  parent="$(cd "$(dirname "$bundle_root")" && pwd)"
  name="$(basename "$bundle_root")"
  list="$parent/.runeon-archive-files"
  # Normalise modes and times so the digest does not depend on umask or clock.
  find "$bundle_root" -type d -exec chmod 755 {} +
  find "$bundle_root" -type f -perm -u+x -exec chmod 755 {} +
  find "$bundle_root" -type f ! -perm -u+x -exec chmod 644 {} +
  TZ=UTC find "$bundle_root" -exec touch -h -t "$bundle_timestamp" {} +
  (cd "$parent" && LC_ALL=C find "$name" -print | LC_ALL=C sort >"$list")
  if tar --version 2>/dev/null | grep -qi bsdtar; then
    COPYFILE_DISABLE=1 tar --format ustar --no-recursion --uid 0 --gid 0 --uname root --gname root \
      -cf - -C "$parent" -T "$list" | gzip -n >"$archive"
  else
    tar --format=ustar --no-recursion --owner=0 --group=0 --numeric-owner \
      -cf - -C "$parent" -T "$list" | gzip -n >"$archive"
  fi
  rm -f "$list"
}
