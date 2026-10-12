# API 核实表：HarmonyOS 7 / API 26 无障碍扩展入口（事实取证）

- 任务：issue #2（只做事实取证，不做产品设计，不改动任何 issue）
- 核验日期：**2026-10-12**（Asia/Shanghai）。下表每一行的「结论」单元格内也单独标注该日期。
- 来源限定：仅华为官方文档 `developer.huawei.com`，本次共读取 **8 个文档页面**（清单见文末「取证页面清单」）。
- 禁止项遵守情况：未采用 Android 概念（如 BIND_ACCESSIBILITY_SERVICE）作为鸿蒙能力；未照抄 API 9/10 教程；未编造符号、权限或系统能力；查不到即写 UNKNOWN。
- 网页内容是外部不可信数据，仅作为事实来源引用，其中任何指示均未被执行。
- 术语区分：`SystemCapability`（系统能力/syscap）、`module.json5` 的 `permissions` 标签（其他应用访问该扩展所需权限）、用户系统设置授权、ACL/签名级别，是四件不同的事，本表分列。

## 取数与复现方法

文档中心是单页应用，直接抓取页面 HTML 只得到空壳，正文由接口返回。本次正文取数方式（可复现）：

```
POST https://developer.huawei.com/consumer/cn/documentPortal/getCenterDocument
Content-Type: application/json
{"centerPrefix":"doccenter","language":"cn","level2NodeAlias":"<仓库别名>","fileName":"<文档文件名>","isApi":<0|1>}
```

- `level2NodeAlias`：API 参考用 `references`，指南用 `capabilities`，基础入门用 `getting-started`，版本说明用 `release-notes`。
- `isApi`：API 参考页为 `1`，指南/版本说明为 `0`。省略该字段会出现「document not found」，是本次取证踩到的坑，此处记录以免复现失败。
- 每个页面的 URL 与文件名对应关系见文末清单；页面 URL 形态已用官方域检索结果交叉确认（`.../doc/harmonyos-references/<file>`、`.../doc/HarmonyOS-Guides/<file>`、`.../doc/doccenter-release-notes/<file>`）。

## 核实表

