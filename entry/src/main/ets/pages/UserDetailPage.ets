import { ApiClient } from '../network/ApiClient'
import { UserDetailResponse } from '../network/response/UserDetailResponse'
import { HttpImage } from '../comp/HttpImage'
import { UserIllustResponse } from '../network/response/UserIllustResponse'
import { BookmarksIllustResponse } from '../network/response/BookmarksIllustResponse'
import { UserRouterParam } from '../param/UserRouterParam'
import { IllustWaterFlow } from '../comp/IllustWaterFlow'

@Entry
@ComponentV2
struct UserDetailPage {
  private userId:number = 0
  private pathStack:NavPathStack|undefined = undefined
  @Local private userDetail:UserDetailResponse|null = null

  aboutToAppear(): void {
    this.pathStack = this.queryNavigationInfo()?.pathStack
    if (this.pathStack){
      const param = this.pathStack.getParamByName('userDetailPage').pop() as UserRouterParam
      this.userId = param.userId
    }
    ApiClient.getUserDetail(this.userId).then(res => {
      console.info('1111',res)
      if (res) {
        const resp = res.toJSON() as UserDetailResponse
        this.userDetail = resp
        console.info('2222',resp)
      }
    })
    // ApiClient.getUserBookmarkTagsIllust(this.userId).then(res => {
    //   if (res) {
    //     const resp = res.toJSON() as UserBookmarkTagsIllustResponse
    //   }
    // })
  }

  getUserIllusts(): Promise<UserIllustResponse|null>{
    return ApiClient.getUserIllusts(this.userId).then(res => {
      if (res) {
        return res.toJSON() as UserIllustResponse
      }else {
        return null
      }
    })
  }

  getUserManga(): Promise<UserIllustResponse|null>{
    return ApiClient.getUserIllusts(this.userId,'manga').then(res => {
      if (res) {
        return res.toJSON() as UserIllustResponse
      }else {
        return null
      }
    })
  }

  getBookmarksIllust(): Promise<BookmarksIllustResponse|null>{
    return ApiClient.getBookmarksIllust({
      userId:this.userId,
      restrict:'public'
    }).then(res => {
      if (res) {
        return res.toJSON() as BookmarksIllustResponse
      }else {
        return null
      }
    })
  }

  build() {
    NavDestination(){
      Column() {
        List(){
          ListItem(){
            Stack(){
              if (this.userDetail?.profile.background_image_url){
                HttpImage({url:this.userDetail.profile.background_image_url})
                  // .blur(20)
              }
              if (this.userDetail){
                Column(){
                  HttpImage({url:this.userDetail.user.profile_image_urls.medium,aRatio:1,br:30}).width(60)
                  Text(this.userDetail.user.name).fontSize($r('sys.float.Subtitle_L')).fontWeight(FontWeight.Bold)
                    .borderRadius($r('sys.float.ohos_id_blur_style_thin_radius'))
                    .padding(4)
                    .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
                }.alignItems(HorizontalAlign.Start)
              }
            }.width('100%')
            .alignContent(Alignment.BottomStart)
          }
          ListItemGroup(){
            ListItem(){
              Tabs(){
                TabContent(){
                  IllustWaterFlow({firstPage:()=>this.getUserIllusts()})
                }.tabBar('作品')
                TabContent(){
                  IllustWaterFlow({firstPage:()=>this.getUserManga()})
                }.tabBar('漫画')
                TabContent(){
                  IllustWaterFlow({firstPage:()=>this.getBookmarksIllust()})
                }.tabBar('收藏')
                TabContent(){

                }.tabBar('详情')
              }
            }.height('100%')
          }
        }.sticky(StickyStyle.Header)
        .scrollBar(BarState.Off)
      }
      .height('100%')
      .width('100%')
    }.hideTitleBar(true)
  }
}
@Builder export function UserDetailPageBuilder(){
  UserDetailPage()
}