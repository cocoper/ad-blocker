/**
 * PROTOTYPE — ClearStart G0 Fixture 的内容页（抛弃式，非生产代码）
 * 作用：给出「广告已消失、进入内容页」的正向标志，供 P05/P06 观察。
 */
import router from '@ohos.router';

@Entry
@Component
struct Content {
  build() {
    Column({ space: 16 }) {
      Text('内容页').fontSize(32).fontWeight(FontWeight.Bold).id('fixture_content')
      Button('返回').onClick(() => {
        router.back();
      })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
  }
}
