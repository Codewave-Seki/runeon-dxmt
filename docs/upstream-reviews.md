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
