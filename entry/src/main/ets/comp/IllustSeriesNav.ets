import { ApiClient, HttpImage, Illust, IllustSeriesIllustResponse, IllustSeriesResponse } from "common";
import { IllustRouterParam } from "../param/IllustRouterParam";

@ComponentV2
export struct IllustSeriesNav {
  @Require @Param illustId: number;
  @Require @Param seriesId: number;
  @Local private prevIllust: Illust | null = null;
  @Local private nextIllust: Illust | null = null;
  private pathStack: NavPathStack | undefined = undefined

  aboutToAppear(): void {
    this.pathStack = this.queryNavigationInfo()?.pathStack
    this.getPreAndNextInfo()
  }

  getPreAndNextInfo() {
    ApiClient.getIllustSeriesIllust(this.illustId).then(res => {
      if (res) {
        const resp = res.toJSON() as IllustSeriesIllustResponse
        this.prevIllust = resp.illust_series_context.prev
        this.nextIllust = resp.illust_series_context.next
      }
    })
  }

  getIllustSeries(seriesId: number) {
    ApiClient.getIllustSeries(seriesId).then(res => {
      if (res) {
        const resp = res.toJSON() as IllustSeriesResponse
        console.info('MangaSeries', resp)
      }
    })
  }

  @Builder
  private NextIllustButton() {
    Row() {
      if (this.nextIllust) {
        HttpImage({ url: this.nextIllust.image_urls.square_medium, aRatio: 1, br: 12 })
          .width(48)
          .shadow({
            radius: 8,
            color: '#00000014',
            offsetX: 0,
            offsetY: 3
          })
        Column() {
          Text('下一话')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1E293B')
            .layoutWeight(1)
          Text(this.nextIllust.title)
            .fontSize(14)
            .fontColor('#64748B')
            .layoutWeight(1)
            .maxLines(1)
        }
        .height(48)
        .alignItems(HorizontalAlign.Start)
      } else {
        Button('没有下一话')
          .layoutWeight(1)
          .enabled(false)
          .backgroundColor('#F1F5F9')
          .fontColor('#94A3B8')
          .borderRadius(10)
      }
    }
    .width('100%')
    .height(40)
    .onClick(() => {
      if (this.nextIllust) {
        this.pathStack?.replacePath({
          name: 'artWorksPage',
          param: { illustId: this.nextIllust.id } as IllustRouterParam
        })
      }
    })
  }

  @Builder
  private PrevIllustButton() {
    Row({ space: 10 }) {
      if (this.prevIllust) {
        Button('上一话')
          .layoutWeight(1)
          .height(44)
          .backgroundColor('#2563EB')
          .fontColor(Color.White)
          .fontWeight(FontWeight.Medium)
          .borderRadius(12)
          .onClick(() => {
            if (this.prevIllust) {
              this.pathStack?.replacePath({
                name: 'artWorksPage',
                param: { illustId: this.prevIllust.id } as IllustRouterParam
              })
            }
          })
      } else {
        Text('没有上一话')
          .layoutWeight(1)
          .fontColor('#94A3B8')
          .fontSize(14)
      }
      Button('系列作品预览')
        .layoutWeight(1)
        .height(44)
        .backgroundColor('#EEF2FF')
        .fontColor('#2563EB')
        .fontWeight(FontWeight.Medium)
        .borderRadius(12)
        .onClick(() => {
          this.getIllustSeries(this.seriesId)
        })
    }
    .width('100%')
    .height(48)
  }

  build() {
    Column({ space: 10 }) {
      this.NextIllustButton()
      this.PrevIllustButton()
    }
    .width('100%')
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
    .borderRadius(14)
    .border({
      width: 1,
      color: '#EEF2F6'
    })
    .shadow({
      radius: 12,
      color: '#00000012',
      offsetX: 0,
      offsetY: 4
    })
  }
}