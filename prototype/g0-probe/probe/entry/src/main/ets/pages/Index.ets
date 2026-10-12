/**
 * PROTOTYPE — ClearStart G0 Probe 宿主页（抛弃式，非生产代码）
 * 作用：① 告诉人去哪儿看证据；② 开机自检——用公开 API 查系统当前认得的无障碍服务清单，
 *       把结果同时写进 hilog（tag=ClearStartProbeHost），这样「系统到底有没有把我们当成无障碍服务」
 *       不用靠人眼看设置页，agent 自己就能读。
 */
import accessibility from '@ohos.accessibility';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { BusinessError } from '@kit.BasicServicesKit';

const DOMAIN = 0x0000;
const TAG = 'ClearStartProbeHost';

@Entry
@Component
struct Index {
  @State lines: string = '';

  aboutToAppear(): void {
    this.selfCheck();
  }

  private selfCheck(): void {
    let out: string = '';
    try {
      const open: boolean = accessibility.isOpenAccessibilitySync();
      out += 'isOpenAccessibilitySync=' + open + '\n';
      hilog.info(DOMAIN, TAG, 'HOST isOpenAccessibilitySync=%{public}s', String(open));
    } catch (e) {
      const err = e as BusinessError;
      out += 'isOpenAccessibilitySync ERR code=' + err.code + '\n';
      hilog.error(DOMAIN, TAG, 'HOST isOpenAccessibilitySync failed code=%{public}d', err.code);
    }

    try {
      const l1 = accessibility.getAccessibilityExtensionListSync('all', 'install');
      out += this.fmt('install', l1.length, l1);
    } catch (e) {
      const err = e as BusinessError;
      out += 'list install ERR code=' + err.code + '\n';
      hilog.error(DOMAIN, TAG, 'HOST list install failed code=%{public}d', err.code);
    }
    try {
      const l2 = accessibility.getAccessibilityExtensionListSync('all', 'enable');
      out += this.fmt('enable', l2.length, l2);
    } catch (e) {
      const err = e as BusinessError;
      out += 'list enable ERR code=' + err.code + '\n';
      hilog.error(DOMAIN, TAG, 'HOST list enable failed code=%{public}d', err.code);
    }
    try {
      const l3 = accessibility.getAccessibilityExtensionListSync('all', 'disable');
      out += this.fmt('disable', l3.length, l3);
    } catch (e) {
      const err = e as BusinessError;
      out += 'list disable ERR code=' + err.code + '\n';
      hilog.error(DOMAIN, TAG, 'HOST list disable failed code=%{public}d', err.code);
    }
    this.lines = out;
  }

  private fmt(state: string, count: number, list: object): string {
    let names: string = '';
    const arr = list as Array<object>;
    for (let i = 0; i < arr.length; i++) {
      const info = arr[i] as Record<string, string>;
      names += info.bundleName + ' ';
    }
    hilog.info(DOMAIN, TAG, 'HOST list state=%{public}s count=%{public}d bundles=%{public}s', state, count, names);
    return 'state=' + state + ' count=' + count + ' [' + names + ']\n';
  }

  build() {
    Column({ space: 10 }) {
      Text('ClearStart G0 Probe').fontSize(22).fontWeight(FontWeight.Bold)
      Text('自检结果（同时写入 hilog，tag=ClearStartProbeHost）').fontSize(13)
      Text(this.lines).fontSize(12).textAlign(TextAlign.Start)
      Text('启用路径：设置 → 辅助功能 → 无障碍 → 找到 ClearStart Probe').fontSize(13).margin({ top: 12 })
    }
    .width('100%')
    .height('100%')
    .padding(20)
    .justifyContent(FlexAlign.Center)
  }
}
