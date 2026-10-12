# ClearStart G0 Probe / Fixture（抛弃式原型）

> **这是抛弃式原型，不是生产代码。** 它的唯一目的是回答一个平台能力问题。按 /prototype 规则：不写测试、不做打磨、不持久化、用完即弃（本目录稍后会被搬到 throwaway 分支，main 只留结论）。

## 要回答的问题（分支判定：两个 HTML 分支都不适用）

问题不是「逻辑手感」也不是「界面长什么样」，而是**平台运行期能力**：

1. **P02**：普通开发者签名下，系统能不能启用一个 `type: accessibility` 的扩展？（即 `onConnect` 在 API 26 真机上是否仍被调用——该回调官方标注 `@deprecated since 12`）
2. **P03**：启用了之后，能不能收到**跨应用**事件？
3. **P04**：能不能**读到跨应用节点**？（现代 API 的 `getWindowRootElement` 是否真的可用——官方《Accessibility Kit 简介》称「不支持通过无障碍节点查询获取界面节点及屏幕内容信息」，而 SDK 声明里这些符号都在，只是标了废弃）

因此 /prototype 的 LOGIC.md / UI.md 两个分支都回答不了它：产物必须是真机上的两个真实包。沿用 /prototype 的**通用规则**：抛弃式、命名可识别、一条命令可跑、无持久化、不做打磨、外显状态、做完捕获。

## 两个包

| 目录 | bundleName | 角色 |
|---|---|---|
| `probe/` | `com.cocoper.clearstart` | **Probe**：宿主页 + `ClearStartProbeExt`（`type: accessibility`）。复用票 6 已验签的签名配置 |
| `fixture/` | `com.cocoper.clearstart.fixture` | **Fixture**：可控目标端，三模式（A 倒计时后出现可点击「跳过」/ B 有广告但控件不可点击 / C 静默页）+ 内容页 |

Fixture 是独立包，这样跨应用能力才算被证明；它的调试签名需要**再点一次 DevEco 自动签名**（一个 profile 只授权一个 bundleName）。

## 怎么跑

```bash
prototype/g0-probe/verify.sh
```

它做四件事：构建两个工程 → 装机 → 拉起 Fixture → 抓 `hilog` 里 tag 为 `ClearStartProbe` 的行并按 P02/P03/P04 给判定。

需要负责人做的两步（脚本会提示）：

1. **给 Fixture 生成调试签名**：DevEco 打开 `prototype/g0-probe/fixture` → File → Project Structure → Signing Configs → 勾选自动签名。
2. **启用 Probe 的扩展**：手机 设置 → 辅助功能 → 无障碍 → 找到本应用并开启。这一步就是 P02 的正面证据。

## 怎么看结果

- 看到 `P02 onConnect FIRED` → 普通签名的 accessibility 扩展**能被系统启用**，且废弃回调在 API 26 真机上仍被投递。
- 看到 `P03 event#n type=…` → 事件确实进来了；若同时出现 Fixture 的包名，则是**跨应用**事件。
- 看到 `P04 READ_OK bundle=… nodes=… clickable=…` → 节点查询**真的可用**，官方「不支持节点查询」的表述与真机行为不符。
- 看到 `P04 READ_FAILED code=…` → 记下错误码，这就是官方那句话的实际含义；G0 的路径判定要据此走 FAIL 平台或降范围。

## 日志纪律

只写：事件类型、目标包名、节点计数、错误码。**绝不打印屏幕文本、节点文本或输入内容**（spec 9.4）。本原型为了证明 P03/P04 会记录**包名与计数**，生产实现里日志口径比这更严。

## 当前状态

见仓库 issue #5 的正文与评论；结论会写进 `docs/evidence/`。
