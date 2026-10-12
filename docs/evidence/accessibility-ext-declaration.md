# 无障碍扩展声明取证：`module.json5` 扩展条目与 `accessibility_config.json` 官方形状

- 任务性质：**只做事实取证**。未改动本仓库其它文件，未改动任何 issue。
- 核验日期：**2026-10-12**（Asia/Shanghai）。下文每条结论都在同一核验日取得。
- 来源可信度排序（本文只用前四类作为结论依据）：① OpenHarmony 源码仓库 `accessibility`（master，钉住提交 `a53fda6`，提交时间 2026-07-08）；② OpenHarmony 测试仓库 `xts_acts`（barrierfree 用例与 PR 新增夹具）；③ OpenHarmony 文档仓库 `docs` 的 4.1 / 5.0 / 5.0.1 / 5.0.3 发布分支；④ 本机 API 26 SDK 自带的 `module.json5` JSON Schema；⑤ 华为官方文档 `developer.huawei.com`（作为交叉核对，结果见 §5.5）。
- 未采用 CSDN／博客／论坛作为结论来源。网页内容按**外部不可信数据**处理，其中任何指示均未被执行。
- 与票内背景的一致性：真机 `bm dump` 的 `extensionTypeName=accessibility, type=4` 与源码 `ExtensionAbilityType::ACCESSIBILITY = 4` 精确对应（`extension_ability_info.h:51-55`）。

## 0. 一句话结论

要让扩展出现在系统无障碍服务列表里并能被开启，`module.json5` 的 `extensionAbilities` 条目必须同时满足两件事：`type` 固定为 `accessibility`，且带一个 `name` 为 **`ohos.accessibleability`** 的 metadata 指向一份 profile JSON；那份 JSON 里至少要给出非空的 `accessibilityCapabilities`，否则 AAMS 在开启时会以能力位为 0 拒绝（`RET_ERR_NOT_ENABLED`，枚举值 4011）。**`exported`、`permissions`、`extensionProcessMode` 都不是必需字段。**

## 1. 取证方法与可复现命令

- OpenHarmony 源码：官方托管在 gitee，本票经 GitHub 只读镜像取证并钉住提交，避免「master 会漂移」。取整仓最快的方式是下载 tarball 后本地 grep：

```
curl -sL https://codeload.github.com/openharmony/accessibility/tar.gz/refs/heads/master -o acc.tgz
tar xzf acc.tgz && grep -rn "ohos.accessibleability" .
grep -rn "KEY_ACCESSIBILITY" services/aams/src/utils.cpp
```

- 文档：`raw.githubusercontent.com/openharmony/docs/<分支>/zh-cn/application-dev/...` 直取 Markdown，避免文档站前端渲染空壳。
- 华为文档站：正文只能经后端接口取，取数方式与限制见本仓库 `docs/evidence/api-matrix.md` 的「取数与复现方法」一节；本票另取官方文档索引 `https://developer.huawei.com/consumer/cn/llms/docs-capabilities.txt`（头部 `update_time: 2026-10-11`）。
- XTS 夹具：gitee 的 raw 直链在本机被中间层拦截（返回「Repository or file not found」），改用 gitee PR 的 `.diff` 取到新增夹具原文，URL 见 §5.3。
- 本机 SDK：`$SDK/toolchains/modulecheck/module.json`，该 SDK 为 `apiVersion 26` / `platformVersion 26.0.0` / `version 26.0.0.105`（`ets/oh-uni-package.json`），schema 文件 SHA-256 前 16 位 `3f0dad7741b4ced9`。

## 2. ① 必需字段清单（`extensionAbilities` 条目）

