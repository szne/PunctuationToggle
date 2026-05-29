# PunctuationToggle

macOS のメニューバーに常駐し、日本語 IME の句読点スタイルをワンクリックで切り替えるアプリです。

## 機能

- **メニューバー常駐** — Dock には表示されません
- **左クリックでトグル** — 設定したモードを順番に切り替えます
- **右クリックメニュー** — 手動切り替え・設定画面の表示・終了
- **設定画面** — 切り替えるモードをチェックボックスで自由に選択
- **ログイン時に自動起動** — 設定画面から ON/OFF 可能

### 切り替えられるモード

| 表示 | 読点 | 句点 |
|------|------|------|
| 、。 | 、   | 。   |
| ，。 | ，   | 。   |
| 、． | 、   | ．   |
| ，． | ，   | ．   |

デフォルトは **、。** と **，．** の 2 モード切り替えです。

## 動作環境

- macOS 13 Ventura 以降
- Apple Silicon（arm64）

## インストール

### リリース版をダウンロード（推奨）

1. [Releases](https://github.com/szne/PunctuationToggle/releases) から最新の `PunctuationToggle.app.zip` をダウンロード
2. 解凍して `.app` を `/Applications` などに移動
3. ダブルクリックで起動
   - 初回起動時に Gatekeeper の警告が出る場合は **右クリック → 「開く」** を選択

### ソースからビルド

```bash
git clone https://github.com/szne/PunctuationToggle.git
cd PunctuationToggle
open PunctuationToggle.xcodeproj
```

Xcode で **Product → Run**（⌘R）を実行してください。

## 使い方

### 基本操作

| 操作 | 動作 |
|------|------|
| 左クリック | 次のモードへ切り替え |
| 右クリック | コンテキストメニューを表示 |

### 設定画面

右クリック → **「設定...」** で設定ウィンドウが開きます。

- **モード選択** — トグル対象にするモードをチェック（最低 2 つ必要）
- **切替順プレビュー** — 選択したモードの切り替え順を確認
- **ログイン時に自動起動** — macOS ログイン時に自動で起動するか設定

## 技術的な詳細

句読点の切り替えは以下のコマンドを内部で実行しています。

```bash
# 設定の書き込み（JIMPrefPunctuationTypeKey はビットマスク）
#   bit0 = 読点 (0=、 1=，)
#   bit1 = 句点 (0=。 1=．)
defaults write com.apple.inputmethod.Kotoeri JIMPrefPunctuationTypeKey -int <0|1|2|3>

# IME に設定を再読み込みさせる
killall -HUP -m "JapaneseIM.*"
```

現在のモードは `UserDefaults` に保存され、次回起動時に復元されます。

## ライセンス

MIT License
