---
title: cft Runbook
description: cft 的操作手冊：怎麼跑、怎麼部署、出事怎麼查
tags: [runbook]
status: 草稿
date: 2026-11-26
project: cft
---

> 這份 runbook 由 heeatw/docs 的 kit 注入骨架，由人在本機用 Claude Code 維護。改程式若影響部署、設定或操作流程，同一個 PR 更新這裡；Actions 裡的えびふ會在 PR 檢查時提醒。
> 所有專案的文件目錄：https://github.com/heeatw/docs/blob/main/INDEX.md

## 這是什麼

<!-- 一段話說明專案目的、服務對象、對外的入口（網址、App、API）。 -->

## 章節

- [本機怎麼跑](01-local-dev.md)
- [部署與回滾](02-deploy.md)
- [環境與密鑰在哪](03-secrets.md)
- [監控與常見故障](04-monitoring.md)
- [相關專案與共用知識](05-related.md)

## 如何更新這份 runbook

- 直接改這個資料夾的檔案，走一般 PR；Actions 裡的えびふ會檢查。
- 程式碼變動影響部署、設定或操作流程時，請在同一個 PR 更新對應章節。
- 兩個以上專案都用得到的知識，寫到 heeatw/docs 的 `notes/`。
