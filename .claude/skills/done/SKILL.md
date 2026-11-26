---
name: done
description: 收尾。推分支、以 bot 身分開 PR（base 是預設分支時 Closes #N，否則 Refs #N）、在 issue 留摘要與 PR 連結。用法：/done
---

> heeatw kit 注入的 skill（受管，要改請改 heeatw/docs 的 `kit/skills/`）。設計：heeatw/docs `team/docs-hub/`。
>
> 名詞：**KB** = heeatw/docs。在專案裡是 `.kb/`（指向 `../docs` 的連結；沒有就 `ln -s ../docs .kb`，`../docs` 不存在先 `gh repo clone heeatw/docs ../docs`），在 heeatw/docs 本身就是 repo 根目錄。**bot** = `<KB>/.scripts/ebifu <gh 子指令>`，以えびふ身分寫 GitHub（私鑰在鑰匙圈 `-a heeatw -s ebifu-app-key`，見 `<KB>/team/keychain/`）；沒有私鑰就用使用者的 gh，內文第一行註明「AI 代寫」。讀取用一般 `gh` 即可。
> 寫回 GitHub 的留言：繁體中文、第一行粗體一句結論、條列、程式碼位置寫 `path:行號`，結尾一行 `— 本機 Claude Code（分支 <branch>）`。
> **整合分支** = 遠端有 `dev` 就是 `dev`（功能併進 dev，main 由發版流程 fast-forward），沒有就是預設分支（通常 `main`）。判斷：`git ls-remote --exit-code --heads origin dev >/dev/null 2>&1; rc=$?; if [ $rc = 0 ]; then echo dev; elif [ $rc = 2 ]; then { git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || echo origin/main; } | sed "s#origin/##"; else echo "ls-remote 失敗 rc=$rc"; fi`（連不上遠端時停下來問，不要當成沒有 dev）。專案 AGENTS.md 對某類分支另訂起點或 base（例如 `server/` 直接對 main、`hotfix/` 從 main 切）時，以專案為準。

# /done

1. **檢查**：工作樹乾淨（沒 commit 的先問要不要 commit）；分支名含 issue 編號 N；`git log origin/<整合分支或專案規定的 base>..HEAD` 不是空的。專案有測試或 lint 就先跑，結果要寫進 PR。改到部署、設定、密鑰、操作流程卻沒動 `docs/runbook/`，先補；規劃定案或行為改了卻沒動 `docs/`，先補。
2. **推**：`git push -u origin <branch>`。
3. **PR**（用 bot）：`<KB>/.scripts/ebifu pr create --base <整合分支或專案規定的 base> --head <branch> --title "<issue 標題或更準的一句>" --body-file <檔>`。內文：

   ```
   > 本 PR 由 AI 依使用者指示在本機代寫。

   ## 做了什麼
   - …（對應 issue 裡的哪一點）

   ## 怎麼驗證
   - 跑了什麼、結果；跑不了的寫明

   ## 沒做 / 之後
   - …

   Closes #N          ← base 是預設分支才寫；base 是 dev 之類時改寫 Refs #N

   🤖 Generated with [Claude Code](https://claude.com/claude-code)
   ```
   **base 不是預設分支時（例如 `dev`）GitHub 不解讀關閉關鍵字**，之後 main fast-forward 也不會關：寫 `Refs #N`，issue 留言加一句「併進 dev；進 main 後請手動關」。
4. **issue 留言**（用 bot）：`**完成**：PR <url>。` 加兩三行摘要，結尾署名。
5. 告訴使用者：PR 連結、Actions 裡的えびふ幾分鐘後會留 review、merge 由他決定。不要自己 merge。
