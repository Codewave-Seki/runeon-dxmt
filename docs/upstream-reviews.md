# Upstream Reviews

Each section records one review of upstream DXMT: what was taken, what was left out and why. Sections are append-only; a later review supersedes an earlier decision by recording a new one.

<a id="backports-0.80-20261020"></a>
## BACKPORTS-0.80-20261020

- Base: DXMT `v0.80` (`589adb780354b461645b29999cefaf533594ee99`).
- Upstream range: `v0.80..main`, reviewed in October 2026. The review did not record the exact upstream head, so the next audit starts again at `v0.80` and skips the commits below.
- First patch set: `0.80-runeon.5`. It was built and shipped before this repository existed; this repository records its series unchanged.

### Taken

Fixes in code the rebuilt DLLs (`d3d10core`, `d3d11`, `dxgi`, `nvapi64`) contain, in series order:

| Patch | Upstream commit | Summary |
|---|---|---|
| `0001` | `05e4a9fcff6a` | fix(d3d11): correct reported `DestBlend` and `SrcBlendAlpha` values in `ID3D11BlendState::GetDesc()` |
| `0002` | `6251cffd33ad` | fix(d3d11): clamp sampler max anisotropy |
| `0003` | `aadf0fbbaa28` | fix(dxmt): add missing increment in loop |
| `0004` | `ab984cfd0083` | fix(d3d11): disable color attachments in mesh pipeline if no pixel shader is bound and rasterization is enabled |
| `0005` | `46911d734538` | fix(d3d11, dxmt): sanitize invalid draw calls |
| `0006` | `cde48cb8910c` | fix(dxmt): correct stencil read component in blit kernel |
| `0007` | `b1f8bdf1b514` | fix(dxmt): ensure valid `BufferViewKey` is not a null value |
| `0008` | `fd7763b9a5c1` | fix(d3d11,dxgi): ignore ID3D11InfoQueue, IMTLD3D11ContextExt, IWineDXGIAdapter, interface requests |
| `0009` | `32c30a8848a9` | fix(d3d10): correctly pass `StartInstanceLocation` parameter in `DrawIndexedInstanced()` |
| `0010` | `1df5dd9e1fd0` | fix(d3d11): create `MTLD3D11FenceImpl` with a smart pointer container |
| `0011` | `66277b82e359` | fix(d3d11): make pure virtual call non-fatal |
| `0012` | `830eb41996bc` | fix(d3d11): raise vertex buffer binding count to `D3D11_IA_VERTEX_INPUT_RESOURCE_SLOT_COUNT` |
| `0013` | `f9beaea30b95` | fix(dxmt): pass mipped width & height to clear encoder |
| `0014` | `acda4f9419eb` | fix(d3d11): remove `d3d11_device_mutex::try_lock()` |
| `0015` | `a22700c7391e` | fix: fix a couple of copy-paste bugs |
| `0016` | `e4f868dc3e53` | fix(d3d10): fix a wrong pointer assignment |
| `0017` | `0fff7ffe5948` | fix(nvapi): copy build branch string with null terminator |
| `0018` | `ce79ad0ad382` | fix(d3d11): fix some logic flaws in dilated motion vector handling |
| `0019` | `0b6399085a2f` | fix(d3d11): lock device in `Signal()` and `Wait()` |
| `0020` | `68af85e96196` | fix(d3d11): handle legitimate null parameter in `Create{Blend\|Rasterizer}State()` |
| `0021` | `e94c312f5c05` | fix(d3d11): avoid deadlock on reentrant `ResizeTarget()` |
| `0022` | `186a2327f1ec` | fix(d3d11): `pMappedResource` argument in `ID3D11DeviceContext::Map` can be NULL |
| `0023` | `e55ad281c60b` | fix(d3d12, dxgi): make some stubs non-fatal |

`0022` (`186a2327f1ec`) made `Map()` with a NULL `pMappedResource` on a resource that is neither dynamic nor staging reach `UNIMPLEMENTED`, which aborts the process in release builds. Downstream `0102` restores the `v0.80` failure for that case and keeps the rest of the commit.

### Downstream changes

| Patch | Summary |
|---|---|
| `0100` | `ID3D11Texture2D` answers `IDXGISurface`, which Wine's Direct2D needs to draw into a D3D10 texture |
| `0101` | `SwapDeviceContextState`, which Wine's Direct2D uses to swap its pipeline state in and out |
| `0102` | `Map()` of a default resource with a NULL `pMappedResource` fails instead of aborting (see `0022`) |