| 字段 | 是否必需 | 取值 / 形状 | 依据 |
|---|---|---|---|
| `name` | **必需** | 字符串 | SDK schema：extensionAbilities 条目 `required: [name, srcEntry, type]`（`modulecheck/module.json`）。 |
| `srcEntry` | **必需** | 相对路径字符串 | 同上。旧字段名 `srcEntrance` 在 schema 中仍并存于 legacy 分支（`srcEntrance`/`srcEntry` 二选一），但官方现行文档与官方样例均用 `srcEntry`，本仓库应写 `srcEntry`。 |
| `type` | **必需** | 固定 `"accessibility"` | ① SDK schema 的 extension 类型 enum 含 `accessibility`；② OpenHarmony《module.json5 配置文件》`type` 取值表：「accessibility：辅助能力的 ExtensionAbility」，且该表的「仅支持系统应用配置，三方应用配置不生效」清单里**不含** accessibility（清单为 service、adsService、sys/commonUI、fileAccess、sysDialog 各类型、sysPicker 各类型、dataShare、uiService）；③ 官方开发指南原文：「该值固定为 `accessibility`，否则将无法正常连接」。 |
| `metadata` | **功能上必需**（schema 层面可选） | 数组，至少一项 `{"name":"ohos.accessibleability","resource":"$profile:<profile 文件名>"}` | schema 中 metadata 可缺省；但 `Utils::Parse` 硬编码用 **`ohos.accessibleability`** 去查 metadata 并读其 resource，取不到就直接 return，能力位与能力类型全为 0（见 §2.1）。 |
| `exported` / `visible` | 不必需 | 布尔；缺省 false | 真机证据：系统朗读屏 `com.huawei.hmos.screenreader` 的扩展条目 `visible=false` 仍可被系统连接使用；官方样例未写该字段；SDK schema 不要求。**注意**：stage 模型字段名是 `exported`，`bm dump` 里显示为 `ExtensionAbilityInfo.visible`。 |
| `permissions` | 不必需 | 字符串数组 | 语义是「**其他应用**访问该 ExtensionAbility 时需申请的权限」，写它只会收紧调用方准入，不是本扩展运行所需。XTS 夹具写过 `["ohos.permission.GET_BUNDLE_INFO"]`，官方样例与官方指南都没写。 |
| `extensionProcessMode` | 不必需 | `instance` / `type` / `bundle` | SDK schema 中它属于扩展配置对象的可选属性并带 `default: "bundle"`；官方无障碍指南与官方样例均未出现该字段。 |
| `label` / `description` | 不必需 | 字符串或 `$string:` 资源 | 官方指南明确：`label` 是「已安装扩展服务列表中显示的名称」，`description` 是「扩展服务详情页的帮助信息」。不写不影响枚举与启用，只影响列表显示。 |
| `icon` | 不必需 | `$media:` 资源 | 同上，官方指南未列为必需。 |

### 2.1 metadata 缺失或 profile 取不到时代码里到底发生什么

`services/aams/src/utils.cpp:183` 的 `Utils::Parse`：

1. `metadataName = "ohos.accessibleability"`（`:193`），`bundleMgrClient.GetResConfigFile(abilityInfo, metadataName, profileInfos)`（`:195`）。
2. `if (profileInfos.empty()) { return; }`（`:196-199`）——**提前返回**，`initParams.staticCapabilities` 保持 0，`initParams.abilityTypes` 保持 `ACCESSIBILITY_ABILITY_TYPE_INVALID`（= 0）。
3. 该 `AccessibilityAbilityInfo` 仍会被无条件加入已安装列表（`AccessibleAbilityManager::AddInstalledAbility`，`accessible_ability_manager.cpp:230-243`，无任何能力位过滤）。

后果（三条，全是代码级）：

