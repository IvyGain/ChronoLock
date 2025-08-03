# 🚀 ChronoLock Apple Watch アプリ - ビルド完全ガイド

## 📋 前提条件

### 必要な環境
```
✅ macOS 14.0 以降
✅ Xcode 15.0 以降 
✅ Apple Watch Series 6 以降（実機テスト用）
✅ Apple Developer Account（個人アカウント対応済み）
✅ iPhone（Apple Watchとペアリング用）
```

### Apple Developer Account 設定
```
1. Apple Developer Program への登録
   - 個人アカウント: 年額 $99
   - 法人アカウント: 年額 $99
   
2. Xcode での Apple ID 設定
   - Xcode → Preferences → Accounts
   - Apple ID を追加してサインイン
```

---

## 🔄 GitHubからプロジェクト取得

### 方法1: git clone（推奨）
```bash
# 1. 任意のディレクトリに移動
cd ~/Desktop

# 2. リポジトリをクローン
git clone https://github.com/IvyGain/ChronoLock.git

# 3. プロジェクトディレクトリに移動
cd ChronoLock

# 4. 最新状態を確認
git status
git log --oneline -5
```

### 方法2: ZIP ダウンロード
```
1. GitHub リポジトリページにアクセス
   https://github.com/IvyGain/ChronoLock

2. 緑色の "Code" ボタンをクリック

3. "Download ZIP" を選択

4. ダウンロードしたZIPファイルを解凍

5. 解凍したフォルダ名を "ChronoLock" に変更
```

### 方法3: GitHub Desktop
```
1. GitHub Desktop アプリを起動

2. File → Clone Repository

3. URL タブで入力:
   https://github.com/IvyGain/ChronoLock.git

4. ローカルパスを選択してクローン
```

---

## 🛠️ Xcode プロジェクト設定

### ステップ1: プロジェクトを開く
```bash
# ターミナルから開く
cd /path/to/ChronoLock
open ChronoLock.xcodeproj

# または Finder から
# ChronoLock.xcodeproj をダブルクリック
```

### ステップ2: 初回設定確認
```
1. Xcode が開いたら、プロジェクトナビゲーター（左側）を確認:

📁 ChronoLock
├── 📁 ChronoLock (iOS - 削除可能)
└── 📁 ChronoLock Watch App ← メインターゲット

2. 不要なiOSターゲットを削除:
   - プロジェクト設定 → TARGETS
   - "ChronoLock" (iOS) を選択
   - Delete キーまたは右クリック → Delete
```

### ステップ3: 開発チーム設定
```
1. プロジェクト設定画面で "ChronoLock Watch App" を選択

2. "Signing & Capabilities" タブをクリック

3. Team 設定:
   ┌─────────────────────────────────────┐
   │ Team: [あなたのApple Developer Account] │
   │ Bundle Identifier: com.chronolock.watchapp │
   │ Provisioning Profile: Automatic     │
   │ Signing Certificate: Automatic      │
   └─────────────────────────────────────┘

4. Bundle Identifier を一意に変更（必要に応じて）:
   例: com.yourname.chronolock.watchapp
```

### ステップ4: Capabilities 確認
```
"Signing & Capabilities" で以下が設定されていることを確認:

✅ HealthKit
   └── Read permissions: Heart Rate

✅ Location
   └── When In Use location access

❌ 以下は個人アカウントでは使用不可:
❌ App Groups
❌ Push Notifications
❌ iCloud
```

---

## 🏗️ ビルドプロセス

### ステップ1: 依存関係確認
```
1. Project Navigator で全ファイルが正常に読み込まれていることを確認
   - 赤色のファイル名がないこと
   - Missing files エラーがないこと

2. 必要に応じてファイルパスを修正
   - 赤色ファイルを右クリック → "Show in Finder"
   - 正しいファイルを選択し直す
```

### ステップ2: ビルド設定確認
```
1. Deployment Target 確認:
   - watchOS Deployment Target: 10.0

2. 言語設定確認:
   - Swift Language Version: Swift 5

3. アーキテクチャ確認:
   - Valid Architectures: arm64
```

### ステップ3: 初回ビルド
```bash
# Xcode で以下のショートカットを実行:

# 1. クリーンビルド
Command + Shift + K

# 2. ビルド実行
Command + B

# 期待される結果:
✅ Build Succeeded
❌ 0 Errors, 0 Warnings
```

### ステップ4: エラー対応（必要に応じて）

#### A. コンパイルエラー
```
よくあるエラーと解決策:

1. "Cannot find 'SomeClass' in scope"
   → import 文の確認
   → ファイルがターゲットに追加されているか確認

2. "Use of undeclared type"
   → Models フォルダのファイルが正しく追加されているか確認

3. "Module not found"
   → Framework のリンク確認
   → HealthKit, CoreLocation が追加されているか確認
```

#### B. プロビジョニングエラー
```
1. "Failed to create provisioning profile"
   解決策:
   - Xcode → Preferences → Accounts
   - "Download Manual Profiles" をクリック
   - 開発チームを再選択

2. "Signing for 'ChronoLock Watch App' requires a development team"
   解決策:
   - Team が正しく選択されているか確認
   - Bundle Identifier が一意であるか確認
```

---

## 📱 シミュレーター・実機テスト

