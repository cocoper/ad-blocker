# 向华为咨询：第三方无障碍扩展的启用入口与用途资质

- 对应票：[向华为确认第三方无障碍服务的启用入口与用途资质](https://github.com/cocoper/ad-blocker/issues/16)
- 状态：**材料已备好，尚未提交**。是否提交、以什么账号提交、以及提交入口，由负责人决定并执行。
- 版本：2026-10-12（Asia/Shanghai）。依据：`HARMONYOS7_EXECUTION_SPEC.md` §2.2 R02、§13、AGENTS.md 第 9 条。

> 纪律：未经负责人明确授权，agent 不代其提交工单、不同意协议、不对外沟通。提交后请把受理号与官方答复原文回填票 16，并落进 `docs/evidence/`。

## 一、可直接复制的问题正文

```
咨询：HarmonyOS 7（API 26）上第三方无障碍（Accessibility）扩展的启用入口与用途资质

环境：HUAWEI MRT-AL10，OpenHarmony-7.0.0.105，软件版本 7.0.0.109(SP6C00E105R5P2)，API 26；
     DevEco Studio 26.0.0，API 26 Release SDK 26.0.0.105；普通开发者自动签名（调试证书 + 调试 Profile）。

我们按官方接口实现了一个 type 为 accessibility 的 ExtensionAbility，扩展声明里带了
metadata: name=ohos.accessibleability, resource=$profile:accessibility_config，profile 里
accessibilityCapabilities 非空（retrieve/gesture/keyEventObserver）、accessibilityAbilityTypes=all。

实测现象：
1) HAP 用普通开发者签名可以安装成功；bm dump 显示该扩展被登记（extensionTypeName=accessibility）。
2) 应用内调用 accessibility.getAccessibilityExtensionListSync('all','install') 能查到本应用，
   而 state=enable 的结果为 0 —— 即已安装、未启用。
3) 但在系统「设置」里找不到启用它的入口：无障碍相关入口名为「关怀和无障碍」，
   该页只有系统自身的一方便携功能（关怀模式 / 视觉辅助 / 听觉辅助 / 交互控制），
   没有「已安装的服务 / 无障碍服务」这类第三方服务列表；设置内搜索「无障碍」也只返回该页。

希望确认：
1) 零售版与开发者版上，第三方（普通签名）无障碍扩展应当通过哪个界面或流程启用？
   是否只对系统应用或白名单开发者开放？
2) 若对第三方开放，需要哪些资质、申请或声明材料？调试签名与正式签名是否有区别？
3) 用途层面：一个「在用户明确启用的应用里，识别并单击该应用广告的跳过/关闭控件」的工具，
   在华为应用市场以什么形态申报、是否允许上架，是否属于需要额外说明的用途？
4) 若该能力在当前版本对第三方不开放，是否有对应的官方规划或替代接口（例如受支持的
   无障碍扩展新入口）可供参考？

复现材料（如需可提供）：扩展模块源码、打包后的 module.json、accessibility_config.json、
装机与自检日志、设置页截图。以上均可提供。
```

## 二、我们已掌握的证据（供对方追问或你自己核对）

| 证据 | 位置 |
|---|---|
| 扩展声明与配置的官方形状（源码级：`services/aams/src/utils.cpp`，OpenHarmony `accessibility` 提交 `a53fda6`） | `docs/evidence/accessibility-ext-declaration.md` |
| SDK 声明核对（四个回调与 `AccessibilityExtensionContext` 全部 `@deprecated since 12`、无替代） | `docs/evidence/api-matrix.md` |
| 真机实测与判定（P01 通过、P02 本机型 BLOCKED） | `docs/evidence/g0-probe.md` |
| 设备信息（型号 / OS build / API / 连接方式） | `docs/evidence/device-matrix.md` |
| 签名类别与装机链路（普通开发者调试签名，未挂调试器） | `docs/evidence/signing.md` |
| 渠道政策核对（审核指南未点名该用途，§13 第 26 项为最接近的风险条款） | `docs/evidence/channel-policy.md` |
| 工具链与环境（DevEco 26.0.0、SDK 26.0.0.105） | `docs/toolchain-lock.md` |
| 原型源码（Probe 扩展 + 自检宿主页 + Fixture） | `prototype/g0-probe/`（另在 throwaway 分支 `prototype/g0-probe`） |

## 三、最小复现步骤（对方若要求复现）

1. 用 DevEco Studio 26.0.0 + API 26 SDK 打开 `prototype/g0-probe/probe`，用普通开发者账号自动签名，`hvigorw --no-daemon assembleHap`。
2. `hdc install -r <signed.hap>` → `install bundle successfully`。
3. `hdc shell bm dump -n com.cocoper.clearstart` → 可见 `extensionTypeName=accessibility`、`type=4`。
4. 打开宿主页：它会把 `getAccessibilityExtensionListSync('all','install' | 'enable')` 的结果打进 hilog
   （tag `ClearStartProbeHost`），并按上面第 2 条给出结果。
5. 打开 设置 → 关怀和无障碍（或在设置里搜索「无障碍」），观察是否存在第三方服务列表。

## 四、提交后要回填的内容

- 提交时间、渠道、受理号／会话号
- 官方答复原文（或截图路径）
- 对应结论：入口是否存在、资质是否必需、用途是否允许
- 若答复推翻或修正了我们的判断，同步更新票 15、票 9 与地图的 Decisions
