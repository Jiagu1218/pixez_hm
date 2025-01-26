import { ApiClient } from "../network/ApiClient";
import { Illust } from "../network/model/Illust";
import { IllustSeriesIllustResponse } from "../network/response/IllustSeriesIllustResponse";
import { IllustSeriesResponse } from "../network/response/IllustSeriesResponse";
import { IllustRouterParam } from "../param/IllustRouterParam";
import { HttpImage } from "./HttpImage";

@ComponentV2
export struct IllustSeriesNav{
  @Require @Param illustId: number;
  @Require @Param seriesId: number;
  @Local private prevIllust: Illust|null = null;
  @Local private nextIllust: Illust|null = null;
  private pathStack:NavPathStack|undefined = undefined
  aboutToAppear(): void {
    this.pathStack = this.queryNavigationInfo()?.pathStack
    this.getPreAndNextInfo()
  }
  getPreAndNextInfo(){
    ApiClient.getIllustSeriesIllust(this.illustId).then(res=>{
      if (res) {
        const resp = res.toJSON() as IllustSeriesIllustResponse
        this.prevIllust = resp.illust_series_context.prev
        this.nextIllust = resp.illust_series_context.next
      }
    })
  }

  getIllustSeries(seriesId: number){
    ApiClient.getIllustSeries(seriesId).then(res=>{
      if (res) {
        const resp = res.toJSON() as IllustSeriesResponse
        console.info('MangaSeries',resp)
      }
    })
  }

  build() {
    Column(){
      Row(){
        if (this.nextIllust){
          HttpImage({url: this.nextIllust.image_urls.square_medium,aRatio:1}).width(48)
          Column(){
            Text('下一话').layoutWeight(1)
            Text(this.nextIllust.title).layoutWeight(1).maxLines(1)
          }.height(48)
          .alignItems(HorizontalAlign.Start)
        }else {
          Button('没有下一话').layoutWeight(1).enabled(false)
        }
      }.width('100%')
      .height(40)
      .onClick(() => {
        if (this.nextIllust) {
          this.pathStack?.replacePath({
            name: 'artWorksPage',
            param: {illustId:this.nextIllust.id} as IllustRouterParam
          })
        }
      })
      Row(){
        if (this.prevIllust){
          Button('上-话').layoutWeight(1)
            .onClick(() => {
              if (this.prevIllust) {
                this.pathStack?.replacePath({
                  name: 'artWorksPage',
                  param: {illustId:this.prevIllust.id} as IllustRouterParam
                })
              }
            })
        }else {
          Text('没有上一话').layoutWeight(1)
        }
        Button('系列作品预览').layoutWeight(1)
        .onClick(() => {
          this.getIllustSeries(this.seriesId)
        })
      }.width('100%')
      .height(48)
    }.height(96)
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
  }
}