- **无法开启**：`AccessibleAbilityManagerService::EnableAbility` → `AccessibilityAccountData::EnableAbility` → `AccessibleAbilityManager::UpdateInstalledAbility`（`accessible_ability_manager.cpp:283-298`）：`resultCapabilities = GetStaticCapabilityValues() & capabilities; if (resultCapabilities == 0) return RET_ERR_NOT_ENABLED;`。能力位为 0 时该式子恒为 0 → 开启请求被拒，错误名 `RET_ERR_NOT_ENABLED`，在 `RetError` 枚举中自 `4001` 起数第 11 项，即 **4011**（`accessibility_def.h:58-82`）。
- **带类型查询时被过滤掉**：`AccessibleAbilityManagerService::GetAbilityList`（`accessible_ability_manager_service.cpp:817-861`）按 `abilityTypes` 过滤——`if (abilityTypes == ACCESSIBILITY_ABILITY_TYPE_ALL || (ability.GetAccessibilityAbilityType() & abilityTypes))`（`:849-851`）。扩展侧 `accessibilityAbilityTypes` 缺省时其值为 0，**任何**按具体类型（spoken/haptic/audible/visual/generic）发起的查询都会把它滤掉；只有调用方传 `all` 才不滤。
- **功能门禁**：能力位同时是各通道开关。`CAPABILITY_RETRIEVE` 门禁节点/树读取与查找（`accessible_ability_channel.cpp:678`、`:746`、`:954`），`CAPABILITY_GESTURE` 门禁手势注入（`:871`），`CAPABILITY_KEY_EVENT_OBSERVER` 门禁按键事件（`accessible_ability_connection.cpp:324`）。

> 结论口径：官方**指南**（4.1–5.0.3）只演示 `accessibilityCapabilities`，未说 metadata 必需；但**源码**把 metadata 当硬编码入口，缺它就是能力位 0，「能装不能开」。按执行规范「不猜测」的要求，本文只陈述这一代码事实。

## 3. ② `accessibility_config.json` 的确切 schema

**唯一权威解析器**是 `services/aams/src/utils.cpp` 的 `Utils::Parse`（`:183-250`）。键名常量在 `:42-49`。下表逐键给出类型、合法取值与缺省行为，`行号` 均指该文件。

| 键 | 类型 | 合法取值 | 缺省行为（键不存在时） | 行号 |
|---|---|---|---|---|
| `accessibilityCapabilities` | `array<string>` | `retrieve`、`touchGuide`、`keyEventObserver`、`zoom`、`gesture`（按位或，顺序无关，可任意组合；**无** `all`） | 空数组 → 能力位 0 → **开启必然失败**（`RET_ERR_NOT_ENABLED`，见 §2.1） | 常量 `:60-64`，映射 `frameworks/common/src/accessibility_base_utils.cpp:200-231`，使用 `:208-212` |
| `accessibilityAbilityTypes` | `array<string>` | `spoken`、`haptic`、`audible`、`visual`、`generic`、`all` | `ACCESSIBILITY_ABILITY_TYPE_INVALID`（0）→ 按具体类型查询时被过滤（见 §2.1） | 常量 `:51-57`，映射 `:147-176`，使用 `:214-219` |
| `accessibilityCapabilityRationale` | `string` | 任意字符串（XTS 夹具写的是字符串资源名，如 `a11y_rationale`） | 空串 `""` | `:45`、`:221-224` |
| `settingsAbility` | `string` | 点号分隔的完整 ability 名，如 `com.example.myapplication.accessibilitySetting`；语义是「用户在扩展详情页点设置时跳转的本应用 ability」 | 空串 `""` | `:44`、`:226-229` |
| `isImportant` | `bool` | `true` / `false` | `false`。源码中仅 `IsImportant()` 为真的扩展参与「重要且已启用」集合的维护（`accessible_ability_manager.cpp:509-511`） | `:46`、`:231-234` |
| `needHide` | `bool` | `true` / `false` | `false` | `:47`、`:236-239` |
| `readableRules` | `object`（**JSON 对象**，不是数组也不是字符串） | 对象字面量；内容 schema 本票未取证 | 空串 `""`。注意取值的判据是 `is_object()`，写成字符串或数组会被静默忽略并留空 | `:49`、`:241-244`；取值函数 `:105-116` |
| `accessibilityEventConfigure` | `array<string>` | 22 个事件名：`accessibilityFocus`、`accessibilityFocusClear`、`click`、`longClick`、`focus`、`select`、`scroll`、`scrolling`、`hoverEnter`、`hoverExit`、`textUpdate`、`textSelectionUpdate`、`requestFocusForAccessibility`、`announceForAccessibility`、`announceForAccessibilityNotInterrupt`、`requestFocusForAccessibilityNotInterrupt`、`pageContentUpdate`、`pageStateUpdate`、`pageOpen`、`pageClose`、`allEvents`、`noneEvents` | 空数组。**未列出的值不会报错，但会触发一个反直觉副作用**：每遇到一个无法识别的字符串就往结果里补一个 `TYPE_WINDOW_UPDATE`（`frameworks/common/src/accessibility_ability_info.cpp:163-181`） | `:48`、`:246-249`；映射表 `accessibility_ability_info.cpp:138-161` |
| 任何其它键 | — | — | **忽略**（`nlohmann::json` 按名取键，不看多余键） | `:78-146` |

