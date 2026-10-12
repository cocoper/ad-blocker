# Domain Docs

本仓库的域文档布局在初始化时与用户确认为：**single-context** —— 一个仓库共用一份根目录的 `CONTEXT.md`，
架构决定放 `docs/adr/`。本次初始化不创建 `CONTEXT-MAP.md`，也不创建任何子项目的 `CONTEXT.md`；
它们留到第一次真正写下词条或决定时再建（由 `/domain-modeling` 惰性创建）。

How the engineering skills should consume this repo's domain documentation when exploring the codebase.

## Before exploring, read these

- **`CONTEXT.md`** at the repo root（本仓库为 single-context，没有 per-context 的 `CONTEXT.md`）。
- 本仓库不使用 `CONTEXT-MAP.md`：它是 multi-context 布局的指针文件，与上面那份结论互斥。
- **`docs/adr/`** — 读与你即将动手的区域相关的 ADR。本仓库为 single-context，不存在
  `src/<context>/docs/adr/` 这一层。

If any of these files don't exist, **proceed silently**. Don't flag their absence; don't suggest creating them
upfront. The `/domain-modeling` skill (reached via `/grill-with-docs` and `/improve-codebase-architecture`)
creates them lazily when terms or decisions actually get resolved.

## File structure

Single-context repo（本仓库）：

```
/
├── CONTEXT.md
├── docs/adr/
│   ├── 0001-event-sourced-orders.md
│   └── 0002-postgres-for-write-model.md
└── src/
```

Multi-context repo（presence of `CONTEXT-MAP.md` at the root）—— 本仓库不采用：

```
/
├── CONTEXT-MAP.md
├── docs/adr/                          ← system-wide decisions
└── src/
    ├── ordering/
    │   ├── CONTEXT.md
    │   └── docs/adr/                  ← context-specific decisions
    └── billing/
        ├── CONTEXT.md
        └── docs/adr/
```

## Use the glossary's vocabulary

When your output names a domain concept (in an issue title, a refactor proposal, a hypothesis, a test name),
use the term as defined in `CONTEXT.md`. Don't drift to synonyms the glossary explicitly avoids.

If the concept you need isn't in the glossary yet, that's a signal — either you're inventing language the
project doesn't use (reconsider) or there's a real gap (note it for `/domain-modeling`).

## Flag ADR conflicts

If your output contradicts an existing ADR, surface it explicitly rather than silently overriding:

> _Contradicts ADR-0007 (event-sourced orders) — but worth reopening because…_
