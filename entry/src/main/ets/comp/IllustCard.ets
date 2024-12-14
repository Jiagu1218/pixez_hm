import { ApiClient } from "../network/ApiClient"
import { Illust } from "../network/model/Illust"
import { HttpImage } from "./HttpImage"
import { router, UIUtils } from "@kit.ArkUI"
import utils from "@arkts.utils"

@ComponentV2
export struct IllustCard{
  @Require @Param illust:Illust
  @Local aRatio:number = 16/9
  @Local like:boolean = false
  aboutToAppear(): void {
    this.aRatio = this.illust.width/this.illust.height
    this.like = this.illust.is_bookmarked
  }

  build() {
    Column(){
      HttpImage({url: this.illust.image_urls.large,aRatio:this.aRatio,br:{topLeft:$r('sys.float.ohos_id_card_border_radius'),topRight:$r('sys.float.ohos_id_card_border_radius')}})
      Row(){
        Column({space:6}){
          Text(this.illust.title).maxLines(1).fontSize(16).fontWeight(500)
          Text(this.illust.user.name).maxLines(1).fontSize(14).fontWeight(400)
        }.justifyContent(FlexAlign.SpaceAround)
        .padding({left:6})
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        SymbolGlyph(this.like?$r('sys.symbol.heart_fill'):$r('sys.symbol.heart'))
          .fontColor(this.like?[Color.Red]:[Color.Gray])
          .onClick(()=>{
          if (this.like) {
            ApiClient.postUnLikeIllust(this.illust.id).then(res=>{
              this.like = false
              console.info('取消点赞成功', res)
            })
          }else {
            ApiClient.postLikeIllust( this.illust.id, 'public').then(res=>{
              this.like = true
              console.info('点赞成功', res)
            })
          }
        }).width(48)
      }.borderRadius({bottomLeft:$r('sys.float.ohos_id_card_border_radius'),bottomRight:$r('sys.float.ohos_id_card_border_radius')})
    }.borderRadius($r('sys.float.ohos_id_card_border_radius'))
    .backgroundColor(Color.Orange)
    .onClick(()=>{
      router.pushUrl({
        url: 'pages/IllustDetailPage',
        params: {
          illustId: this.illust.id
        }
      })
    })
  }
}