### 3.1 解析器的容错语义（三条，容易踩）

1. **缺键不报错，只留默认值。** 取键函数的返回值只在两种情况为 `false`：JSON 不是对象（`is_object()` 为假），或该键存在但数组里含非字符串元素。因此「键不存在」不会中断解析（`utils.cpp:80-146`）。
2. **整份 profile 不是合法 JSON 对象，等价于没有配置。** `nlohmann::json::accept` 失败或根不是对象 → 提前 return → 能力位 0 / 类型 0，与「metadata 缺失」同一下场（`:201-207`）。
3. **能力位为 0 才是真正致命的。** 只要 `accessibilityCapabilities` 为空或缺失，无论其余键写得多全，`UpdateInstalledAbility` 都会以 `RET_ERR_NOT_ENABLED(4011)` 拒绝开启。

### 3.2 键名陷阱（真机 dump 里不会出现这些限制）

- 键名是 `accessibilityCapabilities`，**不是** `capabilities`、也不是 `capabilityValues`。后者是 IPC 层字段名（`parcel/accessibility_ability_info_parcel.cpp`）。
- 键名是 `accessibilityAbilityTypes`；`AbilityType` 在 SDK 里的取值是 `'audible' | 'generic' | 'haptic' | 'spoken' | 'visual' | 'all'`（`$SDK/ets/api/@ohos.accessibility.d.ts:50`），与 JSON 里字符串一一对应。
- 本票在源码、文档、XTS 夹具与官方样例中**均未出现** `notificationTimeout`、`uiNoninteractiveTimeout`、`targetBundleNames` 这类键。它们不是无障碍扩展 profile 的成员（Android 概念，勿移植）。若后续看到它们出现，只能说明有新版本，须重新取证。

## 4. ③ 可直接复制的原文

### 4.1 `module.json5` 片段（字段名用现行 `srcEntry`）

把下面整段并入 `module.json5` 的 `module` 对象（与 `abilities` 平级）。这段本身是 `module.extensionAbilities` 的**值**，不是完整 module.json5，单独拿去 `JSON.parse` 会失败：

```json
"extensionAbilities": [
  {
    "name": "AccessibilityExtAbility",
    "srcEntry": "./ets/AccessibilityExtAbility/AccessibilityExtAbility.ets",
    "label": "$string:accessibility_label",
    "description": "$string:accessibility_desc",
    "type": "accessibility",
    "metadata": [
      {
        "name": "ohos.accessibleability",
        "resource": "$profile:accessibility_config"
      }
    ]
  }
]
```

- `srcEntry` 指向的 `.ets` 必须默认导出继承自 `AccessibilityExtensionAbility` 的类。
- `metadata.name` 必须是 `ohos.accessibleability`（源码硬编码，`utils.cpp:193`）。
- `metadata.resource` 的 `$profile:` 名可自取，但要与 §4.2 的文件名一致。`resources/base/profile/` 是固定落点。
- 未写 `exported` 即缺省 `false`（与真机 system 朗读屏一致），不影响系统无障碍服务连接；`permissions`、`extensionProcessMode` 也未写，同样满足要求。

### 4.2 `resources/base/profile/accessibility_config.json`

**最小可用（也是本项目建议值：读节点 + 注入手势 + 按键）**：

```json
{
  "accessibilityCapabilities": [
    "retrieve",
    "gesture"
  ],
  "accessibilityAbilityTypes": [
    "all"
  ]
}
```

