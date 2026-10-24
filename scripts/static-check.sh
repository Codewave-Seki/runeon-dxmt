#!/usr/bin/env bash

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$script_dir/common.sh"

load_manifests
require_command jq
require_command perl
require_file "$repo_root/LICENSE"

[[ "$(json_value "$patch_manifest" '.baseId')" == "$base_id" ]] \
  || die "base ID differs between base and patch manifests"
[[ "$(basename "$patchset_definition")" == "$patch_set_id" ]] \
  || die "patch-set directory name differs from patchSetId: $patchset_definition"
[[ "$result_tree" =~ ^[0-9a-f]{40}$ ]] || die "resultTree must be a full tree SHA"

[[ "$(series_paths)" == "$(jq -r '.patches | sort_by(.order)[] | .path' "$patch_manifest")" ]] \
  || die "series and patch manifest order differ"

while IFS= read -r relative_patch; do
  require_file "$repo_root/$relative_patch"
  entry="$(jq -ec --arg path "$relative_patch" '.patches[] | select(.path == $path)' "$patch_manifest")"
  [[ "$(sha256_file "$repo_root/$relative_patch")" == "$(jq -r .sha256 <<<"$entry")" ]] \
    || die "patch SHA-256 mismatch: $relative_patch"
  jq -e '.summary | length > 0' <<<"$entry" >/dev/null || die "summary missing: $relative_patch"
  case "$(jq -r .kind <<<"$entry"):$relative_patch" in
    upstream-backport:patches/upstream/*)
      jq -e '.upstreamCommits | length > 0 and all(test("^[0-9a-f]{40}$"))' <<<"$entry" >/dev/null \
        || die "upstream backport needs full upstreamCommits: $relative_patch" ;;
    runeon:patches/runeon/*) ;;
    *) die "kind does not match directory: $relative_patch" ;;
  esac
done < <(series_paths)

for shell_script in "$repo_root"/scripts/*.sh "$repo_root"/.githooks/*; do
  bash -n "$shell_script"
done

# Documents are a fixed set. Only the README is translated.
for root_document in "$repo_root"/*.md; do
  case "$(basename "$root_document")" in
    README.md|README.zh-CN.md|README.ja.md|BUILDING.md|MAINTENANCE.md|SECURITY.md|CLAUDE.md|AGENTS.md) ;;
    *) die "unexpected root document (add a section to an existing file instead): $root_document" ;;
  esac
done
while IFS= read -r docs_document; do
  [[ "${docs_document#"$repo_root"/}" == docs/upstream-reviews.md ]] \
    || die "unexpected document under docs/ (add a section instead): $docs_document"
done < <(find "$repo_root/docs" -type f)

readme_names=(README.md README.zh-CN.md README.ja.md)
for readme in "${readme_names[@]}"; do
  require_file "$repo_root/$readme"
  for name in "${readme_names[@]}"; do
    grep -Fq "($name)" "$repo_root/$readme" || die "README language link is missing $name: $readme"
  done
done

cjk='\p{Han}|\p{Hiragana}|\p{Katakana}'
while IFS= read -r english_file; do
  if perl -CSD -ne "\$found ||= /$cjk/; END { exit(\$found ? 0 : 1) }" "$english_file"; then
    die "English-only file contains Chinese or Japanese text: $english_file"
  fi
done < <(find "$repo_root" -maxdepth 1 -name '*.md' ! -name '*.zh-CN.md' ! -name '*.ja.md'
         find "$repo_root/docs" "$repo_root/base" "$repo_root/patchsets" "$repo_root/patches" "$repo_root/scripts" -type f)
perl -CSD -ne '$found ||= /\p{Han}/; END { exit($found ? 0 : 1) }' "$repo_root/README.zh-CN.md" \
  || die "Chinese README does not contain Chinese text"
perl -CSD -ne '$found ||= /\p{Hiragana}|\p{Katakana}/; END { exit($found ? 0 : 1) }' "$repo_root/README.ja.md" \
  || die "Japanese README does not contain Japanese text"

# Commit messages are English (CI needs the full history: fetch-depth 0).
if git -C "$repo_root" rev-parse --verify --quiet HEAD >/dev/null; then
  if git -C "$repo_root" log --format='%H%n%B' | perl -CSD -ne "if (/^([0-9a-f]{40})\$/) { \$c = \$1 } elsif (/$cjk/) { print \"\$c\\n\"; \$bad = 1 } END { exit(\$bad ? 0 : 1) }"; then
    die "commit messages above contain Chinese or Japanese text"
  fi
fi

printf 'static checks passed for %s\n' "$patch_set_id"
