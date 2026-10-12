# 签名与装机证据（票 6）

- 日期：2026-10-12（Asia/Shanghai）。执行：agent（wayfinder 票 6）；账号侧的一次 GUI 操作由负责人完成。
- 结论：**普通开发者签名（AGC 自动签名生成的调试证书与调试 Profile）的编译 → 装机 → 启动 → 卸载全链路在本机与真机上通过。**
- 边界：这建立了 G0 的输入环境，**不等于** P01/P02 验收。P01 的目标制品是 Probe、P02 是启用无障碍服务，两者都属票 9。

## 1. 应用身份（已定）

| 项 | 值 |
|---|---|
| bundleName | `com.cocoper.clearstart` |
| 版本 | versionName `1.0.0` / versionCode `1000000` |
| 装机后系统上报 | `appDistributionType: none`（未做任何特权分发） |
| 安装位置 | `/data/app/el1/bundle/public/com.cocoper.clearstart` |

## 2. 签名物料（只记路径与类型；私钥不入仓库、不入日志）

| 项 | 值 |
|---|---|
| 签名类别 | **普通开发者调试签名**（非系统签名、非私有 ACL、非企业特权） |
| 生成方式 | DevEco Studio 的「自动生成签名」，绑定负责人华为账号，作用于含目标 bundleName 的工程 |
| Profile | `type=debug`；`bundle-name=com.cocoper.clearstart`；`app-feature=hos_normal_app`；有效期 2026-10-12 22:03:27 → 2027-10-12 22:03:27（本地时区）；内含 `device-id` 授权字段（内容脱敏，当前设备装机实证通过） |
| 证书链 | Huawei CBG Root CA G2 → Huawei CBG Developer Relations CA G2 → 叶子证书（CN 为开发者实名，本文件脱敏；叶子有效期 2026-10-12 → 2027-10-12） |
| 叶子证书 SHA-256 指纹 | `88:09:ED:FB:F7:51:2E:C1:6D:BB:90:47:48:5F:7C:79:5D:05:D1:B0:D4:8B:C7:B6:C3:A4:B5:62:D9:BE:97:DB` |
| 算法 / 密钥别名 | `SHA256withECDSA` / `debugKey` |
| 物料路径 | `~/.ohos/config/default_clearstart-signing_<hash>.{p12,cer,csr,p7b}`；p12 与 p7b 权限 `600`，仅存本机 |
| 复用方式 | 后续工程（票 5）把同一 `signingConfigs` 段复制进自己的 `build-profile.json5` 即可复用，无需再次账号操作 |

## 3. 装机链路（实测）

| 步骤 | 命令 | 结果 |
|---|---|---|
| 构建签名 HAP | `hvigorw --no-daemon assembleHap`（debug） | `entry-default-signed.hap`，167699 字节，SHA-256 `3b3cc715151aa9eb8e8df62e367223b7b44d119f1b7795c385a8262de80a9c4d` |
| 安装 | `hdc install -r <hap>` | `install bundle successfully` |
| 启动 | `hdc shell aa start -b com.cocoper.clearstart -a EntryAbility` | `start ability successfully`，进程 pid 18849 |
| 查询 | `hdc shell bm dump -n com.cocoper.clearstart` | `codePath` 与 `versionName 1.0.0` 正常 |
| 卸载 | `hdc uninstall com.cocoper.clearstart` | `uninstall bundle successfully`，随后 `bm dump` 报该包不存在 |

## 4. 设备与调试器状态

- 设备：HUAWEI MRT-AL10 / OpenHarmony-7.0.0.105 / API 26 / 软件版本 7.0.0.109(SP6C00E105R5P2)，USB 连接（细节见 `docs/evidence/device-matrix.md`）。
- 调试器：**未挂调试器**。上述构建、装机、启动、查询全部由 CLI + hdc 完成，没有 DevEco 调试会话参与。这给出了 spec 要求的「脱离调试器」操作范式，但**不构成** P07 后台 2 小时的证据。

## 5. 已知边界（NOT_RUN）

- NOT_RUN：把 Probe 或 Fixture 装进真机——那两件制品属票 5；本次装的是**验通道用的最小工程**。
- NOT_RUN：无障碍服务的启用 / 撤销路径（P02）。
- NOT_RUN：签名物料 2027-10-12 过期后的续签流程。
- 未验证：该最小工程没有申请任何 `ohos.permission.*`，因此本次装机**不能**证明任何权限的可获得性。
- 临时物：验通道工程位于 `/tmp/clearstart-signing`（不入仓库）；装机验证后已卸载。