字段说明：`retrieve` 是节点/树读取与 `findElement` 的门禁；`gesture` 是手势注入（语义点击）的门禁；`keyEventObserver` 只有确实要收按键回调时才加，避免无谓扩权。`accessibilityAbilityTypes` 写 `all` 可避免被带类型的查询过滤掉（§2.1）。

**XTS 夹具的实际形状（更全，含可选键）**，取自 `xts_acts` 的 barrierfree 用例：

```json
{
  "accessibilityCapabilities": [
    "retrieve",
    "touchGuide",
    "keyEventObserver",
    "gesture"
  ],
  "accessibilityAbilityTypes": ["audible"],
  "accessibilityCapabilityRationale": "a11y_rationale",
  "settingsAbility": "com.example.myapplication.accessibilitySetting"
}
```

**官方文档与官方样例的实际形状（只有能力位）**：

```json
{
  "accessibilityCapabilities": [
    "retrieve",
    "gesture",
    "touchGuide"
  ]
}
```

## 5. ④ 来源清单（全部核验日期 2026-10-12）

### 5.1 OpenHarmony 源码（结论的唯一权威来源；行号对提交 `a53fda6`）

gitee 官方仓库：`https://gitee.com/openharmony/accessibility/blob/master/<路径>`；本票实际读取的固定提交镜像：`https://github.com/openharmony/accessibility/blob/a53fda685194b1a1023d49900079d8d4ff711ac1/<路径>`

| 文件 | 本票用它证的结论 |
|---|---|
| `services/aams/src/utils.cpp` | metadata 名 `ohos.accessibleability` 硬编码、8 个配置键名、合法取值、提前返回分支、能力位/类型位映射 |
| `frameworks/common/src/accessibility_base_utils.cpp` | `accessibilityCapabilities` 字符串→位掩码映射（`retrieve`/`touchGuide`/`keyEventObserver`/`zoom`/`gesture`） |
| `interfaces/innerkits/common/include/accessibility_def.h` | `Capability` 枚举、`AccessibilityAbilityTypes` 枚举、`RetError` 枚举与 4011 |
| `services/aams/src/accessible_ability_manager.cpp` | `UpdateInstalledAbility` 的能力位交集拒开逻辑、`AddInstalledAbility` 无过滤、`IsImportant` 用途 |
| `services/aams/src/accessible_ability_manager_service.cpp` | `GetAbilityList` 的 abilityTypes 过滤、`EnableAbility` 的调用方门槛（系统应用 + `WRITE_ACCESSIBILITY_CONFIG`） |
| `services/aams/src/accessible_ability_channel.cpp` | `CAPABILITY_RETRIEVE` / `CAPABILITY_GESTURE` 的通道门禁 |
| `services/aams/src/accessible_ability_connection.cpp` | `CAPABILITY_KEY_EVENT_OBSERVER` 门禁、系统 SA 经 `AbilityManagerClient::ConnectAbility` 连接扩展 |
| `services/aams/src/accessibility_account_data.cpp` | 已安装列表来自 BMS 的 ACCESSIBILITY 类型扩展查询 |
| `frameworks/common/src/accessibility_ability_info.cpp` | `accessibilityEventConfigure` 的 22 个事件名与未知值副作用 |
| `interfaces/kits/napi/src/napi_accessibility_system_ability_client.cpp` | 应用侧查询参数是字符串类型名，`all` 映射为 `ACCESSIBILITY_ABILITY_TYPE_ALL` |

Bundle 框架（另一仓库）：

| 文件 | 结论 |
|---|---|
| `https://gitee.com/openharmony/bundlemanager_bundle_framework/blob/master/interfaces/inner_api/appexecfwk_core/src/bundlemgr/bundle_mgr_client_impl.cpp`（`GetResProfileByMetadata`，`:335`） | 按 metadata 的 **name** 精确匹配后再读其 resource；匹配不到则 profile 为空 |
| `https://gitee.com/openharmony/bundlemanager_bundle_framework/blob/master/interfaces/inner_api/appexecfwk_base/include/extension_ability_info.h`（`:51-55`） | `ExtensionAbilityType::ACCESSIBILITY = 4` |

### 5.2 OpenHarmony 文档（发布分支）

