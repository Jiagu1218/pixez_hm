import { ApiClient } from "../network/ApiClient"
import { Illust } from "../network/model/Illust"
import { UserPreview } from "../network/model/UserPreview"
import { HttpImage } from "./HttpImage"

@ComponentV2
export struct UserPreviewCard{
  @Require @Param userPreview:UserPreview
  @Local follow: boolean = false
  aboutToAppear(): void {
    this.follow = this.userPreview.user.is_followed
  }
  build() {
    Column(){
      if (this.userPreview.illusts.length>0){
        Grid(){
          Repeat<Illust>(this.userPreview.illusts).each((item)=>{
            GridItem(){
              HttpImage({url: item.item.image_urls.square_medium,aRatio:1})
            }
          }).key((item)=>item.id.toString())
        }.columnsTemplate('1fr 1fr 1fr')
      }
      Row({space:16}){
        HttpImage({url: this.userPreview.user.profile_image_urls.medium,aRatio:1,br:20}).width(40)
        Text(this.userPreview.user.name)
        Blank()
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
  }
}