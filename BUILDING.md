# Building

This builds every file of a patch set's component the way the shipped component is built. It needs macOS with Xcode and its Metal toolchain (`dxmt_command.metal` is compiled into the DLLs), `meson`, `ninja`, `cmake`, mingw-w64, `jq`, `perl` (for `static-check.sh`), and an installed Wine that provides `winebuild` and its import libraries.

Patch sets up to `0.80-runeon.5` rebuilt only `d3d10core`, `d3d11`, `dxgi` and `nvapi64` and took `winemetal` and `nvngx` from the DXMT release; the `BUILDING.md` inside their patch-set bundle describes that build. From `0.80-runeon.6` the base is an upstream commit without a release, so everything is built here.

## Prepare the source

```bash
source_root="$(scripts/fetch-source.sh)"     # clones the pinned tag or commit with its submodules into .work/
scripts/apply-series.sh "$source_root"       # git am of every patch in series order, then a tree check
```

`apply-series.sh` changes the checkout in place. To start again, run `git -C "$source_root" reset --hard <base commit>` or remove `.work/source/`. Select an earlier patch set with `RUNEON_DXMT_PATCHSET_DEFINITION=patchsets/<id>`.

Without the scripts, the same tree comes from:

```bash
git clone https://github.com/3Shain/dxmt.git && cd dxmt
git checkout --detach <base commit> && git submodule update --init --recursive
git -c user.name=build -c user.email=build@example.invalid am $(sed "s|^|/path/to/runeon-dxmt/|" /path/to/runeon-dxmt/patchsets/<id>/series)
git rev-parse 'HEAD^{tree}'   # equals resultTree in the manifest
```

## Set the deployment target

Set the deployment target in the shell that builds LLVM and DXMT:

```bash
export MACOSX_DEPLOYMENT_TARGET=26.0
```

The component supports macOS 26 and later. Without this variable the toolchain targets the build machine's own SDK: on a newer macOS, `xcrun metal` compiles `dxmt_command.metal` for a newer AIR version (for example `air64_v29-apple-macosx27.0.0`), and Metal on macOS 26 refuses to load that library. Check the result with `LC_ALL=C grep -aoE 'air64_v[0-9]+-apple-macosx[0-9.]+' d3d11.dll`, which must report `macosx26.0.0`. `winemetal.so` must show `minos 26.0` in `otool -l`.

## Build LLVM

`winemetal.so` statically links the `airconv` shader converter and LLVM, which must be exactly major version 15. Only LLVM's core libraries are needed, for `x86_64`:

```bash
git clone --depth 1 --branch llvmorg-15.0.7 https://github.com/llvm/llvm-project.git
cmake -G Ninja -B llvm-build -S llvm-project/llvm \
  -DCMAKE_INSTALL_PREFIX="$PWD/llvm" -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_OSX_ARCHITECTURES=x86_64 -DCMAKE_OSX_DEPLOYMENT_TARGET=26.0 \
  -DLLVM_HOST_TRIPLE=x86_64-apple-darwin -DLLVM_TARGETS_TO_BUILD="" \
  -DLLVM_ENABLE_ASSERTIONS=On -DLLVM_ENABLE_ZSTD=Off \
  -DLLVM_BUILD_TOOLS=Off -DLLVM_INCLUDE_BENCHMARKS=Off \
  -DCMAKE_CXX_FLAGS="-D_LIBCPP_KEEP_TRANSITIVE_INCLUDES_LLVM23" \
  -DBUG_REPORT_URL="https://github.com/3Shain/dxmt" -DPACKAGE_VENDOR="DXMT" \
  -DLLVM_VERSION_PRINTER_SHOW_HOST_TARGET_INFO=Off -DCMAKE_POLICY_VERSION_MINIMUM=3.5
cmake --build llvm-build && cmake --install llvm-build
```

These are the options of DXMT's own CI, plus the deployment target and `CMAKE_POLICY_VERSION_MINIMUM`, which CMake 4 needs for LLVM 15.

## Build the component

Build directories stay outside the source tree, so the checkout stays clean for `build-source-bundle.sh`. The options are those of DXMT's own release build:

```bash
cd "$source_root"
meson setup ../build64 --cross-file build-win64.txt --buildtype release --prefix "$PWD/../install" --strip \
  -Denable_nvapi=true -Denable_nvngx=true \
  -Dnative_llvm_path=<LLVM install> -Dwine_install_path=<Wine install>
meson compile -C ../build64 && meson install -C ../build64
meson setup ../build32 --cross-file build-win32.txt --buildtype release --prefix "$PWD/../install" --strip \
  -Dwine_install_path=<Wine install>
meson compile -C ../build32 && meson install -C ../build32
```

The Wine install must provide `bin/winebuild` and `lib/wine/<arch>-windows/` with `libwinecrt0.a`, `libntdll.a` and `libdbghelp.a`. Runeon builds against the Wine of [runeon-wine](https://github.com/Codewave-Seki/runeon-wine).

`../install` then holds the component: `x86_64-windows/` (`d3d10core`, `d3d11`, `dxgi`, `nvapi64`, `nvngx`, `winemetal`), `i386-windows/` (`d3d10core`, `d3d11`, `dxgi`, `winemetal`) and `x86_64-unix/winemetal.so`. The default `wine_builtin_dll=true` marks every DLL as a Wine builtin DLL; leave out the `.a` import libraries. `d3d12.dll` is not built (`enable_d3d12` is off).

## Release bundles

From the tag checkout of a published patch set, after `apply-series.sh`:

```bash
scripts/build-source-bundle.sh "$source_root" dist    # patched tree with submodules, plus RUNEON-SOURCE.json
scripts/build-patchset-bundle.sh dist                 # base pin, series, manifest and patches
```

Both write a `.tar.gz` and its `.sha256`. Archives are reproducible: fixed timestamps, owners and file order.
