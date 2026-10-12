# 设备矩阵

- 核查日期：2026-10-12（Asia/Shanghai），执行：agent（wayfinder 票 6）
- 当前状态：**真机已接入**——构建侧与真机侧均已实测；签名与装机通道的结论见票 6 的 resolution。

## 1. 构建侧（已实测）

| 项 | 值 | 证据 |
|---|---|---|
| 主机 | macOS 27.0.1（Build 26A434），Apple Silicon `arm64` | `sw_vers` / `uname -m` |
| hdc | `3.2.0f` | `hdc -v` |
| 可编译 API 26 工程 | 是 | `BUILD SUCCESSFUL`，见 `docs/toolchain-lock.md` 第 4 节 |

## 2. 真机（已实测，2026-10-12）

| 项 | 值 | 取法 |
|---|---|---|
| 型号 | HUAWEI MRT-AL10 | `hdc shell param get const.product.model` |
| 品牌 | HUAWEI | `const.product.brand` |
| OS 全名 | OpenHarmony-7.0.0.105 | `const.ohos.fullname` |
| 软件版本 | MRT-AL10 7.0.0.109(SP6C00E105R5P2) | `const.product.software.version` |
| API | 26 | `const.ohos.apiversion` |
| 硬件版本 | HL1ZUYPM | `const.product.hardwareversion` |
| 设备类型 | `phone`（build characteristics: `default`） | `const.product.devicetype` / `const.build.characteristics` |
| 连接方式 | USB；`hdc list targets -v` = `5KTUT25430000967  USB  Connected` | 已实测 |
| 序列号 | 已现场读取并核对，本文不复写（脱敏留存） | — |
| Root 痕迹 | 未发现：`/system/bin/su`、`/system/xbin/su`、`/sbin/su` 均不存在，`which su` 无输出 | 属**初步探测**，不等于完整性证明 |
| 签名类别 | 普通开发者调试签名（AGC 自动签名）；已生成并实测装机成功，见 `docs/evidence/signing.md` | 票 6 |
| 安装渠道 | `hdc install` 通道可用（无参数时返回 `[Fail][E006001]` 属预期提示） | 已实测 |

## 3. 未验证 / 待办

- NOT_RUN：**原厂未 Root 的完整性证明**。当前只证明常见 `su` 路径不存在，spec §3.1 要求的判据尚未做到完备（例如系统完整性/校验启动状态未取证）。
- NOT_RUN：本应用自己的签名物料生成与装机（需华为账号在 DevEco 完成一次自动签名，见票 6）。
- 注意：设备在线状态会变化（本次之前它曾是 `[Empty]`），因此任何依赖真机的结论都必须带当次 `hdc list targets` 记录，不得把「曾经在线」当默认前提。

## 4. 与验收的关系

- 本文件是 spec §3.1 的输入环境记录，也是票 6（签名与装机）与票 9（P01–P06 真机实验）的前置。
- 设备在线只解决「有没有机器」；**跨应用读取、语义点击、后台行为**等能力仍全部 UNKNOWN，必须靠票 9 的实验判定。
