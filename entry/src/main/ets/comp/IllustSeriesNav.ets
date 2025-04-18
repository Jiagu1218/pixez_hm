import { ApiClient } from "../network/ApiClient";
import { Illust } from "../network/model/Illust";
import { IllustSeriesIllustResponse } from "../network/response/IllustSeriesIllustResponse";
import { IllustSeriesResponse } from "../network/response/IllustSeriesResponse";
import { IllustRouterParam } from "../param/IllustRouterParam";
import { HttpImage } from "./HttpImage";

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
        HttpImage({ url: this.nextIllust.image_urls.square_medium, aRatio: 1 })
          .width(48)
          .borderRadius(12)
          .shadow({
            radius: 8,
            color: '#00000010',
            offsetX: 0,
            offsetY: 4
          })
        Column() {
          Text('下一话')
            .fontSize(16)
            .fontWeight(FontWeight.Bold)
            .layoutWeight(1)
          Text(this.nextIllust.title)
            .fontSize(14)
            .layoutWeight(1)
            .maxLines(1)
        }
        .height(48)
        .alignItems(HorizontalAlign.Start)
      } else {
        Button('没有下一话')
          .layoutWeight(1)
          .enabled(false)
          .backgroundColor('#E0E0E0')
          .fontColor('#666666')
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
    Row() {
      if (this.prevIllust) {
        Button('上一话')
          .layoutWeight(1)
          .backgroundColor('#2196F3')
          .fontColor('#FFFFFF')
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
          .fontColor('#666666')
      }
      Button('系列作品预览')
        .layoutWeight(1)
        .backgroundColor('#2196F3')
        .fontColor('#FFFFFF')
        .onClick(() => {
          this.getIllustSeries(this.seriesId)
        })
    }
    .width('100%')
    .height(48)
  }

  build() {
    Column() {
      this.NextIllustButton()
      this.PrevIllustButton()
    }
    .height(96)
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: '#00000010',
      offsetX: 0,
      offsetY: 4
    })
  }
}