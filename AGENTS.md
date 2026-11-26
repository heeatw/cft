# AGENTS.md

給在這個專案工作的 AI agent 看的規範。

<!-- heeatw-kit:start v24 — 由 heeatw/docs 自動維護，請勿手改此區塊；要改請改 heeatw/docs 的 kit/AGENTS.kit.md -->
## heeatw 共同規則

專案自己的規則與這段衝突時，以專案的為準。設計說明：heeatw/docs `team/docs-hub/`。

- 用繁體中文（台灣用語）跟使用者對話與寫文件；程式碼、指令、識別字、commit 訊息保留英文。先討論再實作：功能先寫成規格與待決問題，不要自己假設後直接做。文件、issue／PR 留言、回覆都**先寫結論**，背景放後面或不寫，不重述 diff。
- **這個專案的一切都在這個 repo**：issue 開在這裡；程式、開發文件、規劃與決策（`docs/specs/`）、操作手冊（`docs/runbook/`）都在這裡。文件入口 `docs/README.md`。改程式若影響部署、設定或操作流程，同一個 PR 更新 runbook；規劃定案後實作，實作細節回寫 `docs/`。文件開頭放 frontmatter（`title`、`description`、`tags`、`status`、`date`）。
- **heeatw/docs 是唯讀的彙整**：每個專案 main 的 `docs/` 會自動鏡射到那裡的 `projects/<repo>/`，加上跨專案的 `notes/`、團隊規範 `team/`，`INDEX.md` 是總目錄。要查「別的專案有沒有做過類似的事」就看那裡，不要在那裡改專案文件（會被覆蓋）。本機 `.kb` 是指向它的連結：沒有就 `ln -s ../docs .kb`（`../docs` 不存在就先 `gh repo clone heeatw/docs ../docs`）；在 GitHub Actions 裡它已 checkout 到 `.kb/`。用 `grep -r`／`find` 搜程式碼時排除 `.kb`。
- **分支與 PR**：主分支 `main`，只開 PR。整合分支：遠端有 `dev` 就以 `dev` 為整合分支（功能分支從 dev 開、PR 以 dev 為 base，main 只由發版流程 fast-forward），沒有就是 `main`；專案對某類分支另訂起點（例如 `server/` 直接對 main）時以專案為準。做 issue 的分支帶編號：`feat/<編號>-<主題>`；沒有 issue 的小改動（typo）可以不帶。PR 內文寫 `Closes #<編號>`：只有 base 是預設分支時 GitHub 才會關 issue，base 是 `dev` 時改寫 `Refs #<編號>`、進 main 後手動關。
- **替使用者建 issue、PR、留言時用 bot 身分**：`.kb/.scripts/ebifu <gh 子指令>`（私鑰在 macOS 鑰匙圈 `-a heeatw -s ebifu-app-key`，清單與規則見 heeatw/docs `team/keychain/`；沒有才退回檔案 `ebifu.pem`／`$EBIFU_KEY`，不進 git）。沒有私鑰時用使用者的 gh，內文第一行註明是 AI 代寫。commit 維持使用者作者加 `Co-Authored-By`。
- **模型分工**：規劃、寫規格（`docs/specs/`）、設計與審查用 **Fable**，Fable 絕不實作；實作交給 **Opus 子代理**（一期一個 session，在指定分支的 worktree 裡 commit，不推送、不發版、不自己合併，做完回報給主對話收尾）。審查看證據（gate 的 `diff.md`、截圖、測試輸出）不看 diff；規則與理由見 heeatw/docs `team/local-first-workflow/`。
- **後台介面**：改內部後台的介面（版面、配色、導覽、元件庫）先看 heeatw/docs `team/admin-ui-design/`：token 預設 Polaris、每個後台要有深色、金額 `tabular-nums` 靠右、大改前先出 2～3 個方向的 mockup（桌面＋手機）給負責人挑再寫規格再動程式、PR 附 1440／390 截圖。**不加說明文字，先改設計**：預設狀態不放「這是什麼／怎麼操作」，字只走空狀態、欄位 hint（一行、只放格式或例子）、ⓘ popover（admin-ui-design §4）。
- **本機指令**（`.claude/skills/`，kit 注入）：`/issue N` 開工（讀 issue、開分支、留一句開工）；`/done` 收尾（推分支、以 bot 開 PR、issue 留摘要）；`/kb-ask 問題` 查本專案文件、程式與 heeatw/docs 回答並附依據。
- **GitHub Actions 裡的えびふ（bot，GitHub 帳號 `ebifu`）是唯讀的**，只做三件事：PR 建立時留一則 review（有會壞的地方會說「要先修」；之後 push 不自動重審，要重看就在 PR 留言 `@ebifu`）；issue 內文或留言寫 `@ebifu …` 它回一則一起討論，沒寫就什麼都不做；オムレツ（`heomuretsu[bot]`）依 Sentry 警報開的 issue，它做一輪唯讀分析（雜訊或真問題、位置、整合分支修了沒、建議計畫），留一則並加一個 `sentry:*` 標籤（專案可放 `docs/dev/sentry.md` 給提示）。它不改檔、不開 PR、不 merge；要動手就是本機 `/issue N`。
<!-- heeatw-kit:end -->
