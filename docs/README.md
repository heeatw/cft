---
title: cft 文件入口
description: cft 的文件地圖：這是什麼、怎麼跑、怎麼部署、規劃與決策在哪
tags: [docs, index]
status: 草稿
date: 2026-11-26
project: cft
---

# cft 文件

<!-- 一段話：這個專案做什麼、服務誰、對外入口（網址、App、API）。 -->

| 我想要 | 看這裡 |
|---|---|
| 只要指令：本機怎麼跑、部署回滾、密鑰在哪、掛了怎麼查 | [runbook/](runbook/README.md) |
| 規劃、架構決策、為什麼這樣做 | [specs/](specs/README.md) |

- 文件跟程式同一個 PR 改：改了部署、設定、操作流程就改 runbook；規劃定案或行為改了就改 specs 或對應的文件。
- 這個資料夾會自動鏡射到 [heeatw/docs](https://github.com/heeatw/docs) 的 `projects/cft/`（只到 main），其他專案的文件也在那裡；正本永遠是這裡。