### Left out

- D3D12 features and fixes, except where they touch `dxgi` (`0023`): the component does not ship DXMT's `d3d12.dll`.
- `airconv` shader converter fixes: `airconv` is part of `winemetal`, which this patch set takes unchanged from the `v0.80` release instead of rebuilding.
- Refactors, build-system, CI and test-only commits.

### Verification

- The series applies to `v0.80` with `git am` and produces the recorded `resultTree`.
- A local D3D10/D3D11 probe confirmed the observable fixes it covers (`ID3D11BlendState::GetDesc()`, `ID3D10Device::IAGetIndexBuffer()`, null output pointers in `Create{Blend|Rasterizer}State()`, and `Map()` with a NULL output on the immediate and a deferred context). The remaining fixes were checked by code review only; their drawing, shading and synchronisation paths were not run individually.

<a id="base-main-3b252590-20261031"></a>
## BASE-MAIN-3B252590-20261031

- Previous base: DXMT `v0.80` (`589adb780354b461645b29999cefaf533594ee99`) with the 26 commits of `0.80-runeon.5`.
- New base: upstream `main` at `3b252590cb0290e36fca6f088b5255b871d2d95a` (2026-10-27, `v0.80-365-g3b252590`), with the same submodule commits as `v0.80`. Upstream has published no release since `v0.80` (2026-04-23).
- Upstream range: `v0.80..3b252590`, 365 commits: 239 `feat`, 82 `fix`, 20 `chore`, 15 `refactor`, 5 `ci`, 3 `build`, 1 `docs`. 343 are by Feifan He and 22 by nine other authors.
- First patch set: `0.80-runeon.6`.

### Why a new base