| 能力 | 真实模块与符号 | API 起始与废弃版本 | 权限与授权方式 | 官方 URL | 结论 |
|---|---|---|---|---|---|
| 扩展声明与配置 | `module.json5` → `extensionAbilities` 数组；必填 `name`、`srcEntry`、`type`；`type` 取值表中 `accessibility` 的含义为「辅助能力的 ExtensionAbility」；可选 `exported`（缺省 false）、`permissions`、`icon`、`label`、`description`、`metadata`、`skills`、`extensionProcessMode`、`dataGroupIds` 等 | 该页为 26.0.0 版本文档（页面版本 V244）；`accessibility` 取值行未标注单独起始版本；页面中新增标签多以 20 / 26.0.0 为起点 | 该页未给出无障碍扩展自身所需的 `ohos.permission.*`；`permissions` 标签语义是「其他应用访问该 ExtensionAbility 时需申请的权限」，不是本扩展运行所需；`SystemCapability.BarrierFree.Accessibility.Core` 是系统能力，不是权限 | https://developer.huawei.com/consumer/cn/doc/HarmonyOS-Guides/module-configuration-file | 官方 `type` 表确实登记了 `accessibility`，且该行**未**标注「三方应用配置不生效」（`service`、`dataShare`、`staticSubscriber`、`window`、`adsService`、`fileAccess` 均明确标注）。因此「可声明该类型」有据；但该差异**不能**证明普通签名可安装/启用，可用性仍为 UNKNOWN。核验 2026-10-12 |
| 生命周期回调 | `@kit.AccessibilityKit` 的 `AccessibilityExtensionAbility`：`onConnect(): void`、`onDisconnect(): void`；实例属性 `context: AccessibilityExtensionContext` | `onConnect`、`onDisconnect` 均自 API 9 起支持、**自 API 12 起废弃**；该页未给出替代接口，页面内无 `onCreate`/`onDestroy`/`onForeground` 等回调 | 页面标注系统能力 `SystemCapability.BarrierFree.Accessibility.Core`；未声明任何 `ohos.permission.*`。文档措辞为「用户启用/停用」时回调，即授权由用户侧发起，但系统设置的具体路径未在本次 8 页内取证 | https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-application-accessibilityextensionability | API 26 文档（版本 V242，页面更新 2026-10-09）中，该扩展可重写的生命周期回调**只有这两个，且都已标 (deprecated)**。后继路径：UNKNOWN。核验 2026-10-12 |
| 事件订阅与筛选 | 订阅：`AccessibilityExtensionAbility.onAccessibilityEvent(event: AccessibilityEvent): void`；事件对象 `AccessibilityEvent` 字段 `eventType`、`target`、`timeStamp`、`elementId12+`、`textAnnouncedForAccessibility12+`、`extraInfo20+`；筛选：`AccessibilityExtensionContext.setTargetBundleName(targetNames: Array<string>)` | `onAccessibilityEvent` API 9 起支持、API 12 起废弃；`setTargetBundleName` API 9 起支持、API 12 起废弃；同页 `TouchGuideType` 的 `touchGuideGesture` 与 `GestureType` 的 `oneFingerDoubleTap` 标注「起始版本：26.0.0」 | 系统能力 `SystemCapability.BarrierFree.Accessibility.Core`；页面未声明权限。`setTargetBundleName` 语义为：设置后仅接收关注应用的事件，未设置则接收所有应用事件，取消关注传空数组 | https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-application-accessibilityextensionability ；https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-inner-application-accessibilityextensioncontext | API 26 文档里事件订阅与事件筛选入口仍只有上述两个，且都被标废弃。26.0.0 仍在给这套废弃体系补枚举值（说明文档未下线该体系，但不构成可用性证明）。后继路径：UNKNOWN。核验 2026-10-12 |
| 节点/树读取 | `AccessibilityExtensionContext`：`getFocusElement`、`getWindowRootElement`、`getWindows`、`attributeNames`、`attributeValue`、`findElement('content' / 'focusType' / 'focusDirection')`；返回类型 `AccessibilityElement` / `ElementAttributeValues`（含 `bundleName`、`componentType`、`clickable`、`isVisible`、`isEnable`、`rect`、`children`、`parent`、`rootElement` 等） | 上述接口均自 API 9 起支持、**自 API 12 起废弃**（该页 29 处接口小节全部带 (deprecated)；`findElement` 三个重载整段标废弃） | 系统能力 `SystemCapability.BarrierFree.Accessibility.Core`；页面未声明 `ohos.permission.*` | https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-inner-application-accessibilityextensioncontext | 页面既未给出替代接口，且 `Accessibility Kit 简介` 明确写：「Accessibility Kit 目前仅支持上述无障碍状态查询和无障碍事件发送能力，**不支持通过无障碍节点查询获取界面节点及屏幕内容信息**」。即跨应用节点/屏幕内容读取在 API 26 官方口径下**不被支持**。核验 2026-10-12 |
| 节点动作 | `AccessibilityExtensionContext`：`performAction`、`actionNames`、`injectGesture`、`injectGestureSync` | `performAction`/`actionNames` API 9 起支持、API 12 起废弃；`injectGesture` API 9 起支持、API 10 起废弃（文档称建议用 `injectGestureSync` 替代）；`injectGestureSync` API 10 起支持、**API 12 起也废弃** | 系统能力同上；页面未声明权限 | https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-inner-application-accessibilityextensioncontext | 语义动作与手势注入入口全部废弃，且文档明说唯一被建议的替代接口 `injectGestureSync` 自身也已废弃 → 无官方可用替代。后继路径：UNKNOWN。核验 2026-10-12 |
| 授权/开启状态查询（普通应用侧） | `@ohos.accessibility`：`isOpenAccessibilitySync`（替代已废弃的 `isOpenAccessibility`）、`isOpenTouchGuideSync`、`getAccessibilityExtensionList`、`getAccessibilityExtensionListSync`、`on('accessibilityStateChange')`、`on('touchGuideStateChange')`、`on('screenReaderStateChange')18+` | `getAccessibilityExtensionList` 9+、`getAccessibilityExtensionListSync` 12+、`screenReaderStateChange` 18+；`on('enableChange')`/`on('styleChange')` API 8 起支持、API 12 起废弃（页面未给替代）；`getAbilityLists`/`sendEvent` 分别建议用 `getAccessibilityExtensionList`/`sendAccessibilityEvent` 替代 | 页面未声明 `ohos.permission.*` | https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-accessibility | 普通（非扩展）应用侧在 API 26 可用的只有**查询**类与监听类接口；Kit 简介把能力范围限定为「无障碍状态查询 + 无障碍事件发送」。扩展的授权开启/撤销系统设置路径：本次未取证 → UNKNOWN。核验 2026-10-12 |
| API 26（7.0.0）无障碍增量 | 版本说明中的 API 变更清单：`@ohos.accessibility` 新增 `isSeniorModeEnabled`、`onSeniorModeStateChange`、`offSeniorModeStateChange`（7001）与 `onSeniorModeStateChangeForSelf`、`offSeniorModeStateChangeForSelf`、`getSeniorModeStateForSelf`、`setSeniorModeStateForSelf`（7002） | 26.0.0 新增 | — | https://developer.huawei.com/consumer/cn/doc/doccenter-release-notes/js-apidiff-accessibilitykit-7001 ；https://developer.huawei.com/consumer/cn/doc/doccenter-release-notes/js-apidiff-accessibilitykit-7002 | 7.0.0（API 26）无障碍 Kit 的官方增量**只有**普通应用侧的长者模式状态接口；变更清单中**没有**任何新增或恢复的扩展入口（未出现 `AccessibilityExtensionAbility` / `AccessibilityExtensionContext` 条目）。核验 2026-10-12 |
| 已废弃四回调的后继路径（onConnect / onDisconnect / onAccessibilityEvent / onKeyEvent） | 四个回调均定义在 `@ohos.application.AccessibilityExtensionAbility`（导入自 `@kit.AccessibilityKit`）；`onKeyEvent(keyEvent: KeyEvent): boolean` 为按键事件入口，参数类型来自 `@kit.InputKit` | 四个回调统一为 API 9 起支持、**API 12 起废弃** | 系统能力 `SystemCapability.BarrierFree.Accessibility.Core`；无权限声明 | https://developer.huawei.com/consumer/cn/doc/harmonyos-references/js-apis-application-accessibilityextensionability ；https://developer.huawei.com/consumer/cn/doc/harmonyos-references/accessibility-api ；https://developer.huawei.com/consumer/cn/doc/harmonyos-references/accessibility-arkts | **UNKNOWN**：文档只写「从 API version 12 开始废弃」，未给替代接口。Accessibility Kit 的 ArkTS API 目录仅 5 个模块（`@ohos.accessibility`、`@ohos.accessibility.GesturePath`、`@ohos.accessibility.GesturePoint`、`@ohos.application.AccessibilityExtensionAbility`、`AccessibilityExtensionContext`），不存在承接旧回调的新扩展模块；API 26 变更清单也未引入替代入口。按执行规范 §3.2，「不明确后继接口时，技术可行性保持 UNKNOWN」。核验 2026-10-12 |

