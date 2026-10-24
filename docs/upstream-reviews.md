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
