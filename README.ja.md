# Runeon DXMT

[English](README.md) | [Chinese](README.zh-CN.md) | [Japanese](README.ja.md)

> 英語版が正式な文書です。中国語版と日本語版は参照用の完全な翻訳です。

Runeon DXMT は、Runeon が配布する DXMT コンポーネントの公開ソース保守リポジトリです。固定された [DXMT](https://github.com/3Shain/dxmt) のタグ、そこへバックポートしたアップストリームの修正、Runeon 独自の変更、そして配布したすべてのコンポーネントに正確に対応するソースを再構築するスクリプトを収めています。広範な互換性を約束するものではなく、Runeon App、Steam、ゲーム、Apple の非公開グラフィックスコンポーネントは含みません。

## ベースラインと現在のリリース

- アップストリーム：DXMT `v0.80`（`589adb7`）と固定された submodule。[`base/dxmt-0.80.json`](base/dxmt-0.80.json) を参照
- 現在の正式ソース：[`0.80-runeon.5`](https://github.com/Codewave-Seki/runeon-dxmt/releases/tag/0.80-runeon.5)：アップストリームの修正 23 件と Runeon の変更 3 件。定義は [`patchsets/0.80-runeon.5`](patchsets/0.80-runeon.5/manifest.json)
- アップストリームのレビュー記録：[MAINTENANCE.md](MAINTENANCE.md#review-records)

## リポジトリ構成

| パス | 内容 |
|---|---|
| `base/` | 固定したアップストリームのリポジトリ、タグ、コミット、submodule のコミット |
| `patchsets/<id>/` | 1 つのパッチセットの `series` と `manifest.json`。スクリプトは既定で最新のものを使い、`RUNEON_DXMT_PATCHSET_DEFINITION=patchsets/<id>` で別のものを選べます |
| `patches/upstream/`、`patches/runeon/` | アップストリーム DXMT のバックポートと Runeon の変更。1 ファイルにつき 1 コミット |
| `scripts/` | 取得、適用、検査、バンドル作成のスクリプト |
| `docs/` | アップストリームのレビュー記録（英語） |

## 範囲と境界

- DXMT のソースツリー、ビルド成果物、コンポーネントのアーカイブ、prefix、ユーザーデータ、診断情報はコミットしません。
- `D3DMetal.framework`、`libd3dshared.dylib`、GPTK の非公開オーバーレイは、ダウンロード、ミラー、配布のいずれも行いません。
- きれいに適用できるだけではアップストリームのコミットをパッチセットに入れません。すべてのコミットを先にレビューします。
- Runeon の変更は、ゲーム名、Steam AppID、実行ファイル名で照合することはありません。
- Production に配布したすべてのコンポーネントには、正確なパッチセットのバンドル、完全な対応ソース、SHA-256 ファイルを含む不変の正式 Release を用意します。候補は Pre-release のままにします。タグと Release のアセットは移動、置換、削除しません。
- コンポーネントのパッケージ化、署名、配布は Runeon の製品リポジトリが行います。

## 検証とビルド

```bash
scripts/static-check.sh
source_root="$(scripts/fetch-source.sh)"
scripts/integration-check.sh "$source_root"
```

`integration-check.sh` は、固定タグの一時 worktree に `git am` で各パッチを順に適用し、結果が manifest に記録された tree と一致することを確認します。DLL と Release バンドルのビルドは [BUILDING.md](BUILDING.md) を参照してください。

## リリース履歴

各 Release には、パッチセットのバンドル、完全な対応ソース、2 つの SHA-256 ファイルが含まれます。

| パッチセット | 状態 | 説明 |
|---|---|---|
| [`0.80-runeon.5`](https://github.com/Codewave-Seki/runeon-dxmt/releases/tag/0.80-runeon.5) | 正式版、最新 | 現行版。本リポジトリの作成前にビルド・配布済み |

## ドキュメント

- [BUILDING.md](BUILDING.md)：DLL とソースバンドルのビルド
- [MAINTENANCE.md](MAINTENANCE.md)：アップストリームのレビュー、パッチの受け入れ基準、リリース方針
- [SECURITY.md](SECURITY.md)：セキュリティ問題の報告
- [docs/upstream-reviews.md](docs/upstream-reviews.md)：レビュー記録

## ライセンス

DXMT は `v0.80` の後、アップストリームのコミット `ec357fd` でライセンスを MIT から LGPL-2.1-or-later に変更しました。本リポジトリのバックポートした修正と Runeon の変更は LGPL-2.1-or-later でライセンスされます。[`LICENSE`](LICENSE) を参照してください。DXMT `v0.80` 時点のコードは引き続き MIT ライセンスで利用できます。アップストリームのコミットは元の作者を保持します。本リポジトリは Runeon App のライセンスを変更しません。