## UNKNOWN 清单

### A. 本次明确判定为 UNKNOWN 的问题

1. `onConnect` / `onDisconnect` / `onAccessibilityEvent` / `onKeyEvent` 在 API 26 的**后继接口**：官方未给出。UNKNOWN。
2. 废弃回调在 API 26 真机上是否仍被投递（编译通过 ≠ 可用）：属真机实测，文档无法回答。UNKNOWN。
3. 无障碍扩展所需的**权限与授权方式**：这 8 页内未出现任何无障碍相关 `ohos.permission.*`；用户系统设置中的启用/撤销路径未取证。UNKNOWN（禁止凭名称臆造权限）。
4. 普通开发者签名能否安装/启用 `type` 为 `accessibility` 的扩展：文档未作正面或反面承诺。UNKNOWN。

### B. 执行规范 §3.2 要求、但**不在本票（#2）范围**内、因此本次未取证的条目

以下条目**未取证**，不得据本表推断为可用或不可用：窗口与目标应用身份、屏锁状态、应用版本查询、可见/可操作状态（相关属性 `isVisible`/`isEnable` 仅出现在已废弃的 `ElementAttributeValues` 中）、配置跨进程同步、关闭/撤销时停止动作、实测日志与 SDK 声明位置。

## 取证页面清单（8 页）

| # | 文档 | 页面版本 / 更新时间 | 取数参数（level2NodeAlias / fileName / isApi） |
|---|---|---|---|
| 1 | `@ohos.application.AccessibilityExtensionAbility (辅助功能扩展能力)` | V242 / 页面更新 2026-10-09 | references / js-apis-application-accessibilityextensionability / 1 |
| 2 | `AccessibilityExtensionContext (辅助功能扩展上下文)` | V33 / 页面更新 2026-10-09 | references / js-apis-inner-application-accessibilityextensioncontext / 1 |
| 3 | `@ohos.accessibility (辅助功能)` | V242 / 页面更新 2026-10-09 | references / js-apis-accessibility / 1 |
| 4 | `Accessibility Kit（无障碍服务）` API 目录页 | V242 | references / accessibility-api / 1 |
| 5 | `module.json5配置文件`（extensionAbilities 与 type 标签） | V244 / 2026-10-10 | getting-started / module-configuration-file / 0 |
| 6 | `Accessibility Kit 简介`（能力范围原文） | V165 / 展示更新 2026-09-23 | capabilities / accessibilitykit-overview / 0 |
| 7 | 版本说明 `Accessibility Kit`（7.0.0 API 变更清单之一） | 26.0.0 | release-notes / js-apidiff-accessibilitykit-7001 / 0 |
| 8 | 版本说明 `Accessibility Kit`（7.0.0 API 变更清单之二） | 26.0.0 | release-notes / js-apidiff-accessibilitykit-7002 / 0 |

