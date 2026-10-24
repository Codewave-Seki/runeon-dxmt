# Building

This builds the DLLs of a patch set the way the shipped component is built. It needs macOS with Xcode and its Metal toolchain (`dxmt_command.metal` is compiled into the DLLs), `meson`, `ninja`, mingw-w64, `jq`, `perl` (for `static-check.sh`), and an installed Wine that provides `winebuild`.

## Prepare the source

```bash
source_root="$(scripts/fetch-source.sh)"     # clones the pinned tag with its submodules into .work/
scripts/apply-series.sh "$source_root"       # git am of every patch in series order, then a tree check
```

`apply-series.sh` changes the checkout in place. To start again, run `git -C "$source_root" reset --hard <base commit>` or remove `.work/source/`. Select an earlier patch set with `RUNEON_DXMT_PATCHSET_DEFINITION=patchsets/<id>`.

Without the scripts, the same tree comes from:

```bash
git clone --recurse-submodules --branch v0.80 https://github.com/3Shain/dxmt.git
cd dxmt && git -c user.name=build -c user.email=build@example.invalid am $(sed "s|^|/path/to/runeon-dxmt/|" /path/to/runeon-dxmt/patchsets/<id>/series)
git rev-parse 'HEAD^{tree}'   # equals resultTree in the manifest
```

## Build the DLLs

Build directories stay outside the source tree, so the checkout stays clean for `build-source-bundle.sh`. Only the DLL targets are built; `winemetal` and `nvngx` are DXMT's release binaries for the base tag.

```bash
cd "$source_root"
meson setup ../build64 --cross-file build-win64.txt --buildtype release \
  -Dwine_builtin_dll=false -Denable_nvapi=true \
  -Dnative_llvm_path=<empty directory> -Dwine_install_path=<Wine install>
meson setup ../build32 --cross-file build-win32.txt --buildtype release \
  -Dwine_builtin_dll=false \
  -Dnative_llvm_path=<empty directory> -Dwine_install_path=<Wine install>
ninja -C ../build64 src/d3d10/d3d10core.dll src/d3d11/d3d11.dll src/dxgi/dxgi.dll src/nvapi/nvapi64.dll
ninja -C ../build32 src/d3d10/d3d10core.dll src/d3d11/d3d11.dll src/dxgi/dxgi.dll
```

Then remove the debug sections of `nvapi64.dll` with `x86_64-w64-mingw32-strip --strip-debug`, and mark the rebuilt DLLs as Wine builtin DLLs with `winebuild --builtin`, as DXMT's release DLLs already are.

## Release bundles

From the tag checkout of a published patch set, after `apply-series.sh`:

```bash
scripts/build-source-bundle.sh "$source_root" dist    # patched tree with submodules, plus RUNEON-SOURCE.json
scripts/build-patchset-bundle.sh dist                 # base pin, series, manifest and patches
```

Both write a `.tar.gz` and its `.sha256`. Archives are reproducible: fixed timestamps, owners and file order.
