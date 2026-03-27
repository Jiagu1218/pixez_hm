import { ApiClient, HttpImage, Illust, UserPreview } from "common"
import { IllustRouterParam } from "../param/IllustRouterParam"

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
    Column({ space: 14 }) {
      if (this.userPreview.illusts.length > 0) {
        Grid() {
          Repeat<Illust>(this.userPreview.illusts).each((item) => {
            GridItem() {
              HttpImage({
                url: item.item.image_urls.square_medium,
                aRatio: 1,
                br: 8
              })
            }
            .onClick(() => {
              this.pathStack?.pushPath({
                name: 'artWorksPage',
                param: { illustId: item.item.id } as IllustRouterParam
              })
            })
          }).key((item) => item.id.toString())
        }
        .columnsTemplate('1fr 1fr 1fr')
        .columnsGap(8)
        .rowsGap(8)
      }
      Row({ space: 14 }) {
        HttpImage({
          url: this.userPreview.user.profile_image_urls.medium,
          aRatio: 1,
          br: 20
        })
          .width(44)
          .height(44)
        Text(this.userPreview.user.name)
          .layoutWeight(1)
          .maxLines(2)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1E293B')
        Button(this.follow ? '已关注' : '关注')
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .height(36)
          .padding({ left: 16, right: 16 })
          .borderRadius(10)
          .backgroundColor(this.follow ? '#F1F5F9' : $r('sys.color.brand'))
          .fontColor(this.follow ? '#475569' : Color.White)
          .onClick(() => {
            if (!this.userPreview.user) {
              return
            }
            if (this.follow) {
              ApiClient.postUnFollowUser(this.userPreview.user.id).then(() => {
                this.follow = false
              })
            } else {
              ApiClient.postFollowUser(this.userPreview.user.id, 'public').then(() => {
                this.follow = true
              })
            }
          })
      }
      .width('100%')
      .padding({ top: 4 })
    }
    .width('100%')
    .padding({ left: 14, right: 14, top: 14, bottom: 14 })
    .borderRadius(16)
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
    .border({
      width: 1,
      color: '#EEF2F6'
    })
    .shadow({
      radius: 12,
      color: '#0000000C',
      offsetX: 0,
      offsetY: 4
    })
  }
}