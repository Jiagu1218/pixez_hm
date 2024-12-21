import { LengthUnit, router } from '@kit.ArkUI';
import { HttpImage } from '../comp/HttpImage';
import { ApiClient } from '../network/ApiClient';
import { WebViewNovel } from '../network/model/WebViewNovel';
import { HtmlUtil } from '../network/util/HtmlUtil';

interface Params {
  novelId: number;
}

@Entry
@ComponentV2
struct NovelDetailPage {
  @Local private novelId: number = 0
  @Local private webViewNovel: WebViewNovel | null = null
  @Local private content:Array<string> = []
  private scroller: Scroller = new Scroller()

  aboutToAppear(): void {
    const params = router.getParams() as Params
    //uploadedimage 案例id：23617228 pixivimage 案例id：22354955
    this.novelId = params.novelId
    this.getWebViewNovel()
  }
  @Monitor('webViewNovel')
  dealWithText(){
    const illusts:Array<string> = []
    if (!(this.webViewNovel!.illusts instanceof Array) ||!(this.webViewNovel!.images instanceof Array)) {
      illusts.push(...this.webViewNovel!.text
        .split(/\[(uploadedimage:\d+(?:-\d+)?)\]|\[(pixivimage:\d+(?:-\d+)?)\]/g)
        .filter(item=>item != undefined && item!= '')
      )
    }else {
      illusts.push(this.webViewNovel!.text??'')
    }
    this.content = illusts
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
            this.scroller.scrollTo({ yOffset:0,xOffset:0,animation:true})
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
      Column({space:16}) {
        if (this.webViewNovel) {
          Column() {
            HttpImage({ url: this.webViewNovel.coverUrl })
            Row(){
              Text(this.webViewNovel.title)
                .fontSize(36)
                .fontWeight(FontWeight.Bold)
                .margin({ top: 10 })
            }.width('100%')
            Row(){
              Text(this.webViewNovel.cdate).fontSize(14)
            }.width('100%')
            Flex({ wrap: FlexWrap.Wrap, space: { main: { value: 8, unit: LengthUnit.VP } } }) {
              ForEach(this.webViewNovel.tags, (item: string, index) => {
                Text(item).fontSize(14).borderColor(Color.Gray).borderWidth(1).borderRadius(4)
              })
            }
          }
          Divider()
          Column(){
            //TODO 处理富文本信息
            Text(this.webViewNovel.caption.replaceAll('<br />', '\n')).fontSize(16).fontWeight(FontWeight.Bold).backgroundColor(Color.Gray).borderRadius(4)
          }.width('80%')
          Divider()
          Column(){
            ForEach(this.content, (item: string, index) => {
              if (item.match(/pixivimage:(\d+(?:-\d+)?)/)) {
                HttpImage({
                  url: this!.webViewNovel!.illusts![item.replace(/pixivimage:(\d+(?:-\d+)?)/,
                    '$1').toString()].illust.images.medium
                })
              } else if(item.match(/uploadedimage:(\d+(?:-\d+)?)/)) {
                HttpImage({
                  url: this!.webViewNovel!.images![item.replace(/uploadedimage:(\d+(?:-\d+)?)/,
                    '$1').toString()].urls.original
                })
              }else {
                Text(item)
              }
            })
          }
          if (this.webViewNovel.seriesNavigation){
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
                if (this.webViewNovel!.seriesNavigation?.prevNovel) {
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
                if (this.webViewNovel!.seriesNavigation?.nextNovel) {
                  this.novelId = this.webViewNovel!.seriesNavigation.nextNovel.id
                }
              })
            }.width('100%')
            .justifyContent(FlexAlign.SpaceBetween)
          }
        }
      }.width('100%')
    }
    .height('100%')
    .width('100%')
  }
}