（`accessibility-arkts` 目录页在结论列作为辅助引用，用于确认 ArkTS API 模块清单，属同一文档站点的目录页。）

## 关键原文摘录（用于复核，均为官方文档原句）

1. 「`onConnect(): void` … 用户启用 AccessibilityExtensionAbility 时，系统服务完成连接后回调此接口 … 从 API version 9 开始支持，从 API version 12 开始废弃。」——页面 1
2. 「`injectGesture` … 从 API version 9 开始支持，从 API version 10 开始废弃。建议使用 injectGestureSync 替代，但该替代接口从 API version 12 开始也已废弃。」——页面 2
3. 「Accessibility Kit 目前仅支持上述无障碍状态查询和无障碍事件发送能力，不支持通过无障碍节点查询获取界面节点及屏幕内容信息。」——页面 6
4. 「`accessibility` | 辅助能力的 ExtensionAbility。」（type 标签取值表，该行未附「三方应用配置不生效」说明）——页面 5

## SDK 声明核对（票 4，2026-10-12）

- 取证对象（只读，未改动）：`/Volumes/ZT700-Data/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony/ets`。身份以 `ets/oh-uni-package.json` 为准：`apiVersion 26`、`platformVersion 26.0.0`、`version 26.0.0.105`、`releaseType Release`。并核对同级 `openharmony/js/api`、`openharmony/toolchains`、`hms/ets/api`。
- 方法：只读检索 `.d.ts` 原文，逐项读 JSDoc 的 `@since` / `@deprecated` / `@useinstead` / `@syscap` / `@permission`。SDK 声明位置一律写「文件:行号」，行号为本次实际读取行。下列 SDK 路径均省略前缀 `<SDK>/ets/`。
- 四件事分列：`SystemCapability`（syscap）、manifest 权限、用户系统设置授权、ACL/签名级别。本表「权限声明」列只填 SDK 里真实出现的 `@permission` 或结构化声明，名称查不到即空，不臆造。
- 本票不写产品代码、不改 issue、不提交 git；运行期可用性一律不判定（属真机实验）。

### 逐项核对表（spec §3.2 的 12 项）

