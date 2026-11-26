---
name: issue
description: 開工。讀 issue #N 與全部留言進 context，開 <prefix>/N-<主題> 分支，在 issue 留一句開工。用法：/issue 20
---

> heeatw kit 注入的 skill（受管，要改請改 heeatw/docs 的 `kit/skills/`）。設計：heeatw/docs `team/docs-hub/`。
>
> 名詞：**KB** = heeatw/docs。在專案裡是 `.kb/`（指向 `../docs` 的連結；沒有就 `ln -s ../docs .kb`，`../docs` 不存在先 `gh repo clone heeatw/docs ../docs`），在 heeatw/docs 本身就是 repo 根目錄。**bot** = `<KB>/.scripts/ebifu <gh 子指令>`，以えびふ身分寫 GitHub（私鑰在鑰匙圈 `-a heeatw -s ebifu-app-key`，見 `<KB>/team/keychain/`）；沒有私鑰就用使用者的 gh，內文第一行註明「AI 代寫」。讀取用一般 `gh` 即可。
> 寫回 GitHub 的留言：繁體中文、第一行粗體一句結論、條列、程式碼位置寫 `path:行號`，結尾一行 `— 本機 Claude Code（分支 <branch>）`。
> **整合分支** = 遠端有 `dev` 就是 `dev`（功能併進 dev，main 由發版流程 fast-forward），沒有就是預設分支（通常 `main`）。判斷：`git ls-remote --exit-code --heads origin dev >/dev/null 2>&1; rc=$?; if [ $rc = 0 ]; then echo dev; elif [ $rc = 2 ]; then { git symbolic-ref --short refs/remotes/origin/HEAD 2>/dev/null || echo origin/main; } | sed "s#origin/##"; else echo "ls-remote 失敗 rc=$rc"; fi`（連不上遠端時停下來問，不要當成沒有 dev）。專案 AGENTS.md 對某類分支另訂起點或 base（例如 `server/` 直接對 main、`hotfix/` 從 main 切）時，以專案為準。

# /issue $ARGUMENTS

1. **讀**：`gh issue view N --json title,body,labels,comments,url`。把討論串裡的決定整理成：要做什麼、已決定什麼、還沒決定什麼。issue 若在別的 repo，用 `-R` 讀。
2. **分支**：`git fetch -q origin`，從 `origin/<整合分支>` 開 `feat/N-<英文-kebab-主題>`；專案 AGENTS.md 若規定別的前綴（`server/`、`fix/`）或該前綴另有起點照它。分支已存在就切過去並 `git pull --ff-only`。
3. **留言**（用 bot）：

   ```
   **開工**：分支 `feat/N-<主題>`。
   - 理解：一兩句，做什麼、不做什麼
   - 假設：從討論串拿來、但沒有明說的事（沒有就省略）
   — 本機 Claude Code（分支 feat/N-<主題>）
   ```
4. **先對齊再動手**：把你的理解、計畫（三到五步）、要問的問題講給使用者，等他說開始。規劃類的 issue，產出寫進 `docs/specs/`（一個主題一個檔，frontmatter 齊全），定案後才實作。
5. 做完用 `/done`。
