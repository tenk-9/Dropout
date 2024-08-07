# DropOut
コンピュータグラフィックス（TMU/SD/CS, L0149）の最終課題として制作したゲームのリポジトリです．

[![demo movie](https://img.youtube.com/vi/zZtItorBEQY/0.jpg)](https://www.youtube.com/watch?v=zZtItorBEQY)

## コンセプト
板を操作して，画面外から落ちてくるアイテムをできるだけ多く集めるゲームです．

大学生における単位と学生の関係性にインスピレーションを受けています．アイテムは単位を，操作する板は学生の象徴です．DropOutのタイトルもここからきています．
- アイテム
  - アイテムには`1`から`5`の重さがあり，実際に獲得するまで重さは分かりません．
  - ある程度ランダムな高さから，ランダムな重さをもって自由落下してきます．
  - まるで単位みたいですね．
- 板（プレイヤー）
  - 板は獲得したアイテムの重さ分だけ質量が増し，動きづらくなります．
  - まるで履修単位数が多いために各授業の勉強が疎かになる学生のようです．
- 得点
  - 最終的な得点は，`取得したアイテムの総重量 / アイテムの総数`で計算されます．
  - 理論上の最高点は`5.0`です．`4.0`ではありません．ゲームバランスのため，意図的に違えています．

## 操作方法
### 移動
`w`, `a`,`s`, `d`で移動します．板に対して，キーと対応した方向に力を加えます．同時入力にも対応しています．
- `w`: 上方向
- `a`: 左方向
- `s`: 下方向
- `d`: 右方向
### リスタート
`r`キーを押すとポーズ画面になり，リスタートするか否かを選択できます．
- `y`: リスタートします
  - 得点等がリセットされ，初めからゲームが始まります．
- `n`: リスタートしません
  - ポーズが解除され，続きの状態からスタートします．

## あそびかた
### 手軽に
1. リポジトリをクローンします．
2. 自分の環境に合致したディレクトリを選択します．
     - `linux-aarch64`
     - `linux-amd64`
     - `linux-arm`
     - `windows-amd64`
3. 選択したディレクトリ内の実行ファイルを起動します．
     - `windows-amd64`環境の場合，[OpenSDK 17](https://adoptium.net/temurin/archive/?version=17)のインストールが必要です．
4. Enjoy ;)

### Processing4を持っている場合
Processing経由で起動することもできます．
1. リポジトリをクローンします．
2. `Dropout.pde`をProcessing4で開きます．
3. `ツール`タブから`フォント作成`を選択します．
4. `Consoals`を選択し，サイズを`100`として`OK`を押下します．
5. `data`ディレクトリに`Consolas-100.vlw`ができていることを確認します．
6. Processing4の左上の▶をクリックします．

## 特徴
### 物理演算
ゲーム内のオブジェクト（アイテム，板）の挙動は物理現象を再現しています．
#### アイテム
- 自由落下を再現しています．
  - 重力加速度はゲームバランスが最適となるよう，現実とは意図的に違えています．
- 空気抵抗が再現されています．
  - 速度の向きと反対に，その大きさに比例する力がかかると仮定しています．
  - $` \textbf{F}_{resist} = -k\textbf{v} `$
- 落下地点には現在の高さに応じて予測円が現れます．
  - ゲーム性向上のためです．
  - 高さが低いほど半径は小さく，色は赤くなります．
#### 板
- 力の作用を再現しています．
  - キー入力に応じて，物体に対して力を加えます．
  - $` \textbf{a} = \textbf{F}/m `$
  - $` \textbf{x}\prime = \textbf{v}\delta t + (\textbf{a}/2)\delta t^2 `$
  - $` \textbf{v}\prime = \textbf{v} + \textbf{a} \delta t `$
- アイテムの取得に応じて質量が変化します．
  - アイテムを取ればそれだけ動きが鈍くなります．
#### 衝突判定
- アイテムの中心と板の領域で判断します．
  - アイテムの中心座標が板のx-y-z領域に含まれていれば衝突したとみなします．
  - 衝突した場合，アイテムを獲得できます．