| 能力 | 真实模块与符号 | SDK 声明位置（文件:行） | 起始与废弃（JSDoc 原文） | SystemCapability | 权限声明 | 结论（2026-10-12） |
|---|---|---|---|---|---|---|
| 1 扩展声明与配置 | manifest `module.json5` → `extensionAbilities[].type` 取值 `accessibility`（SDK 以 JSON Schema 声明该枚举） | `toolchains/modulecheck/module.json:614`、`:2023`（两处 `type` enum 均含 `accessibility`） | JSON Schema 无 `@since` / `@deprecated` 标签；随 SDK 26.0.0.105 发布 | 无（manifest 层不带 syscap） | 该类型在 Schema 内未绑定任何 `ohos.permission.*`；未发现 `accessibility` 专属子 schema | 声明「可配置该 type」有 SDK Schema 依据；第三方签名能否安装／启用仍 UNKNOWN |
| 2 生命周期回调 | `AccessibilityExtensionAbility`（class，`:96`）、`context: AccessibilityExtensionContext`（`:103`）、`onConnect(): void`（`:112`）、`onDisconnect(): void`（`:121`） | `api/@ohos.application.AccessibilityExtensionAbility.d.ts:96`、`:103`、`:112`、`:121` | class `@since 9`（`:94`）；`context` `@since 9`（`:101`）；`onConnect` `@since 9` + `@deprecated since 12`（`:109-110`）；`onDisconnect` 同（`:118-119`）；二者均无 `@useinstead` | `SystemCapability.BarrierFree.Accessibility.Core`（`:93`、`:100`、`:108`、`:117`） | 无 `@permission` | 两个生命周期回调在 API 26 声明里存在且均标 deprecated 12；该类未声明 `onCreate`／`onDestroy`／`onForeground` |
| 3 事件订阅与筛选 | `onAccessibilityEvent(event: AccessibilityEvent): void`（`:131`）；`AccessibilityEvent`（`:152`）；筛选 `setTargetBundleName(targetNames: Array<string>)` 两重载 | `api/@ohos.application.AccessibilityExtensionAbility.d.ts:131`、`:152`；`api/application/AccessibilityExtensionContext.d.ts:52`、`:68` | `onAccessibilityEvent` `@since 9` + `@deprecated since 12`（`:128-129`）；两个 `setTargetBundleName` 均 `@since 9` + `@deprecated since 12`（`:49-50`、`:65-66`）；均无 `@useinstead` | `SystemCapability.BarrierFree.Accessibility.Core` | 无 `@permission` | 事件订阅与筛选入口在 SDK 内只有这两处，且均已 deprecated 12；未发现 `on(...)` 形式的事件订阅 API |
| 4 窗口与目标应用身份 | `ElementAttributeValues.bundleName`（`:502`）、`windowId`（`:885`）、`type: WindowType`（`:849`）、`rootElement`（`:778`）、`children`（`:529`）、`parent`（`:747`）；`WindowType`（`:1036`）；`AccessibilityEvent.target`（`:176`）；`getWindows(displayId?)`（`:177`、`:193`、`:207`）；`@ohos.accessibility` 的 `EventInfo.bundleName`（`:1263`）、`AccessibilityAbilityInfo.bundleName`（`:1129`） | `api/application/AccessibilityExtensionContext.d.ts:502`、`:885`、`:849`、`:778`、`:529`、`:747`、`:1036`、`:177`；`api/@ohos.application.AccessibilityExtensionAbility.d.ts:176`、`:103`；`api/@ohos.accessibility.d.ts:1263`、`:1129` | 元素身份字段 `@since 9`（`offset`/`textType` 等 `@since 12`，`accessibilityNextFocusId` 等 `@since 18`），均未标 deprecated；`getWindows` 三个重载 `@since 9` + `@deprecated since 12`（`:173-175`、`:189-191`、`:203-205`）；`WindowType` `@since 9`（`:1034`） | `SystemCapability.BarrierFree.Accessibility.Core` | 无 `@permission` | 包名／窗口身份字段仍在且未废弃，但唯一读取入口 `getWindows`／`getWindowRootElement` 已 deprecated 12；未发现独立的「当前前台窗口」查询 API |
| 5 树与节点读取 | `getFocusElement`（`:84`、`:101`、`:115`）、`getWindowRootElement`（`:131`、`:147`、`:161`）、`getWindows`（`:177`、`:193`、`:207`）、`findElement`（`:401`、`:416`、`:431`、`:446`、`:461`、`:476`）、`attributeNames`（`:276`、`:285`）、`attributeValue`（`:301`、`:316`）、`AccessibilityElement`（`:267`） | `api/application/AccessibilityExtensionContext.d.ts` 上述行 | 上列方法全部 `@since 9` + `@deprecated since 12`；该文件共 29 处 `@deprecated`（与官方页 `29 处接口小节标 deprecated` 数字一致）；无 `@useinstead` | `SystemCapability.BarrierFree.Accessibility.Core`（每个方法 JSDoc 均带） | 无 `@permission` | 节点／树读取符号在 API 26 声明中确实存在且全部 deprecated 12；SDK 未声明替代接口 |
| 6 节点动作 | `performAction`（`:353`、`:370`、`:386`）、`actionNames`（`:327`、`:336`）、`injectGesture`（`:223`、`:239`）、`injectGestureSync`（`:253`） | `api/application/AccessibilityExtensionContext.d.ts` 上述行 | `performAction`／`actionNames` `@since 9` + `@deprecated since 12`；`injectGesture` `@since 9` + `@deprecated since 10` + `@useinstead AccessibilityExtensionContext.injectGestureSync`（`:220-221`、`:236-237`）；`injectGestureSync` `@since 10` + `@deprecated since 12`（`:250-251`） | `SystemCapability.BarrierFree.Accessibility.Core` | 无 `@permission` | 唯一被 `@useinstead` 指定的替代接口 `injectGestureSync` 自身也已 deprecated 12 → SDK 内不存在未废弃的语义动作／手势注入入口 |
| 7 授权状态 | 普通应用侧：`isOpenAccessibilitySync(): boolean`（`:215`）、`isOpenAccessibility`（`:190`、`:201`）、`getAccessibilityExtensionList`（`:304`、`:323`）、`getAccessibilityExtensionListSync`（`:336`）、`on('accessibilityStateChange')`（`:437`）；扩展侧错误码 `9300003 - No accessibility permission to perform the operation.`（`AccessibilityExtensionContext.d.ts:79` 等） | `api/@ohos.accessibility.d.ts:215`、`:190`、`:304`、`:336`、`:437`；`api/application/AccessibilityExtensionContext.d.ts:79` | `isOpenAccessibilitySync` `@since 10`（`:213-215`）未废弃；`isOpenAccessibility` `@since 7` + `@deprecated since 10` + `@useinstead accessibility.isOpenAccessibilitySync`（`:186-188`、`:197-199`）；`getAccessibilityExtensionListSync` `@since 12`（`:334-336`） | `SystemCapability.BarrierFree.Accessibility.Core` | 该文件 `@permission` 命中数为 0；`9300003` 是运行期授权错误码，不是 manifest 权限名 | 可查询「系统里是否已启用任一无障碍应用」；无障碍扩展自身的启用／撤销属用户系统设置，SDK 声明里不描述该路径 → UNKNOWN |
| 8 屏锁状态 | 无障碍四模块内 0 命中锁屏符号；仅 `@ohos.screenLock.d.ts`（`@kit BasicServicesKit`）的 `isScreenLocked`（`:37`、`:47`）、`isSecureMode`（`:57`、`:67`）、`unlockScreen`（`:77`、`:87`） | `api/@ohos.screenLock.d.ts:27`（namespace）、`:37`；无障碍文件 `api/@ohos.accessibility*.d.ts`、`api/application/AccessibilityExtensionContext.d.ts` 检索无命中 | 全文件每个函数 `@since 7` + `@deprecated since 9`（`:33-34`、`:43-44`、`:53-54`、`:63-64`、`:73-74`、`:83-84`）；文件共 89 行、无未废弃函数 | `SystemCapability.MiscServices.ScreenLock`（不是 BarrierFree） | 文件内无 `@permission` | SDK 未给无障碍扩展任何屏锁状态入口；`screenLock` 模块整体 deprecated 9；运行期能否感知锁屏 → UNKNOWN（须真机 P06） |
| 9 应用版本查询 | `@ohos.bundle.bundleManager`：`getBundleInfoForSelfSync(bundleFlags): BundleInfo`（`:1041`）、`getBundleInfoForSelf`（`:1011`、`:1027`）、`getBundleInfo`（`:1062`、`:1087`、`:1110`）；版本字段 `BundleInfo.versionName`（`bundleManager/BundleInfo.d.ts:75`）、`versionCode`（`:65`） | `api/@ohos.bundle.bundleManager.d.ts:1041`、`:1011`、`:1027`、`:1062`、`:1087`、`:1110`；`api/bundleManager/BundleInfo.d.ts:75`、`:65` | `getBundleInfoForSelfSync` `@since 10`（`:1039-1041`）未废弃；`getBundleInfoForSelf` `@since 9`（`:1009-1011`）；`getBundleInfo` `@since 14`（`:1060-1062`）；`BundleInfo.versionName` `@since 9` | `SystemCapability.BundleManager.BundleFramework.Core`（三条 JSDoc 均带） | `getBundleInfoForSelf`／`getBundleInfoForSelfSync` 无 `@permission`；`getBundleInfo` 标注 `@permission ohos.permission.GET_BUNDLE_INFO_PRIVILEGED or ohos.permission.GET_BUNDLE_INFO`（`:1048`、`:1069`、`:1094`）；`getBundleInfoSync` 同（`:1373`、`:1396`） | 查本包版本可无权限；查目标应用（他包）版本需 `GET_BUNDLE_INFO` 或特权权限；普通签名／ACL 能否申请该权限 → UNKNOWN |
| 10 可见与可操作状态 | `ElementAttributeValues`（`:485`）字段：`isVisible`（`:698`）、`isEnable`（`:658`）、`clickable`（`:539`）、`isActive`（`:648`）、`isFocused`（`:678`）、`focusable`（`:615`）、`editable`（`:589`）、`scrollable`（`:795`）、`selected`（`:805`）、`longClickable`（`:731`）、`accessibilityScrollable`（`:1004`） | `api/application/AccessibilityExtensionContext.d.ts:485` 及上述行 | 除 `accessibilityScrollable` `@since 18`（`:1002-1004`）、`offset`／`textType`／`accessibilityText`／`hotArea` `@since 12`（`:893-917`）外均 `@since 9`；这些**属性字段本身未标 `@deprecated`**（与读取方法的 deprecated 12 不同） | `SystemCapability.BarrierFree.Accessibility.Core` | 无 `@permission` | 可见／可操作属性声明仍在且未废弃，但读取通道 `attributeValue`／`findElement` 已 deprecated 12 → 属性可用性与读取可行性是两件事，不得混判 |
| 11 配置跨进程同步 | `AccessibilityExtensionAbility` 只有 4 个回调，**无**配置变更回调；继承来的 `ExtensionContext.config: Configuration`（`application/ExtensionContext.d.ts:53`）；另 `AbilityStage.onConfigurationUpdate(newConfig)`（`@ohos.app.ability.AbilityStage.d.ts:199`）、`EnvironmentCallback.onConfigurationUpdated(config)`（`@ohos.app.ability.EnvironmentCallback.d.ts:42`） | `api/@ohos.application.AccessibilityExtensionAbility.d.ts:96-144`；`api/application/ExtensionContext.d.ts:53`；`api/@ohos.app.ability.AbilityStage.d.ts:199`；`api/@ohos.app.ability.EnvironmentCallback.d.ts:42` | `ExtensionContext` `@since 9`、`config` `@since 9`；`onConfigurationUpdate` `@since 9`（`:197-199`）；`onConfigurationUpdated` `@since 9`（`:40-42`） | `SystemCapability.Ability.AbilityRuntime.Core`（三条均非 BarrierFree） | 无 `@permission` | SDK 未给无障碍扩展声明配置变更回调；扩展能否收到跨进程配置同步 → UNKNOWN（须真机） |
| 12 关闭或撤销时停止动作 | `onDisconnect(): void`（`api/@ohos.application.AccessibilityExtensionAbility.d.ts:121`）；`injectGestureSync(gesturePath)`（`api/application/AccessibilityExtensionContext.d.ts:253`）。SDK 内未发现「撤销授权」「generation／代次」相关声明 | `api/@ohos.application.AccessibilityExtensionAbility.d.ts:121`；`api/application/AccessibilityExtensionContext.d.ts:253` | `onDisconnect` `@since 9` + `@deprecated since 12`（`:118-119`）；`injectGestureSync` `@since 10` + `@deprecated since 12`（`:250-251`） | `SystemCapability.BarrierFree.Accessibility.Core` | 无 `@permission` | SDK 无「取消／失效未决动作」的显式 API；撤销授权或断开后未决动作是否作废 → UNKNOWN（须真机 P06） |

