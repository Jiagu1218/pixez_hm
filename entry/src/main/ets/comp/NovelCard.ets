import { uiEffect } from "@kit.ArkGraphics2D"
import { Novel } from "../network/model/Novel"
import { HttpImage } from "./HttpImage"

@ComponentV2
export struct NovelCard {
  @Require @Param novel:Novel
  @Local aRatio:number = 9/16
  @Local like:boolean = false
  @Param limitLevel:number = 6
  // @Local filter:Filter = uiEffect.createFilter()
  aboutToAppear(): void {
    this.like = this.novel.is_bookmarked
  }
  build() {
    Row(){
      Column(){
        HttpImage({url: this.novel.image_urls.medium,aRatio:this.aRatio})
      }.width('30%')
      Column(){
        Text(this.novel.title).maxLines(1).fontSize(16).fontWeight(500)
        Text(this.novel.user.name).maxLines(1).fontSize(14).fontWeight(400)
      }.layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
    }.borderRadius($r('sys.float.ohos_id_card_border_radius'))
    .width('100%')
    .aspectRatio(16/9)
    .backgroundColor(Color.Orange)
    .onClick(()=>{

    })
  }
}