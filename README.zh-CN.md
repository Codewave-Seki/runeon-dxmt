# Runeon DXMT

[English](README.md) | [Chinese](README.zh-CN.md) | [Japanese](README.ja.md)

> 英文文档为权威版本。中文与日文文档是为方便阅读提供的完整译本。

Runeon DXMT 是 Runeon 所分发 DXMT 组件的公开源码维护仓库。它包含固定的 [DXMT](https://github.com/3Shain/dxmt) tag 或 commit、回移到该 tag 上的上游修复、Runeon 自己的修改，以及重建每个已分发组件精确对应源码的脚本。本仓库不作任何广泛的兼容性承诺，也不包含 Runeon App、Steam、游戏或 Apple 私有图形组件。

## 基线与当前版本

- 上游：DXMT `v0.80`（`589adb7`），见 [`base/dxmt-0.80.json`](base/dxmt-0.80.json)；从 `0.80-runeon.6` 起为上游 `main` 的 `3b25259`，见 [`base/dxmt-main-3b252590.json`](base/dxmt-main-3b252590.json)
- 当前正式源码：[`0.80-runeon.5`](https://github.com/Codewave-Seki/runeon-dxmt/releases/tag/0.80-runeon.5)：23 个上游修复与 3 个 Runeon 修改。定义见 [`patchsets/0.80-runeon.5`](patchsets/0.80-runeon.5/manifest.json)
- 当前候选：[`0.80-runeon.6`](https://github.com/Codewave-Seki/runeon-dxmt/releases/tag/0.80-runeon.6)：上游 `main` 的 `3b25259` 与 1 个 Runeon 修改。定义见 [`patchsets/0.80-runeon.6`](patchsets/0.80-runeon.6/manifest.json)
- 上游审查记录：[MAINTENANCE.md](MAINTENANCE.md#review-records)

## 仓库结构

| 路径 | 内容 |
|---|---|
| `base/` | 固定的上游仓库、tag、commit 与 submodule commit |
| `patchsets/<id>/` | 一个补丁集的 `series` 与 `manifest.json`；脚本默认使用最新补丁集，可用 `RUNEON_DXMT_PATCHSET_DEFINITION=patchsets/<id>` 选择其他补丁集 |
| `patches/upstream/`、`patches/runeon/` | 上游 DXMT 回移与 Runeon 修改，每个文件一个 commit |
| `scripts/` | 获取、应用、检查与打包脚本 |
| `docs/` | 上游审查记录（英文） |

## 范围与边界

- 不提交 DXMT 源码树、构建产物、组件归档、prefix、用户数据或诊断信息。
- 从不下载、镜像或分发 `D3DMetal.framework`、`libd3dshared.dylib` 与 GPTK 私有 overlay。
- 能干净应用并不意味着上游 commit 会进入补丁集；每个 commit 都要先经过审查。
- Runeon 修改从不按游戏名、Steam AppID 或可执行文件名匹配。
- 每个进入 Production 的组件都有一个不可变的正式 Release，包含精确的补丁集 bundle、完整对应源码与 SHA-256 文件。候选版本保持为 Pre-release。tag 与 Release 资产从不移动、替换或删除。
- 组件的打包、签名与分发由 Runeon 产品仓库负责。

## 验证与构建

```bash
scripts/static-check.sh
source_root="$(scripts/fetch-source.sh)"
scripts/integration-check.sh "$source_root"
```

`integration-check.sh` 用 `git am` 把每个补丁依次应用到固定基线的临时 worktree 上，并检查结果是否为 manifest 记录的 tree。DLL 与 Release bundle 的构建见 [BUILDING.md](BUILDING.md)。

## 发布历史

每个 Release 都包含补丁集 bundle、完整对应源码与两个 SHA-256 文件。

| 补丁集 | 状态 | 说明 |
|---|---|---|
| [`0.80-runeon.6`](https://github.com/Codewave-Seki/runeon-dxmt/releases/tag/0.80-runeon.6) | Pre-release | 候选版本 |
| [`0.80-runeon.5`](https://github.com/Codewave-Seki/runeon-dxmt/releases/tag/0.80-runeon.5) | 正式版，最新 | 当前版本；在本仓库建立前已构建并分发 |

## 文档

- [BUILDING.md](BUILDING.md)：构建 DLL 与源码 bundle
- [MAINTENANCE.md](MAINTENANCE.md)：上游审查、补丁准入与发布策略
- [SECURITY.md](SECURITY.md)：报告安全问题
- [docs/upstream-reviews.md](docs/upstream-reviews.md)：审查记录

## 许可证

DXMT 在 `v0.80` 之后的上游 commit `ec357fd` 中把许可证从 MIT 改为 LGPL-2.1-or-later。本仓库中的回移修复与 Runeon 修改按 LGPL-2.1-or-later 授权，见 [`LICENSE`](LICENSE)。DXMT `v0.80` 时的代码仍可按其 MIT 许可证使用。上游 commit 保留原作者。本仓库不改变 Runeon App 的许可证。