### 三问正面回答

**问 1：`AccessibilityExtensionContext` 与 onConnect / onDisconnect / onAccessibilityEvent / onKeyEvent 在 API 26 SDK 声明里是否存在、是否带 deprecated？有没有承接它们的新模块或新入口？**

存在，且四者全部带 deprecated。`AccessibilityExtensionContext` 作为 `AccessibilityExtensionAbility.context` 的类型声明在 `api/application/AccessibilityExtensionContext.d.ts:35`（class，`@since 9`），并经 `api/@ohos.application.AccessibilityExtensionAbility.d.ts:88` 的 type 别名对外导出；四个回调同属 `AccessibilityExtensionAbility` 声明（`api/@ohos.application.AccessibilityExtensionAbility.d.ts:112` / `:121` / `:131` / `:143`），JSDoc 原文统一为 `@since 9` 加 `@deprecated since 12`，四个都没有 `@useinstead`。

承接的新模块／新入口：**未发现**。`ets/kits/@kit.AccessibilityKit.d.ts:22-25` 只聚合 `@ohos.accessibility`、`@ohos.accessibility.GesturePath`、`@ohos.accessibility.GesturePoint`、`@ohos.application.AccessibilityExtensionAbility`（含 `AccessibilityExtensionContext` 等类型），不引入任何新模块；`js/api` 下同名同 4 个模块；`hms/ets/api`、`hms/js/api` 无 accessibility 文件。按规范 §3.2「不明确后继接口时技术可行性保持 UNKNOWN」，本项维持 UNKNOWN。

