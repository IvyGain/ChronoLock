# 🎯 Xcode 初心者向け - ChronoLock ビルド詳細ガイド

## 📚 Xcode 基礎知識

### Xcode の画面構成
```
┌─────────────────────────────────────────────────────────────┐
│ 🍎 Xcode メニューバー                                        │
├─────────────────────────────────────────────────────────────┤
│ ▶️ ツールバー [実行] [停止] [デバイス選択] [ターゲット選択]     │
├─────────────────────────────────────────────────────────────┤
│ 📁 Navigator │           📝 Editor Area          │ 🔧 Inspector│
│ (左側)       │                                  │ (右側)     │
│ - Project    │  ここにコードや設定画面が表示される  │ - File     │
│ - Search     │                                  │ - Quick    │
│ - Issues     │                                  │ - Identity │
│ - Debug      │                                  │ - Attributes│
│ - Breakpoint │                                  │            │
│ - Report     │                                  │            │
└──────────────┴──────────────────────────────────┴────────────┘
```

### 重要なショートカット
```
🏗️ ビルド関連:
Command + B      = ビルド実行
Command + R      = アプリ実行
Command + .      = 実行停止
Command + Shift + K = クリーンビルド

📁 ナビゲーション:
Command + 1      = Project Navigator
Command + 2      = Source Control Navigator
Command + 0      = Navigator 表示/非表示
Command + Option + 0 = Inspector 表示/非表示

🔍 検索:
Command + F      = ファイル内検索
Command + Shift + F = プロジェクト全体検索
```

---

## 🚀 ステップバイステップ操作手順

### Phase 1: プロジェクトの取得と起動

#### ステップ1-1: GitHubからダウンロード
```
📖 手順:
1. ブラウザで以下にアクセス:
   https://github.com/IvyGain/ChronoLock

2. 緑色の "Code" ボタンをクリック
   ┌─────────────────┐
   │ 📋 Code ▼      │
   │ ├─ 📋 Clone     │
   │ ├─ 📦 Download ZIP │ ← これをクリック
   │ └─ 🌐 GitHub CLI │
   └─────────────────┘

3. ZIP ファイルがダウンロードされる
   ダウンロード先: ~/Downloads/ChronoLock-main.zip

4. ZIP ファイルをダブルクリックして解凍
   解凍先: ~/Downloads/ChronoLock-main/

5. フォルダ名を変更:
   "ChronoLock-main" → "ChronoLock"

6. 作業しやすい場所に移動:
   例: ~/Desktop/ChronoLock
```

#### ステップ1-2: Xcode でプロジェクトを開く
```
📖 手順:
1. Finder で ChronoLock フォルダを開く

2. "ChronoLock.xcodeproj" ファイルを探す
   アイコン: 🔨 (ハンマーマーク)

3. ChronoLock.xcodeproj をダブルクリック
   → Xcode が自動で起動

4. 初回起動時の確認:
   ✅ Xcode が正常に開く
   ✅ プロジェクトファイルが読み込まれる
   ✅ 左側にファイル一覧が表示される
```

### Phase 2: プロジェクト設定の確認・修正

#### ステップ2-1: ターゲット設定確認
```
📖 手順:
1. 左側の Project Navigator で最上位の "ChronoLock" をクリック
   📁 ChronoLock ← これをクリック

2. 中央の画面で TARGETS セクションを確認:
   ┌─────────────────────────────┐
   │ TARGETS                     │
   │ ✅ ChronoLock Watch App     │ ← メイン
   │ ❌ ChronoLock (削除推奨)     │ ← iOS版（不要）
   └─────────────────────────────┘

3. 不要なiOSターゲットを削除:
   - "ChronoLock" (iOS版) を選択
   - Delete キーを押す
   - 確認ダイアログで "Move to Trash" をクリック
```

#### ステップ2-2: 開発チーム設定
```
📖 手順:
1. "ChronoLock Watch App" ターゲットを選択

2. 上部タブで "Signing & Capabilities" をクリック

3. Team 設定を変更:
   ┌─────────────────────────────────────┐
   │ Team: [None (Add Team...)]          │ ← クリック
   │ ├─ Add an Account...                │
   │ └─ [あなたのApple ID]               │ ← 選択
   └─────────────────────────────────────┘

4. Bundle Identifier を確認・変更:
   現在: com.chronolock.watchapp
   変更例: com.yourname.chronolock
   
   ⚠️ 注意: 世界で一意である必要があります
```