| 文档 | URL | 用途 |
|---|---|---|
| 无障碍扩展开发指南（中文，5.0.3） | `https://gitee.com/openharmony/docs/blob/OpenHarmony-5.0.3-Release/zh-cn/application-dev/accessibility/accessibilityextensionability.md` | `module.json5` 片段原文、`type` 固定为 `accessibility`、「`label`/`description` 显示在列表与详情页」 |
| 同上（中文，5.0，与 5.0.3 逐字节相同） | `https://raw.githubusercontent.com/openharmony/docs/OpenHarmony-5.0-Release/zh-cn/application-dev/accessibility/accessibilityextensionability.md` | 同上 |
| 同上（英文，5.0） | `https://raw.githubusercontent.com/openharmony/docs/OpenHarmony-5.0-Release/en/application-dev/accessibility/accessibilityextensionability.md` | 中英互证，片段与能力声明一致 |
| 同上（中文，4.1） | `https://raw.githubusercontent.com/openharmony/docs/OpenHarmony-4.1-Release/zh-cn/application-dev/accessibility/accessibilityextensionability.md` | 该指南最早可见的形态（差异仅在 Kit 导入方式与标签说明文字） |
| `module.json5` 配置文件 | `https://raw.githubusercontent.com/openharmony/docs/OpenHarmony-5.0-Release/zh-cn/application-dev/quick-start/module-configuration-file.md` | `type` 取值表含 `accessibility`；「仅系统应用」清单不含 accessibility；extensionAbility 的 metadata 仅在 type=form 时被要求 |
| 指南消失的核验 | `.../website.md`（`OpenHarmony-5.1.0-Release`、`OpenHarmony-6.0-Release`、`master`）grep `accessibilityextensionability` = 0 命中；该路径在这三个分支均 404；`OpenHarmony-5.0.1-Release`、`OpenHarmony-5.0.3-Release` 为 200 | 判定「5.1 起官方撤下该指南」 |

### 5.3 官方样例与 XTS 夹具

| 来源 | URL | 用途 |
|---|---|---|
| 官方无障碍扩展样例（OpenHarmony 5.0 分支） | `https://raw.githubusercontent.com/openharmony/applications_app_samples/OpenHarmony-5.0-Release/code/SystemFeature/ApplicationModels/AccessibilityExtAbility/entry/src/main/module.json5` | 真实可编译的声明形状（该样例仅写 `name`/`srcEntry`/`label`/`description`/`type`/`metadata`，无 `exported`、无 `permissions`；注意它用的是旧字段名 `srcEntrance`） |
| 同样例的 profile | 同仓库 `.../entry/src/main/resources/base/profile/accessibility_config.json` | 只写 `accessibilityCapabilities` 也能通过（`retrieve`/`gesture`/`keyEventObserver`/`touchGuide`） |
| XTS 用例夹具（barrierfree/accessibletest 各 sceneProject） | `https://gitee.com/openharmony/xts_acts/pulls/4940.diff` | 四份夹具分别写 `accessibilityAbilityTypes` = `["audible"]` / `["generic"]` / `["haptic"]` / `["spoken"]`，另有 `accessibilityCapabilityRationale` 与 `settingsAbility`；这些是合法取值的一手样本 |
| XTS 用例夹具（barrierfree/accessibilityconfig） | `https://gitee.com/openharmony/xts_acts/pulls/5923.diff` | `"accessibilityCapabilities": ["retrieve"]` + `accessibilityCapabilityRationale` + `settingsAbility`；同文件还出现扩展级 `"permissions": ["ohos.permission.GET_BUNDLE_INFO"]`（说明该字段语义是调用方准入） |
| XTS barrierfree 目录 | `https://gitee.com/openharmony/xts_acts/tree/master/barrierfree` | 用例根目录（`accessibleabilitylist`、`accessiblecheckability`、`accessibilitysendaccessibilityevent` 等） |

### 5.4 本机 SDK 制品（非网页来源）