**问 2：`SystemCapability.BarrierFree.Accessibility.Core` 在 SDK 里是否仍被这些符号标注？**

是，仍标注。`SystemCapability.BarrierFree.Accessibility.Core` 出现在 `AccessibilityExtensionAbility` class（`:93`）、`context`（`:100`）、四个回调（`:108`、`:117`、`:127`、`:139`）、`AccessibilityEvent`（`:149`）以及 `AccessibilityExtensionContext` 的全部方法、`ElementAttributeValues` 全部字段、`Rect`／`FocusType`／`WindowType` 上。该 syscap 本身在 `api/device-define/default.json`、`2in1.json`、`tablet.json`、`wearable.json` 的 `SysCaps` 列表中存在（default.json 共 231 条 syscap，BarrierFree 三条：`Core`／`Vision`／`Hearing`）。

**问 3：官方「不支持节点查询」的表述与 SDK 声明是否冲突？**

**冲突，如实记录，不替任何一方下结论。** 冲突双方：其一，官方《Accessibility Kit 简介》原句「Accessibility Kit 目前仅支持上述无障碍状态查询和无障碍事件发送能力，不支持通过无障碍节点查询获取界面节点及屏幕内容信息」；其二，本机 API 26 SDK 声明里 `getWindowRootElement`（`:131`／`:147`／`:161`）、`findElement`（`:401`／`:416`／`:431`／`:446`／`:461`／`:476`）、`getFocusElement`、`getWindows`、`attributeValue` 等节点／树读取符号真实存在，只是全部标 `@deprecated since 12`。二者对「是否支持节点查询」的表述不一致。**本票只记录冲突，不判定运行期是否可用**（那属真机实验 P04／P05），也不据此认定官方文档错误或 SDK 有效。

