#!/usr/bin/env bash
# PROTOTYPE — ClearStart G0 一键验证（抛弃式，非生产脚本）
# 做四件事：构建两个工程 → 装机 → 拉起 Fixture → 抓 Probe 日志并给 P02/P03/P04 判定。
set -u

APP=/Volumes/ZT700-Data/Applications/DevEco-Studio.app/Contents
ROOT="$(cd "$(dirname "$0")" && pwd)"
REAL_HOME="${HOME}"
PROTO_HOME="${PROTO_HOME:-/tmp/clearstart-home}"
PROTO_TAG="ClearStartProbe"
PROBE_BUNDLE="com.cocoper.clearstart"
FIX_BUNDLE="com.cocoper.clearstart.fixture"

# --- 环境（票 3 记录的三个坑：HOME 不可写、系统 Java 不可用、SDK 要显式指路）---
mkdir -p "${PROTO_HOME}/.hvigor" "${PROTO_HOME}/.npm"
ln -sfn "${REAL_HOME}/.ohos" "${PROTO_HOME}/.ohos"
export HOME="${PROTO_HOME}"
export HVIGOR_USER_HOME="${PROTO_HOME}/.hvigor"
export npm_config_cache="${PROTO_HOME}/.npm"
export JAVA_HOME="${APP}/jbr/Contents/Home"
export DEVECO_SDK_HOME="${APP}/sdk"
export PATH="${JAVA_HOME}/bin:${APP}/tools/node/bin:${PATH}"
HVIGORW="${APP}/tools/hvigor/bin/hvigorw"
HDC="${APP}/sdk/default/openharmony/toolchains/hdc"

say() { printf '\n== %s\n' "$1"; }

build() { # $1 = probe|fixture
  local d="$1"
  say "构建 ${d}"
  ( cd "${ROOT}/${d}" && "${HVIGORW}" --no-daemon assembleHap ) > "/tmp/proto-${d}.log" 2>&1
  if grep -q 'BUILD SUCCESSFUL' "/tmp/proto-${d}.log"; then
    echo "构建成功（日志 /tmp/proto-${d}.log）"
  else
    echo "构建失败，看 /tmp/proto-${d}.log"; grep -E 'ERROR' "/tmp/proto-${d}.log" | head -8; return 1
  fi
}

say "设备"
"${HDC}" list targets

build probe || exit 1
build fixture || exit 1

PROBE_HAP="$(ls "${ROOT}/probe/entry/build/default/outputs/default/"*signed.hap 2>/dev/null | head -1)"
FIX_SIGNED="$(ls "${ROOT}/fixture/entry/build/default/outputs/default/"*signed.hap 2>/dev/null | head -1)"
FIX_HAP="${FIX_SIGNED:-$(ls "${ROOT}/fixture/entry/build/default/outputs/default/"*unsigned.hap 2>/dev/null | head -1)}"

say "装机"
"${HDC}" install -r "${PROBE_HAP}" 2>&1 | tail -2
if [ -n "${FIX_SIGNED}" ]; then
  "${HDC}" install -r "${FIX_HAP}" 2>&1 | tail -2
else
  echo "Fixture 还没有签名（请先在 DevEco 里对 ${ROOT}/fixture 点一次自动签名），本次只装 Probe。"
fi

say "清空日志并拉起 Fixture"
"${HDC}" shell hilog -r >/dev/null 2>&1
"${HDC}" shell aa start -b "${FIX_BUNDLE}" -a EntryAbility 2>&1 | tail -1
sleep 3

say "抓 Probe 日志（tag=${PROTO_TAG}）"
# 先用 -x（导出后退出）；拿不到就本地有界地流式抓 4 秒，避免脚本挂住。
OUT="$("${HDC}" shell hilog -x 2>/dev/null | grep -a "${PROTO_TAG}" | tail -40)"
if [ -z "${OUT}" ]; then
  "${HDC}" shell hilog > /tmp/proto-hilog.txt 2>&1 &
  HPID=$!
  sleep 4
  kill "${HPID}" 2>/dev/null
  wait "${HPID}" 2>/dev/null
  OUT="$(grep -a "${PROTO_TAG}" /tmp/proto-hilog.txt | tail -40)"
fi
printf '%s\n' "${OUT}"

say "判定"
if printf '%s' "${OUT}" | grep -q 'P02 onConnect FIRED'; then
  echo "P02：扩展已被系统启用，且废弃 12 的 onConnect 在 API 26 真机上仍被调用。"
else
  echo "P02：未见 onConnect。要么扩展还没在「设置 → 辅助功能 → 无障碍」里启用，要么该废弃回调已不再投递。"
fi
printf '%s' "${OUT}" | grep -q 'P03 event#' && echo "P03：收到事件。" || echo "P03：未收到事件。"
printf '%s' "${OUT}" | grep -q 'P04 READ_OK' && echo "P04：节点查询可用（与官方「不支持节点查询」的说法不符）。" || true
printf '%s' "${OUT}" | grep -q 'P04 READ_FAILED' && echo "P04：节点查询报错，错误码见上面 READ_FAILED 行。" || true

say "下一步（若判定为未见）"
echo "1) 给 fixture 生成签名：DevEco 打开 ${ROOT}/fixture → File → Project Structure → Signing Configs → 自动签名"
echo "2) 启用扩展：手机 设置 → 辅助功能 → 无障碍 → 找到本应用并开启"
echo "3) 重新跑本脚本"