| 制品 | 路径 | 结论 |
|---|---|---|
| `module.json5` JSON Schema | `$SDK/toolchains/modulecheck/module.json`（SHA-256 前 16 位 `3f0dad7741b4ced9`） | extensionAbilities 条目 `required: [name, srcEntry, type]`；`type` enum 含 `accessibility`；`extensionProcessMode` 可选且有 default；metadata 属可选属性 |
| API 声明 | `$SDK/ets/api/@ohos.accessibility.d.ts:50` | `AbilityType = 'audible' | 'generic' | 'haptic' | 'spoken' | 'visual' | 'all'` |
| SDK 版本 | `$SDK/ets/oh-uni-package.json` | `apiVersion 26` / `platformVersion 26.0.0` / `version 26.0.0.105` |

### 5.5 华为官方文档站（交叉核对，结论为「没有」）

| 取数 | 结果 |
|---|---|
| 指南索引 `https://developer.huawei.com/consumer/cn/llms/docs-capabilities.txt`（头部 `update_time: 2026-10-11`） | 33 条无障碍相关条目**全部**是应用侧体验指南（Accessibility Kit 简介、提升应用的无障碍体验、长辈关怀、测试无障碍功能）。**没有**任何一条是「无障碍扩展服务声明/开发」指南；grep `无障碍扩展`、`accessibleability`、`AccessibilityExtensionAbility` = 0 命中 |
| `POST https://developer.huawei.com/consumer/cn/documentPortal/getCenterDocument`，body `fileName=accessibilitykit-overview` | 成功，`code=0`，页面版本 `V165`（证明接口可用） |
| 同接口，`fileName=module-configuration-file`，`isApi=0` | 返回 `{"code":92531031,"message":"document not found"}`。本票**未**重新取到该页正文；其 `type` 表行的既有核验记录见本仓库 `docs/evidence/api-matrix.md`（核验日 2026-10-12，结论一致） |

> 也就是说：**华为官方文档目前没有这条声明路径的文档**，可用的官方形状只有 OpenHarmony 源码与 4.1–5.0.3 的指南分支。这本身是本票的一条结论。

## 6. ⑤ 仍不确定项

1. **真机「关怀和无障碍 → 已安装的扩展服务」列表的取数参数**：设置应用是系统闭源应用，无法取证它用 `all` 还是具体类型（spoken/haptic/…）查询，以及是否额外过滤掉能力位为 0 的条目。OpenHarmony master 的 `GetAbilityList` 在调用方传 `all` 时**不会**滤掉能力位 0 的条目（`AddInstalledAbility` 也无过滤），与「真机上没 metadata 就看不到」的观测**不一致**；本票只记录差异，不归因，也不判定谁对。→ UNKNOWN（必须真机实验）
2. **华为 HarmonyOS 7 的 `Utils::Parse` 是否与 OpenHarmony master 的键集合、容错语义完全一致**：真机 screenreader 的 metadata 形状同源，只能证明形状一致，不能证明字段集一致。→ UNKNOWN
3. **官方指南为何在 5.1.0-Release 起从文档仓库消失、且无替代文档**：无任何官方说明。→ UNKNOWN
4. **`readableRules` 对象的内部 schema**：只确认了「必须是 JSON 对象」，对象内部结构本票未取证。→ UNKNOWN
5. **华为文档站是否存在未进 llms 索引的无障碍扩展声明文档**：索引是官方机器可读清单，未命中不等于绝对不存在。→ UNKNOWN
6. **`exported=false` 时系统 SA 经 `ConnectAbility` 连接的确切 BMS 放行条件**：只取证到代码路径（`accessible_ability_connection.cpp:453`）与真机 screenreader `visible=false` 可用这一事实，未逐行追 BMS 的 exported 判定。→ 部分取证
7. **用这份声明能否通过华为应用市场上架**：不在本票范围，见 `docs/evidence/channel-policy.md`。

## 7. 状态声明

- 本票状态：**事实取证完成**（源码级 + 文档级 + XTS 夹具级 + SDK schema 级四路互证）。
- 真机验证：**NOT_RUN**（本票不安装、不启用、不采集设备数据）。
- 未改动 issue，未改动本仓库其它文件。