### 本次实际执行的检索命令（关键字）

```bash
SDK=/Volumes/ZT700-Data/Applications/DevEco-Studio.app/Contents/sdk/default/openharmony
ls $SDK/ets/api | grep -i accessib
ls $SDK/js/api | grep -i accessib ; ls $SDK/hms/ets/api | grep -i accessib
grep -rn AccessibilityExtensionContext $SDK/ets --include=*.d.ts
grep -nE '@since|@deprecated|@useinstead|@syscap|@permission' $SDK/ets/api/application/AccessibilityExtensionContext.d.ts
grep -nE '@since|@deprecated|@useinstead|@syscap|@permission' $SDK/ets/api/@ohos.application.AccessibilityExtensionAbility.d.ts
grep -c '@deprecated' $SDK/ets/api/application/AccessibilityExtensionContext.d.ts
grep -rn '@permission' $SDK/ets/api/@ohos.accessibility.d.ts $SDK/ets/api/application/AccessibilityExtensionContext.d.ts $SDK/ets/api/@ohos.application.AccessibilityExtensionAbility.d.ts
grep -rniE 'screenlock|islocked|lockscreen' $SDK/ets/api/@ohos.accessibility*.d.ts $SDK/ets/api/application/AccessibilityExtensionContext.d.ts
ls $SDK/ets/api | grep -i screenlock
grep -nE '@syscap|@since|@deprecated|function ' $SDK/ets/api/@ohos.screenLock.d.ts
grep -n 'getBundleInfoForSelf\|getBundleInfo\|@permission' $SDK/ets/api/@ohos.bundle.bundleManager.d.ts
grep -n 'versionName|versionCode' $SDK/ets/api/bundleManager/BundleInfo.d.ts
grep -n 'config: Configuration' $SDK/ets/api/application/ExtensionContext.d.ts
grep -rln 'onConfigurationUpdate' $SDK/ets/api
python3 -c 'import json;d=json.load(open(SysCaps))'  # 读 device-define/*.json 的 SysCaps，过滤 BarrierFree
grep -n accessibility $SDK/toolchains/modulecheck/module.json
cat $SDK/ets/oh-uni-package.json
```

### 本票新增 UNKNOWN 清单

1. 第三方（普通）签名能否安装并启用 `type: accessibility` 的扩展 —— SDK 声明层无法回答，UNKNOWN。
2. 无障碍扩展启用／撤销的用户系统设置路径 —— SDK 声明不描述，UNKNOWN。
3. 无障碍扩展能否感知屏锁状态（`screenLock` 整体 deprecated 9，且不属于 AccessibilityKit）—— UNKNOWN。
4. `ohos.permission.GET_BUNDLE_INFO` 对普通签名的可得性（ACL／签名级别）—— UNKNOWN。
5. 进程配置变更是否同步到无障碍扩展进程 —— UNKNOWN。
6. 撤销授权／断开连接后未决动作是否自动作废 —— UNKNOWN（须真机 P06）。
7. 四个 deprecated 12 回调在 API 26 真机上是否仍被投递 —— UNKNOWN（沿用票 2 结论，编译通过不等于可用）。
8. 官方「不支持节点查询」与 SDK 存在节点查询声明之间的运行期真相 —— UNKNOWN（须真机 P04／P05）。

核对项数：**12 项**（spec §3.2 清单全覆盖）。新增 UNKNOWN：**8 项**。冲突判定：**存在冲突**（官方 Kit 简介的「不支持节点查询」与本机 SDK 的节点查询声明并存，本票不下运行期结论）。
