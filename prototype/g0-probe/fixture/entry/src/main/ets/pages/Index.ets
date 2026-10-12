/**
 * PROTOTYPE — ClearStart G0 Fixture（抛弃式目标端，绝不进入生产制品）
 * 三个模式：A 倒计时后出现可点击的「跳过」；B 有广告但控件不可点击；C 静默页（无广告）。
 * 只用于给 Probe 提供可控的事件源与页面结构，不做任何真实广告行为。
 */
import router from '@ohos.router';

@Entry
@Component
struct Index {
  @State mode: number = 0;
  @State left: number = 3;
  private timerId: number = -1;

  aboutToAppear(): void {
    this.restart();
  }

  aboutToDisappear(): void {
    this.stopTimer();
  }

  private restart(): void {
    this.stopTimer();
    if (this.mode === 0) {
      this.left = 3;
      this.timerId = setInterval(() => {
        if (this.left > 0) {
          this.left = this.left - 1;
        }
        if (this.left <= 0) {
          this.stopTimer();
        }
      }, 1000);
    }
  }

  private stopTimer(): void {
    if (this.timerId !== -1) {
      clearInterval(this.timerId);
      this.timerId = -1;
    }
  }

  private switchMode(m: number): void {
    this.mode = m;
    this.restart();
  }

  private modeText(): string {
    if (this.mode === 0) {
      return 'A 倒计时';
    }
    if (this.mode === 1) {
      return 'B 不可点击';
    }
    return 'C 静默';
  }

  build() {
    Column({ space: 16 }) {
      Row({ space: 8 }) {
        Button('A 倒计时').fontSize(13).onClick(() => this.switchMode(0))
        Button('B 不可点击').fontSize(13).onClick(() => this.switchMode(1))
        Button('C 静默').fontSize(13).onClick(() => this.switchMode(2))
      }

      if (this.mode === 2) {
        Text('静默页：没有广告，也没有可跳过控件').fontSize(18).id('fixture_silent')
      } else {
        Text('广告').fontSize(40).fontWeight(FontWeight.Bold).id('fixture_ad_label')
        if (this.mode === 0) {
          Button(this.left > 0 ? ('跳过 ' + this.left) : '跳过')
            .enabled(this.left === 0)
            .id('fixture_skip')
            .onClick(() => {
              router.pushUrl({ url: 'pages/Content' });
            })
        } else {
          Button('跳过（不可点击）').enabled(false).id('fixture_skip_disabled')
        }
      }

      Text('当前模式：' + this.modeText()).fontSize(13)
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
