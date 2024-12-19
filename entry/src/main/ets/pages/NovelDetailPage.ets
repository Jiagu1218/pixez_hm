import { LengthUnit, router } from '@kit.ArkUI';
import { HttpImage } from '../comp/HttpImage';
import { ApiClient } from '../network/ApiClient';
import { Novel } from '../network/model/Novel';
import { WebViewNovel } from '../network/model/WebViewNovel';
import { NovelDetailResponse } from '../network/response/NovelDetailResponse';
import { HtmlUtil } from '../network/util/HtmlUtil';

interface Params {
  novelId: number;
}

@Entry
@ComponentV2
struct NovelDetailPage {
  @Local private novelId: number = 0
  @Local private novel: Novel | null = null
  @Local private webViewNovel: WebViewNovel | null = null
  private scroller: Scroller = new Scroller()

  aboutToAppear(): void {
    const params = router.getParams() as Params
    this.novelId = params.novelId
    this.getWebViewNovel()
  }

  getWebViewNovel() {
    ApiClient.webviewNovel(this.novelId).then(res => {
      if (res) {
        if (res?.headers['content-type']?.match('text/html')) {
          const body = res.toString()
          const jsonStr = HtmlUtil.getNovelJson(body!)
          console.info('11111', body, jsonStr)
          if (jsonStr) {
            const json = JSON.parse(jsonStr) as WebViewNovel
            console.info('webviewNovel', json)
            this.webViewNovel = json
          }
        }
      }
    })
  }

  @Monitor('novelId')
  watchNovelId() {
    this.getWebViewNovel()
  }

  build() {
    Scroll(this.scroller) {
      Column() {
        if (this.webViewNovel) {
          Column() {
            HttpImage({ url: this.webViewNovel.coverUrl })
            Text(this.webViewNovel.title)
              .fontSize(36)
              .fontWeight(FontWeight.Bold)
              .margin({ top: 10 })
            Flex({ wrap: FlexWrap.Wrap, space: { main: { value: 8, unit: LengthUnit.VP } } }) {
              ForEach(this.webViewNovel.tags, (item: string, index) => {
                Text(item).fontSize(14).borderColor(Color.Gray).borderWidth(1).borderRadius(4)
              })
            }
          }

          Divider()
          Text(this.webViewNovel.text)
          Divider()
          Row() {
            Text() {
              SymbolSpan($r('sys.symbol.arrow_left'))
              Span(' ')
              Span(this.webViewNovel.seriesNavigation.prevNovel?.title ?? '')
            }.maxLines(2)
            .width('40%')
            .visibility(this.webViewNovel.seriesNavigation.prevNovel ? Visibility.Visible : Visibility.Hidden)
            .onClick(() => {
              if (this.webViewNovel!.seriesNavigation.prevNovel) {
                this.novelId = this.webViewNovel!.seriesNavigation.prevNovel.id
              }
            })

            Text() {
              Span(this.webViewNovel.seriesNavigation.nextNovel?.title ?? '')
              Span(' ')
              SymbolSpan($r('sys.symbol.arrow_right'))
            }.maxLines(2)
            .width('40%')
            .visibility(this.webViewNovel.seriesNavigation.nextNovel ? Visibility.Visible : Visibility.Hidden)
            .onClick(() => {
              if (this.webViewNovel!.seriesNavigation.nextNovel) {
                this.novelId = this.webViewNovel!.seriesNavigation.nextNovel.id
              }
            })
          }.width('100%')
          .justifyContent(FlexAlign.SpaceBetween)
        }
      }.width('100%')
    }
    .height('100%')
    .width('100%')
  }
}