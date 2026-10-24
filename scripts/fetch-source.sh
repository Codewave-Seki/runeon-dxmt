#!/usr/bin/env bash
# Clones the pinned DXMT tag with its submodules into the work root (once),
# verifies it, and prints its path.

set -euo pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=common.sh
source "$script_dir/common.sh"

load_manifests
require_command git
source_root="$work_root/source/$base_id"

if [[ ! -d "$source_root/.git" ]]; then
  mkdir -p "$(dirname "$source_root")"
  printf 'cloning %s %s\n' "$base_repository" "$base_tag" >&2
  git -c advice.detachedHead=false clone --quiet --recurse-submodules --branch "$base_tag" \
    "$base_repository" "$source_root"
fi

assert_base_checkout "$source_root"
printf '%s\n' "$source_root"
