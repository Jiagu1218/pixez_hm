import { ApiClient } from "../network/ApiClient"
import { Illust } from "../network/model/Illust"
import { UserPreview } from "../network/model/UserPreview"
import { IllustRouterParam } from "../param/IllustRouterParam"
import { HttpImage } from "./HttpImage"

@ComponentV2
export struct UserPreviewCard{
  private pathStack: NavPathStack|undefined = undefined
  @Require @Param userPreview:UserPreview
  @Local follow: boolean = false
  aboutToAppear(): void {
    this.pathStack = this.queryNavigationInfo()?.pathStack
    this.follow = this.userPreview.user.is_followed
  }
  build() {
    Column(){
      if (this.userPreview.illusts.length>0){
        Grid(){
          Repeat<Illust>(this.userPreview.illusts).each((item)=>{
            GridItem(){
              HttpImage({url: item.item.image_urls.square_medium,aRatio:1})
            }.onClick(()=>{
              this.pathStack?.pushPath({
                name: 'illustDetailPage',
                param: {illustId: item.item.id} as IllustRouterParam
              })
            })
          }).key((item)=>item.id.toString())
        }.columnsTemplate('1fr 1fr 1fr')
      }
      Row({space:16}){
        HttpImage({url: this.userPreview.user.profile_image_urls.medium,aRatio:1,br:20}).width(40)
        Text(this.userPreview.user.name).layoutWeight(1).maxLines(2)
        Button(this.follow?'已关注':'关注')
          .onClick(()=>{
            if (!this.userPreview.user){
              return
            }
            if (this.follow) {
              ApiClient.postUnFollowUser(this.userPreview.user.id).then(()=>{
                this.follow = false
              })
            }else {
              ApiClient.postFollowUser(this.userPreview.user.id,'public').then(()=>{
                this.follow = true
              })
            }
          })
      }.width('100%')
    }.width('100%')
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
  }
}