#### ステップ2-3: Apple ID アカウント追加（必要に応じて）
```
📖 手順:
1. Xcode メニューバー:
   Xcode → Preferences... → Accounts

2. 左下の "+" ボタンをクリック
   → "Apple ID" を選択

3. Apple ID とパスワードを入力
   - 開発者アカウントまたは通常のApple ID

4. "Sign In" をクリック

5. アカウントが追加されたことを確認
   Teams 欄に表示される個人チーム名を確認
```

### Phase 3: 初回ビルドテスト

#### ステップ3-1: デバイス選択
```
📖 手順:
1. Xcode ツールバーの左側を確認:
   ┌─────────────────────────────────┐
   │ ▶️ ChronoLock Watch App         │
   │   └─ iPhone 15 Pro             │ ← ここをクリック
   └─────────────────────────────────┘

2. デバイス選択メニューで Apple Watch を選択:
   ┌─────────────────────────────────┐
   │ watchOS Simulators              │
   │ ├─ Apple Watch Series 9 (45mm)  │ ← これを選択
   │ ├─ Apple Watch Ultra 2 (49mm)   │
   │ └─ Add Additional Simulators... │
   └─────────────────────────────────┘

3. 選択後のツールバー表示:
   ┌─────────────────────────────────┐
   │ ▶️ ChronoLock Watch App         │
   │   └─ Apple Watch Series 9       │ ← 正しく表示
   └─────────────────────────────────┘
```

#### ステップ3-2: 初回ビルド実行
```
📖 手順:
1. クリーンビルドを実行:
   メニューバー: Product → Clean Build Folder
   ショートカット: Command + Shift + K

2. ビルドを実行:
   メニューバー: Product → Build
   ショートカット: Command + B

3. ビルド結果の確認:
   ✅ 成功時: "Build Succeeded" がステータスに表示
   ❌ 失敗時: エラーが Issues Navigator に表示

4. エラーが発生した場合:
   - 左側 Navigator で ⚠️ Issues をクリック
   - エラー内容を確認
   - 下記のトラブルシューティングを参照
```

### Phase 4: アプリの実行・テスト

#### ステップ4-1: シミュレーターでの実行
```
📖 手順:
1. アプリを実行:
   ツールバーの ▶️ ボタンをクリック
   または Command + R

2. Apple Watch Simulator が起動:
   ┌─────────────────┐
   │ 🕐 Apple Watch   │
   │  Simulator      │
   │                 │
   │    ChronoLock   │ ← アプリアイコン
   │      アプリ      │
   └─────────────────┘

3. アプリが自動で開いて動作確認:
   ✅ メイン画面（タブビュー）が表示
   ✅ Digital Crown でナビゲーション
   ✅ タップでの画面遷移

4. 基本機能テスト:
   - Inventory タブでチェスト一覧確認
   - 最初のチェストをタップ
   - Pin Tumbler ロック画面で Digital Crown テスト
```

#### ステップ4-2: シミュレーター操作方法
```
📖 Apple Watch Simulator の使い方:

🖱️ マウス操作:
- クリック = タップ
- ドラッグ = スワイプ
- スクロール = Digital Crown

⌨️ キーボードショートカット:
Hardware → Rotate Left/Right = Digital Crown
Command + Shift + H = ホームボタン
Device → Shake = 振動シミュレーション

🔧 設定メニュー:
Device → Appearance → Light/Dark = 外観切り替え
Device → Orientation = 画面回転
Window → Scale = 画面サイズ調整
```

### Phase 5: 実機テスト（Apple Watch 接続時）

#### ステップ5-1: Apple Watch の準備
```
📖 手順:
1. iPhone と Apple Watch のペアリング確認:
   iPhone の Watch アプリで接続状態確認

2. Apple Watch で開発者モードを有効化:
   Settings → Privacy & Security → Developer Mode → ON
   ⚠️ 再起動が必要な場合があります

3. iPhone を Mac に USB 接続:
   "このコンピュータを信頼しますか？" → "信頼"

4. Xcode でデバイスを確認:
   Window → Devices and Simulators
   左側に "My Apple Watch" が表示されることを確認
```

