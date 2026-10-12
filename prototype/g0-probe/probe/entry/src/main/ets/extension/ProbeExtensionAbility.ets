/**
 * PROTOTYPE — ClearStart G0 Probe（抛弃式，非生产代码，勿并入 main 分支）
 *
 * 要回答的问题：普通开发者签名的 accessibility 扩展，在 API 26 真机上能否
 *   P02 被系统启用（onConnect 是否被调用 —— 该回调官方标注 API 12 废弃）
 *   P03 收到跨应用事件
 *   P04 读到跨应用节点（getWindowRootElement 是否真的可用 —— 官方口径否认）
 *
 * 日志纪律：只记录事件类型、目标包名、节点计数、错误码。绝不打印屏幕文本。
 * 观察窗口/预算（粗版）：最多 60 个节点、深度 6。
 */
import { AccessibilityExtensionAbility, AccessibilityEvent, AccessibilityElement } from '@kit.AccessibilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';
import { KeyEvent } from '@kit.InputKit';

const DOMAIN = 0x0000;
const TAG = 'ClearStartProbe';
const MAX_NODES = 60;
const MAX_DEPTH = 6;

class WalkNode {
  el: AccessibilityElement;
  d: number;

  constructor(el: AccessibilityElement, d: number) {
    this.el = el;
    this.d = d;
  }
}

class TreeStats {
  nodes: number = 0;
  clickable: number = 0;
  visible: number = 0;
  depth: number = 0;
  bundle: string = '';
  firstClickableBundle: string = '';
}

export default class ProbeExtensionAbility extends AccessibilityExtensionAbility {
  private events: number = 0;
  private readOk: number = 0;
  private readFail: number = 0;
  private lastErrCode: number = 0;

  onConnect(): void {
    this.events = 0;
    this.readOk = 0;
    this.readFail = 0;
    hilog.info(DOMAIN, TAG, 'P02 onConnect FIRED (deprecated since 12, still invoked by system)');
  }

  onDisconnect(): void {
    hilog.info(DOMAIN, TAG, 'onDisconnect fired: events=%{public}d readOk=%{public}d readFail=%{public}d lastErr=%{public}d',
      this.events, this.readOk, this.readFail, this.lastErrCode);
  }

  onAccessibilityEvent(event: AccessibilityEvent): void {
    this.events++;
    const et: string = String(event.eventType);
    hilog.info(DOMAIN, TAG, 'P03 event#%{public}d type=%{public}s', this.events, et);
    this.probeTree(this.events);
  }

  onKeyEvent(keyEvent: KeyEvent): boolean {
    hilog.info(DOMAIN, TAG, 'onKeyEvent fired (not consumed)');
    return false;
  }

  private probeTree(seq: number): void {
    this.context.getWindowRootElement()
      .then((root: AccessibilityElement) => {
        return this.walk(root);
      })
      .then((s: TreeStats) => {
        this.readOk++;
        hilog.info(DOMAIN, TAG,
          'P04 READ_OK seq=%{public}d bundle=%{public}s nodes=%{public}d depth=%{public}d clickable=%{public}d visible=%{public}d clickBundle=%{public}s',
          seq, s.bundle, s.nodes, s.depth, s.clickable, s.visible, s.firstClickableBundle);
      })
      .catch((e: BusinessError) => {
        this.readFail++;
        this.lastErrCode = e.code;
        hilog.error(DOMAIN, TAG, 'P04 READ_FAILED seq=%{public}d code=%{public}d msg=%{public}s',
          seq, e.code, e.message);
      });
  }

  private async walk(root: AccessibilityElement): Promise<TreeStats> {
    const s = new TreeStats();
    const queue: WalkNode[] = [new WalkNode(root, 0)];
    let head: number = 0;
    while (head < queue.length && s.nodes < MAX_NODES) {
      const cur: WalkNode = queue[head];
      head++;
      s.nodes++;
      if (cur.d > s.depth) {
        s.depth = cur.d;
      }
      try {
        const b: string = await cur.el.attributeValue('bundleName');
        if (s.bundle === '') {
          s.bundle = b;
        }
        const clickable: boolean = await cur.el.attributeValue('clickable');
        if (clickable) {
          s.clickable++;
          if (s.firstClickableBundle === '') {
            s.firstClickableBundle = b;
          }
        }
        const vis: boolean = await cur.el.attributeValue('isVisible');
        if (vis) {
          s.visible++;
        }
        if (cur.d < MAX_DEPTH) {
          const kids: Array<AccessibilityElement> = await cur.el.attributeValue('children');
          if (kids !== undefined && kids !== null) {
            for (let i = 0; i < kids.length; i++) {
              queue.push(new WalkNode(kids[i], cur.d + 1));
            }
          }
        }
      } catch (e) {
        const err = e as BusinessError;
        this.lastErrCode = err.code;
        hilog.warn(DOMAIN, TAG, 'node attr read failed code=%{public}d', err.code);
      }
    }
    return s;
  }
}
