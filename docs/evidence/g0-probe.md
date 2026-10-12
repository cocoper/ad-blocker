# G0 Probe 结论（票 5，2026-10-12）

## 1. 要回答的问题

普通开发者签名下，一个 `type: accessibility` 的扩展能不能在 API 26 真机上被**用户启用**，从而进入 P02 → P03 → P04 的链路（onConnect / 跨应用事件 / 跨应用节点）。

/ 原型的分支判定：LOGIC.md 与 UI.md 两个 HTML 分支都不适用（要答的是平台运行期能力），产物必须是真机上的两个真实包。

## 2. 产物

`prototype/g0-probe/`：`probe/`（宿主页 + `ClearStartProbeExt`）、`fixture/`（三模式可控目标端 + 内容页）、`verify.sh`（构建→装机→拉起→抓 hilog→判 P02/P03/P04）、`README.md`。Fixture 是独立包 `com.cocoper.clearstart.fixture`，尚未签名装机。

## 3. 实测结果（逐条带证据）

| # | 事实 | 证据 |
|---|---|---|
| 1 | **P01 通过**：普通开发者签名 + **内含 `type: accessibility` 扩展**的 HAP 能装机 | `hdc install -r` → `install bundle successfully` |
| 2 | 系统登记了该扩展 | `bm dump -n com.cocoper.clearstart`：`extensionTypeName=accessibility`、`type=4`、`srcEntrance=./ets/extension/ProbeExtensionAbility.ets` |
| 3 | 声明缺 metadata 时**不会被当成无障碍服务** | 见 `docs/evidence/accessibility-ext-declaration.md`（源码硬编码 `ohos.accessibleability`）；补上后宿主页自检 `getAccessibilityExtensionListSync('all','install')` 返回的 7 项里出现本包 |
| 4 | 配置已被框架解析（能力类型非 0） | 同一自检以 **`all`** 这个带类型的查询返回本包；按源码，`accessibilityAbilityTypes` 为 0 时该查询会把它过滤掉 |
| 5 | **当前无任何无障碍服务被启用** | 同上自检：`state=enable count=0` |
| 6 | **设置里没有第三方无障碍服务的启用入口** | ① 设置搜索「无障碍」只返回「关怀和无障碍」一项；② 该页（重启设置进程后重开、滚到底）全量内容为：关怀模式 / 视觉辅助（屏幕朗读、放大手势、高对比度文字、颜色反转、色彩校正、高级视觉辅助）/ 听觉辅助（音频调节、声音修复、文本通话、助听设备、闪烁提醒、小艺字幕）/ 交互控制（屏幕触控、无障碍快捷键）；③「高级视觉辅助 → 更多」里是过渡动画相关，无服务开关 |
| 7 | 第三方 app 无法自助启用 | `@ohos.accessibility` 全库无 enable 类接口（只有 `isOpen*` / `getAccessibilityExtensionList*` / `on*` / `sendAccessibilityEvent` / captions / animationReduce） |
| 8 | 设备侧入口名与深链（顺带产出） | 入口名不是「辅助功能」而是**「关怀和无障碍」**；`aa start -b com.huawei.hmos.settings -a com.huawei.hmos.settings.MainAbility -A ohos.want.action.viewData -U accessibility_feature:` 实测能打开该页（Settings 的 bundle 里自己声明了 `accessibility_feature` scheme） |

## 4. 判定

**P02 在本机型 + 本 OS 版本上：BLOCKED（无用户可达的启用入口）。**

- 我们的声明与配置经源码级 schema 核对与真机打包核对，**没有写错**；框架也确实登记了扩展。
- 但**用户没有任何界面路径**把第三方扩展打开；系统设置里根本没有「已安装的服务 / 无障碍服务」这类列表。
- 因此 P03（跨应用事件）、P04（跨应用节点读取）在本机**无法进入**：服务开不了，回调就不会被投递。

## 5. 边界（不得夸大）

- 本结论的适用范围是**这一台机器 + 这一个 OS build**（HUAWEI MRT-AL10 / OpenHarmony-7.0.0.105 / 软件版本 7.0.0.109(SP6C00E105R5P2) / API 26）。spec 3.4 的「FAIL 平台」需要平台级证据，本票只给出**单设备**证据，所以措辞是 BLOCKED（本设备）而不是平台 FAIL。
- 无法读 `/system/app`（`Permission denied`），因此不能从设置应用的代码层证明该入口不存在；判断来自三条独立的界面观测（搜索、整页滚动、二级页）+ 公共 API 面。
- 未排除的可能：(a) 重启设备后设置列表状态不同（缓存）；(b) 零售版与开发版差异；(c) 厂商对第三方无障碍服务启用的策略限制（白名单/资质）。
- 未验证：Fixture 签名与装机、P02/P03/P04 的任何正向结果。

## 6. 对项目的影响

1. **G0 的存在性问题现在有了第一个硬答案**：能装、能被框架登记，但**用户开不了**。按 spec 3.4 与 14.1，这属于必须停线回报的形态；最终判定票（#14）需要据此决定 PASS/BLOCKED/FAIL。
2. 需要两条新的核验路径：**第二台设备/另一个 OS build**（区分「本机状态」与「平台策略」），以及**向华为确认第三方无障碍服务的启用入口与用途资质**（spec §2.2 R02 的咨询路径）。
3. **产品引导路径**只能写「关怀和无障碍」；`accessibility_feature` 深链只能作为辅助手段，且必须先在本机确认它落到的是无障碍页而不是设置首页（本票实测：带 `viewData` action 时可打开）。
4. 原型本身按 /prototype 规则捕获：源码在本仓库 `prototype/g0-probe/`，另提交到 throwaway 分支（main 只留结论）。

## 7. 证据索引

- 命令与日志：本文件第 3 节；完整构建日志 `/tmp/proto-probe.log`、`/tmp/proto-fixture.log`（本机临时路径）。
- 截图：`/tmp/cs_ui*.jpeg`、`/tmp/d*.jpeg`、`/tmp/s_*.jpeg`（按证据口径**不入库**，仓库外留存，核验日期 2026-10-12 22:49–22:57）。
- 声明与 schema：`docs/evidence/accessibility-ext-declaration.md`。
- 环境与签名：`docs/toolchain-lock.md`、`docs/evidence/signing.md`、`docs/evidence/device-matrix.md`。