- All 23 fixes of [BACKPORTS-0.80-20261020](#backports-0.80-20261020) are on `main`.
- Downstream `0100` and `0101` are superseded upstream by `a148782` (DXGI surface on textures) and `e186434` (`SwapDeviceContextState()`).
- `main` builds `winemetal`, with the `airconv` shader converter, and `nvngx` from source, so their fixes reach the component without a release.

### Downstream changes

| Patch | Summary |
|---|---|
| `0102` | `Map()` of a default resource with a NULL `pMappedResource` fails instead of aborting. `3b252590` still reaches `UNIMPLEMENTED("map-on-default: map")` in both `d3d11_context_imm.cpp` and `d3d11_context_def.cpp`; the patch applies unchanged. |

### What changes for the component

| Path | Commits | Effect |
|---|---|---|
| `src/d3d12` | 166 | Not built: `enable_d3d12` is off, and the component does not ship DXMT's `d3d12.dll` |
| `src/airconv` | 107 | 55 are DXIL (shader model 6) work that only `d3d12.dll` uses. The rest change the DXBC path every D3D10/D3D11 shader takes: a new binding model (`BindingMap`, root-signature bindings), `VertexPuller` and `IOHelper`, 16-bit inputs and resources, and geometry and tessellation shader fixes. The shader cache version is now 26 (`AIRCONV_VERSION`; `kDXMTShaderCacheVersion` was 18 at `v0.80`), so existing shader caches are rebuilt |
| `src/d3d11`, `src/d3d10`, `src/dxgi` | 36, 3, 10 | The 23 fixes already backported, keyed mutexes, DXGI surfaces, heap allocation, copies between texture types, `d3d11.maxTessFactor` |
| `src/dxmt`, `src/winemetal`, `src/util` | 26, 24, 7 | `ClearRTV`/`ClearUAV` encoding, ref-counted fences, heap allocation, format plane counts, fixes for the Xcode 27 toolchain |
| `src/nvapi`, `src/nvngx` | 1, 3 | Build-branch string fix (backported before); DLSS stand-in fixes for resources passed as `void *`, the default pre-exposure value and the NGX error value |

The whole tree is LGPL-2.1-or-later since `ec357fd`; code as of `v0.80` remains available under MIT (`LICENSE.OLD`). The built files also contain third-party code: Microsoft's DXBCParser (MIT), code derived from DXVK (zlib), NVIDIA's NVAPI headers (MIT) and, statically linked into `winemetal.so`, LLVM 15.0.7 (Apache-2.0 WITH LLVM-exception).

### Left out

- Commits after `3b252590`.
- `d3d12.dll`, the ARM64EC build and DXMT's native macOS build.

### Verification

- The series applies to `3b252590` with `git am` and produces the recorded `resultTree`.
- A complete `x86_64` and `i386` build follows `BUILDING.md` with Xcode 27.1 (Metal 32023.921), mingw-w64 GCC 15.2.0, Meson 1.11.1, Ninja 1.13.2, CMake 4.4.5, LLVM 15.0.7, deployment target 26.0, and the Wine of runeon-wine `cx26.3-wine11.0-runeon.28`. Every DLL carries the Wine builtin mark, `winemetal.so` reports `minos 26.0`, and the Metal library in `d3d11.dll` targets `air64_v28-apple-macosx26.0.0`.
- An earlier build of the same tree with the same toolchain had the same file set as DXMT's own CI build of `3b252590`, with sizes within 3%.
- A D3D10/D3D11 probe (device creation at every feature level, a Direct2D render target, and the probes for the backported fixes and `0102`) gives output identical to `0.80-runeon.5`.
- Two D3D11 games, a 32-bit Unity 5.5 title and a 64-bit Unity 6 title with an embedded Chromium, were compared with `0.80-runeon.5` using Metal's performance HUD: no new failure, and the same frame rate and GPU time per frame. A slow menu in each game behaved the same with both versions; samples placed it in the game's own CPU work and in Chromium start-up, not in DXMT.
- Not verified: most of the 365 commits individually; geometry and tessellation shader paths, which no probe exercised; and running on macOS 26, because the test machine runs macOS 27.0.1.

<a id="base-main-0df86108-20261117"></a>
## BASE-MAIN-0DF86108-20261117

- Previous base: upstream `main` at `3b252590cb0290e36fca6f088b5255b871d2d95a` ([BASE-MAIN-3B252590-20261031](#base-main-3b252590-20261031)).
- New base: upstream `main` at `0df86108348bab2aaa5c4610a5eb63a9de9047ac` (2026-11-10, `v0.80-408-g0df8610`), with the same submodule commits as `3b252590`. Upstream has published no release since `v0.80` (2026-04-23).
- Upstream range: `3b252590..0df86108`, 43 commits: 28 `feat`, 9 `fix`, 4 `refactor`, 2 `chore`. 38 are by Feifan He and 5 by Paweł Kołodziejski.
- Reviewed through: `0df86108`.
- First patch set: `0.80-runeon.8`.

### Why a new base

- The maintainer decided to take every upstream commit up to the newest point, without selecting individual commits, and to carry the downstream changes on top. The new base is therefore the upstream commit itself; nothing is cherry-picked.
- The commits were not reviewed one by one for defects in the previous base. The table below records what each area changes for the component.

### Downstream changes

| Patch | Summary |
|---|---|
| `0102` | `Map()` of a default resource with a NULL `pMappedResource` fails instead of aborting. `0df86108` still reaches `UNIMPLEMENTED("map-on-default: map")`; the patch applies unchanged. |
| `0103` | The presenter keeps the Metal layer's opacity as the window system set it, so a window that composites its alpha channel shows the transparent parts of the swap chain. No upstream commit in the range touches `src/dxmt`; the patch applies unchanged. |
| `0104` | `IDXGISwapChain1::SetRotation()` accepts identity on flip-model swap chains. Upstream `b09855e` adds a format check to `CreateSwapChain()` in the same file but does not change `SetRotation()`; the patch applies unchanged. |
| `0105` | Placed Metal buffer memory stays non-executable in 32-bit processes running with DEP off. No upstream commit in the range touches `src/dxmt` or `src/winemetal`; the patch applies unchanged. |
| `0106` | Rows of mappable linear 2D textures are padded to 256 bytes, and initial data copies use each side's own pitch. Upstream `d2dd386` changes a bounds check in `d3d11_resource_staging.cpp` outside the patched code; the patch applies unchanged. |

Admission notes:

- `0105`: approved by the maintainer for default use without opt-in. It only changes the host protection of memory DXMT allocates for its own Metal buffers, in processes running with DEP off, to fix a locally reproduced stall; it does not change the process DEP policy.
- `0106`: approved by the maintainer for default use. It adopts a padded row layout that conforms to the D3D11 contract, to resolve an application compatibility problem located on a local machine. It does not depend on identifying games and is not enabled per game. This decision does not mean that Windows drivers uniformly use this alignment, and it does not widen the admission scope for other patches.

### What changes for the component

| Path | Commits | Effect |
|---|---|---|
| `src/airconv` | 37 | 27 are DXIL (shader model 6) work that only `d3d12.dll` uses: hull and domain shaders, wave intrinsics, bitfield, `msad`, `cbufferLoad`, pull-mode evaluation and others. The DXBC path every D3D10/D3D11 shader takes changes in `4636f5c` (indexable hull shader control point input), `7456c4e` (clip and cull values pass through domain shaders), `961f57d` (hull control point write moved), `0df8610` (geometry shader index buffer sentinel check) and `6e69d0f` (input attribute type refactor). `AIRCONV_VERSION` stays 26, so shader caches written by earlier patch sets are not invalidated |
| `src/d3d11` | 6 | `d2dd386` corrects off-by-one subresource index checks when staging and dynamic textures create a DXGI surface; `fae6cb8` fails `D3D11CreateDeviceAndSwapChain` with `E_INVALIDARG` for an unknown driver type, or a software driver type without a module; `b09855e` fails `CreateSwapChain` with `E_INVALIDARG` for a format Metal cannot present; `5e85544` returns `E_NOINTERFACE` for `ID3D10Device` on a device not created through `d3d10core`; `23a4d50` warns and returns `E_NOINTERFACE` for `ID3D11VideoContext`; `bf14438` fails `CreateDeferredContext*` with `DXGI_ERROR_INVALID_CALL` on a single-threaded device and leaves the output untouched on failure |
| Build system | 0 | No change to `meson.build`, `meson_options.txt`, the cross files, the submodules or the installed file set |

### Upstream commits included

- `d2dd386` fix(d3d11): correct flawed out-of-bound checks. (Feifan He)
- `961f57d` refactor(airconv): move hull control point write to main converter function (Feifan He)
- `842ca5b` feat(airconv): implement dxil `binaryWithTwoOuts` (Feifan He)
- `7c9f057` feat(airconv): implement dxil bitcast intrinsics (Feifan He)
- `1f31cb5` feat(airconv): parse dxil tessellation metadata (Feifan He)
- `f829356` chore(airconv): remove duplicated variable definitions (Feifan He)
- `5809ad1` fix(airconv): always use `center_no_perspective` interpolation for position input in pixel shader (Feifan He)
- `affe3ce` feat(airconv): handle dynamic row value of `loadInput` (Feifan He)
- `2d4bda0` feat(airconv): parse dxil hull and domain shader (Feifan He)
- `af9b19b` feat(airconv): implement dxil `SV_OutputControlPointID` and `SV_Domain` (Feifan He)
- `90994b5` feat(airconv): support `storeOutput` in hull shader (Feifan He)
- `2d788da` feat(airconv): implement dxil `storePatchConstant` (Feifan He)
- `59b9efc` feat(airconv): implement dxil `loadOutputControlPoint` (Feifan He)
- `af2c039` feat(airconv): implement dxil `loadPatchConstant` (Feifan He)
- `180290b` refactor(airconv): dispatch dxil op translation by numerical id instead of name string (Feifan He)
- `4636f5c` fix(airconv): make dxbc control point input indexable (Feifan He)
- `7456c4e` feat(airconv): make clip/cull value pass through in dxbc domain shader (Feifan He)
- `9af0654` feat(airconv): implement dxil bitfield extract (Feifan He)
- `647b002` feat(airconv): implement dxil `SV_StencilRef` (Feifan He)
- `fae6cb8` fix(d3d11): fixed handling invalid Driver Type in `D3D11CreateDeviceAndSwapChain` (Paweł Kołodziejski)
- `b09855e` fix(d3d11): fixed handling invalid pixel format for swapchain buffer in `CreateSwapChain` (Paweł Kołodziejski)
- `5e85544` fix(d3d11): fixed handling invalid device query in `QueryInterface` (Paweł Kołodziejski)
- `23a4d50` fix(d3d11): warning about missing D3D11VideoContext implementation in `QueryInterface` (Paweł Kołodziejski)
- `bf14438` fix(d3d11): handle invalid call for deferred context when device is single threaded enabled. (Paweł Kołodziejski)
- `7b18b4e` feat(airconv): return zero for dxil `viewID` (Feifan He)
- `6cfa42a` feat(airconv): implement dxil `renderTargetGetSamplePosition` (Feifan He)
- `640ad70` feat(airconv): implement dxil pull-mode evaluation (Feifan He)
- `c01e79e` feat(airconv): implement dxil `waveAnyTrue` and `waveAllTrue` (Feifan He)
- `6d705a1` feat(airconv): implement dxil `waveIsFirstLane` (Feifan He)
- `9d882b3` feat(airconv): implement dxil `waveActiveOp` and `wavePrefixOp` (Feifan He)
- `17c6dba` feat(airconv): implement dxil `waveAllBitCount` and `wavePrefixBitCount` (Feifan He)
- `db02949` feat(airconv): implement dxil `waveActiveBit` (Feifan He)
- `83a322f` feat(airconv): implement dxil `waveActiveBallot` (Feifan He)
- `c08669d` feat(airconv): implement dxil `waveReadLaneFirst` (Feifan He)
- `7b0af44` feat(airconv): implement dxil `waveActiveAllEqual` (Feifan He)
- `866b0b7` feat(airconv): implement dxil `msad` (Feifan He)
- `4f248a8` feat(airconv): implement dxil `bfi` (Feifan He)
- `bebf48e` feat(airconv): implement dxil buffer oob access behavior (Feifan He)
- `c8a68ee` feat(airconv): implement dxil `cbufferLoad` (Feifan He)
- `c683793` chore(airconv): skip inspecting input semantics of geometry shader (Feifan He)
- `b75f71d` refactor(airconv): remove one indirection of `RegisterComponentType` for dxil ps output (Feifan He)
- `6e69d0f` refactor(airconv): remove `air::InputAttributeComponentType` (Feifan He)
- `0df8610` fix(airconv): correct index buffer sentinel value check in gs converter (Feifan He)

### Left out

- Commits after `0df86108`.
- `d3d12.dll`, the ARM64EC build and DXMT's native macOS build.

### Verification

- The series applies to `0df86108` with `git am` and produces the recorded `resultTree`.
- A complete `x86_64` and `i386` build follows `BUILDING.md` with Xcode 27.1 (Metal 32023.921), mingw-w64 GCC 15.2.0, Meson 1.11.1, Ninja 1.13.2, CMake 4.4.5, LLVM 15.0.7, deployment target 26.0, and the Wine of runeon-wine `cx26.3-wine11.0-runeon.37`. Every DLL carries the Wine builtin mark, `winemetal.so` reports `minos 26.0`, and the Metal library in `d3d11.dll` targets `air64_v28-apple-macosx26.0.0`.
- Two independent clones of the tagged commit produce byte-identical patch-set and source bundles. The released build differs from the build used for testing only in PE timestamps and checksums and in the build directory embedded in `winemetal.so`.
- In a fresh prefix, on both `i386` and `x86_64`, the `SetRotation()` probe for `0104`, the linear texture probe for `0106` and the probes for the backported fixes pass. The `0106` probe covers several widths, tight and padded source pitches, dynamic and staging textures and rows read back after a GPU copy; an 804×256 `R8G8B8A8` texture gets `RowPitch` 3328.
- Games: the 32-bit D3D11 title that motivated `0104`–`0106` no longer aborts at start-up, no longer stalls periodically with DEP off, and no longer crashes on its texture uploads; another D3D11 title shows no new failure.
- Not verified: most of the 43 commits individually; geometry and tessellation shader paths, which no probe exercised; and running on macOS 26, because the test machine runs macOS 27.0.1.

### Verification of 0.80-runeon.9

`0.80-runeon.9` is `0.80-runeon.8` on the same base plus the downstream patch `0107`; its rationale is in the commit that added it.

- The series applies to `0df86108` with `git am` and produces the recorded `resultTree`.
- A complete `x86_64` and `i386` build follows `BUILDING.md`; the tag is on `c9d68a9`. Two independent clones of that commit produce byte-identical patch-set and source bundles.
- The released `x86_64-windows/nvngx.dll` carries Runeon's Authenticode signature, certificate SHA-256 `c47062133e659af51e2226f781a5856478d5fe1212973b0f877bd4b33fe1aa5b`.
- Game, on macOS 27.0.1 with runeon-wine `cx26.3-wine11.0-runeon.41` (maintainer's local tests, local build and the released Dev build): with `DXMT_ENABLE_NVEXT` and `DXMT_NVEXT_NGX_PATH` set by the launcher's route, a D3D11 title logged `runeon-dxmt-nvext-ngx-path-1` with that directory, loaded `_nvngx.dll` from it and offered DLSS. Without them the same title enabled no vendor extension and offered no DLSS. Every run exited normally.
- Not verified: the separate registry probe for `0107`; a comparison against `0.80-runeon.8` on a second D3D11 title; running on macOS 26.