### ステップ1: シミュレーターテスト
```
1. デバイス選択:
   Xcode ツールバー → デバイス選択
   ┌─────────────────────────────────┐
   │ ChronoLock Watch App           │
   │ ├── Apple Watch Series 9 (45mm) │ ← 選択
   │ ├── Apple Watch Ultra 2 (49mm)  │
   │ └── Add Additional Simulators... │
   └─────────────────────────────────┘

2. アプリ実行:
   Command + R

3. 期待される結果:
   ✅ Apple Watch Simulator が起動
   ✅ ChronoLock アプリが自動で開く
   ✅ メイン画面（タブビュー）が表示
   ✅ iOSアプリは起動しない（Watch単体）
```

### ステップ2: 基本機能テスト
```
シミュレーターで以下をテスト:

1. ナビゲーション:
   ✅ Digital Crown でタブ切り替え
   ✅ タップでの画面遷移

2. ロック解除:
   ✅ Pin Tumbler ロック操作
   ✅ Digital Crown 反応性
   ✅ ハプティックフィードバック

3. UI表示:
   ✅ 全画面の正常表示
   ✅ テキストの可読性
   ✅ アイコンの表示
```

### ステップ3: 実機テスト準備
```
実機テスト前の準備:

1. Apple Watch のペアリング確認:
   - iPhone の Watch アプリで接続状態確認
   - Apple Watch が最新の watchOS に更新

2. 開発者モードの有効化:
   Apple Watch で:
   Settings → Privacy & Security → Developer Mode → ON

3. デバイス選択:
   Xcode で "My Apple Watch" を選択

4. アプリのインストール:
   Command + R で実機にインストール・実行
```

---

## 🔧 トラブルシューティング

### よくある問題と解決策

#### 1. ビルドエラー
```bash
# 解決策A: クリーンビルド
Product → Clean Build Folder (Command + Shift + K)

# 解決策B: Derived Data 削除
rm -rf ~/Library/Developer/Xcode/DerivedData

# 解決策C: プロジェクトを閉じて再オープン
```

#### 2. シミュレーター問題
```
# Apple Watch Simulator リセット
Device → Erase All Content and Settings

# または
Hardware → Device → Manage Devices → Delete
```

#### 3. 実機接続問題
```
1. USB接続でiPhoneがMacに認識されているか確認
2. iPhone で "このコンピュータを信頼する" を選択
3. Apple Watch で開発者モードが有効か確認
4. Xcode の Devices & Simulators で Apple Watch が表示されるか確認
```

#### 4. 権限関連エラー
```
実機で権限エラーが発生した場合:

1. Apple Watch で:
   Settings → Privacy & Security → Location Services → ON
   Settings → Privacy & Security → Health → ON

2. iPhone で:
   Settings → Privacy & Security → Health → ChronoLock → All Categories → ON
```

---

## 📦 App Store 提出準備

### ステップ1: アーカイブ作成
```
1. デバイス選択:
   "Any watchOS Device (arm64)" を選択

2. アーカイブ実行:
   Product → Archive (Command + Shift + Option + K)

3. Organizer 画面で:
   - 作成されたアーカイブを確認
   - "Distribute App" をクリック
```

### ステップ2: App Store Connect 準備
```
1. App Store Connect にログイン:
   https://appstoreconnect.apple.com

2. 新しいアプリを作成:
   - Platform: watchOS
   - Bundle ID: com.chronolock.watchapp（または設定した値）
   - App Name: ChronoLock

3. アプリ情報を入力:
   - App Store Assets/Metadata/ フォルダの内容を参照
   - 説明文、キーワード、スクリーンショットを追加
```

### ステップ3: 最終チェック
```
提出前のチェックリスト:

□ アプリが正常にビルドできる
□ シミュレーターでの動作確認完了
□ 実機でのテスト完了
□ All Apple Watch サイズでの表示確認
□ HealthKit・Location 権限の正常動作
□ App Store Connect でのメタデータ入力完了
□ プライバシーポリシーのアップロード完了
□ アプリアイコンの設定完了
```

---

## 🎯 推定スケジュール

### 初回セットアップ: 1-2時間
```
□ GitHubからクローン: 10分
□ Xcode設定: 30分
□ 初回ビルド: 30分
□ 基本動作確認: 30分
```

### テスト・デバッグ: 2-4時間
```
□ シミュレーターテスト: 1時間
□ 実機テスト: 1-2時間
□ 各種デバイスサイズ確認: 1時間
```

### App Store 提出: 1-2時間
```
□ アーカイブ作成: 30分
□ App Store Connect 設定: 1時間
□ 最終レビュー・提出: 30分
```

### Apple レビュー期間: 1-7日
```
□ 平均レビュー期間: 1-3日
□ 追加情報要求の場合: +2-4日
```

---

## 🏆 成功指標

### ビルド成功の確認
```
✅ Xcode でエラーなしでビルド完了
✅ Apple Watch シミュレーターでアプリ起動
✅ 全機能が正常動作
✅ 実機での動作確認完了
```

### リリース準備完了の確認
```
✅ App Store Connect でアプリ情報入力完了
✅ アーカイブファイルのアップロード完了
✅ Apple レビューへの提出完了
✅ レビュー承認後の自動リリース設定完了
```

---

**🎉 このガイドに従えば、GitHubリポジトリから始めて App Store リリースまで完了できます！**

**⏱️ 総所要時間: 4-8時間（初回）、2-3時間（2回目以降）**