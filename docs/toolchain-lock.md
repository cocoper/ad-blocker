# 工具链锁定（G0）

- 锁定与核验日期：2026-10-12（Asia/Shanghai），执行人：agent（wayfinder 票 #3）
- 构建侧机器：macOS 27.0.1（Build 26A434），Apple Silicon `arm64`
- 结论：**本机可以编译 API 26 工程**，证据见第 4 节「冒烟构建」。本文只记录真实读出的版本与命令，没有推测的 patch 版本。

## 1. 版本锁

| 组件 | 版本 | 来源路径 |
|---|---|---|
| DevEco Studio | 26.0.0（build `DS-261.23567.138.36.2600851`） | `/Volumes/ZT700-Data/Applications/DevEco-Studio.app` |
| HarmonyOS SDK | apiVersion `26`，platformVersion `26.0.0`，releaseType `Release`，version `26.0.0.105` | 同上 `/Contents/sdk/default/{openharmony,hms}`；声明文件 `/Contents/sdk/default/sdk-pkg.json` |
| Ets 包 | `26.0.0.105` | `/Contents/sdk/default/openharmony/ets/oh-uni-package.json` |
| hvigor 与 `@ohos/hvigor-ohos-plugin` | `6.26.8` | `/Contents/tools/hvigor` |
| ohpm | `26.0.0.630` | `/Contents/tools/ohpm` |
| Node.js | `v24.14.1` | `/Contents/tools/node` |
| JDK（打包阶段用） | JBR `OpenJDK 25.0.2+10-329.117-nomod` | `/Contents/jbr/Contents/Home` |
| hdc | `3.2.0f` | `/Contents/sdk/default/openharmony/toolchains/hdc` |

说明：SDK 随 DevEco 安装包分发（`sdk/default`），不是 `~/Library/Huawei/Sdk` 下的独立安装；该目录目前只有一份 HarmonyOS 7.0.0 系统镜像（`system-image/HarmonyOS-7.0.0/phone_all_arm`，4.7G）与 SDK 许可文件，没有 SDK 本体。

## 2. 系统 Java 不可用（会让打包失败）

`/usr/bin/java` 是 macOS 占位程序，运行报 `Unable to locate a Java Runtime`。`PackageHap` 阶段因此失败过一次（错误码 `00308018`）。构建必须显式使用 DevEco 自带 JBR。

## 3. 沙箱约束（本仓库 agent 环境的硬事实）

本会话的文件沙箱是 workspace-write，`$HOME` **不可写**。hvigor 默认要写 `~/.hvigor/project_caches`、npm 默认要写 `~/.npm`，都会以 `EPERM` 失败。用下面这组环境变量重定向后可成功构建（这是**必需**的前置，不是可选优化）：

```
export HOME=/tmp/clearstart-home                 # 任意可写目录
export HVIGOR_USER_HOME=$HOME/.hvigor
export npm_config_cache=$HOME/.npm
export JAVA_HOME=/Volumes/ZT700-Data/Applications/DevEco-Studio.app/Contents/jbr/Contents/Home
export DEVECO_SDK_HOME=/Volumes/ZT700-Data/Applications/DevEco-Studio.app/Contents/sdk
export PATH="$JAVA_HOME/bin:/Volumes/ZT700-Data/Applications/DevEco-Studio.app/Contents/tools/node/bin:$PATH"
```

未重定向 `HOME` 时的失败原文：`EPERM: operation not permitted, mkdir '/Users/yang/.hvigor/project_caches/<hash>/workspace/node_modules/@ohos'`。

## 4. 冒烟构建（可复现证明）

- 工程来源：DevEco 自带最小工程模板 `/Contents/plugins/codegenie-plugin/previewProjectTemplate`，复制到 `/tmp/clearstart-env-smoke`。
- 改动：`build-profile.json5` 的 `compatibleSdkVersion` 与 `targetSdkVersion` 改为 `26.0.0`，并删掉指向空 `signingConfigs` 的 `signingConfig` 行。
- 命令：在工程根目录执行 `hvigorw --no-daemon assembleHap`（用第 3 节的环境变量）。
- 结果：`BUILD SUCCESSFUL`，`33 tasks in total: 16 executed, 17 up-to-date`；`CompileArkTS`、`CompileResource`、`PackageHap`、`SignHap` 均 Finished。
- 产物：`entry/build/default/outputs/default/entry-default-unsigned.hap`，127049 字节，SHA-256 `500a83febcf15d2fc982de32eda852a707055e1e333a8fd18540f88f1611147a`；包内为 `module.json`、`ets/modules.abc`、`resources.index` 与资源文件。
- 日志：`docs/evidence/build-logs/hvigorw-smoke-2026-10-12.log`（原 `/tmp/clearstart-smoke3.log` 的副本，2473 字节，已自查无 token/口令/私钥字样）。
- 说明：冒烟工程本体放在 `/tmp/clearstart-env-smoke`，属临时构建物，不入仓库；配方已完整记录在本节，可随时重建。

性质边界：这是**工具链冒烟工程**，不是本项目的 Probe 或 Fixture；它只证明环境能编译 API 26 工程，**不构成任何产品能力证据**。产物是**未签名** HAP（构建日志 `WARN: No signingConfig found for product default`）；签名属票 #6。

## 5. 未验证项（NOT_RUN）

- NOT_RUN：把该 HAP 装进真机运行——当前无设备在线，见 `docs/evidence/device-matrix.md`（BLOCKED）。
- NOT_RUN：`ohpm install` 拉取三方依赖（冒烟工程 `dependencies` 为空，未触及 registry）。
- NOT_RUN：DevEco Studio GUI 构建路径（本次只用 CLI）。