#### ステップ5-2: 実機での実行
```
📖 手順:
1. デバイス選択を変更:
   ツールバーで "My Apple Watch" を選択

2. アプリを実行:
   Command + R

3. 初回実行時の手順:
   - 開発者証明書の確認ダイアログが表示
   - Apple Watch にアプリがインストールされる
   - 自動でアプリが起動

4. 権限確認:
   - HealthKit へのアクセス許可
   - Location Services へのアクセス許可
   - 必要に応じて許可を選択

5. 実機での動作確認:
   - ハプティックフィードバック（振動）
   - ハートレート監視（Cursed Chest）
   - 位置情報連動機能
```

---

## 🚨 トラブルシューティング

### よくあるエラーと解決策

#### エラー1: "No such module 'HealthKit'"
```
🔧 解決策:
1. Project Settings → ChronoLock Watch App → Build Phases
2. "Link Binary With Libraries" を展開
3. "+" ボタンをクリック
4. "HealthKit.framework" を検索して追加
5. 同様に "CoreLocation.framework" も追加
```

#### エラー2: "Failed to create provisioning profile"
```
🔧 解決策:
1. Bundle Identifier を変更:
   com.chronolock.watchapp → com.yourname.uniquename

2. Team を再選択:
   Signing & Capabilities → Team → [あなたのアカウント]

3. "Automatically manage signing" にチェック

4. 再ビルド: Command + Shift + K → Command + B
```

#### エラー3: "Cannot find 'MainView' in scope"
```
🔧 解決策:
1. ファイルの追加確認:
   Project Navigator で MainView.swift が存在するか確認

2. Target への追加確認:
   MainView.swift を選択 → File Inspector → Target Membership
   "ChronoLock Watch App" にチェック

3. import 文の確認:
   ChronoLockWatchApp.swift の先頭に "import SwiftUI"
```

#### エラー4: Apple Watch Simulator が起動しない
```
🔧 解決策:
1. Simulator をリセット:
   Device → Erase All Content and Settings

2. 別のシミュレーターを試す:
   Apple Watch Ultra 2 など

3. Xcode を再起動:
   完全終了 → 再起動

4. macOS を再起動（最終手段）
```

#### エラー5: 実機で "App installation failed"
```
🔧 解決策:
1. Apple Watch の容量確認:
   十分な空き容量があることを確認

2. ペアリングの確認:
   iPhone の Watch アプリで接続状態確認

3. 開発者モードの確認:
   Apple Watch で Developer Mode が ON

4. 証明書の更新:
   Xcode → Preferences → Accounts → Download Manual Profiles
```

---

## 📊 進捗チェックリスト

### 初期設定（30分）
- [ ] GitHubからプロジェクトダウンロード
- [ ] Xcode でプロジェクトオープン
- [ ] Apple ID アカウント追加
- [ ] 開発チーム設定
- [ ] Bundle Identifier 設定

### ビルド確認（15分）
- [ ] クリーンビルド成功
- [ ] エラーゼロでビルド完了
- [ ] デバイス選択でApple Watch表示
- [ ] ターゲットが Watch App のみ

### シミュレーターテスト（30分）
- [ ] Apple Watch Simulator でアプリ起動
- [ ] メイン画面表示確認
- [ ] タブナビゲーション動作
- [ ] ロック解除機能動作
- [ ] Digital Crown 操作確認

### 実機テスト（30分、Apple Watch必要）
- [ ] 実機でアプリインストール成功
- [ ] HealthKit 権限許可
- [ ] Location Services 権限許可
- [ ] ハプティックフィードバック確認
- [ ] 全機能の動作確認

### 最終確認（15分）
- [ ] アプリが完全にwatchOS単体で動作
- [ ] iOSアプリが起動しない
- [ ] データの保存・読み込み正常
- [ ] パフォーマンス問題なし

---

## 🎯 次のステップ

### Phase 6: App Store 提出準備
1. **アーカイブ作成**: Product → Archive
2. **App Store Connect 設定**: アプリ情報入力
3. **スクリーンショット準備**: 各 Apple Watch サイズ
4. **メタデータ入力**: 説明文、キーワード等
5. **レビュー提出**: 最終チェック後提出

### 推定時間
- **初回セットアップ**: 1-2時間
- **テスト・デバッグ**: 2-3時間
- **App Store提出**: 1-2時間
- **Appleレビュー**: 1-7日

---

**🏆 このガイドを順番に実行すれば、Xcode初心者でもChronoLockアプリをビルド・実行できます！**

**💡 わからないことがあれば、各セクションを再確認するか、Apple の公式ドキュメントを参照してください。**