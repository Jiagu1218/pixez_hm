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
                Text(){
                  Span('粉丝：')
                  Span(this.userDetail?.profile.total_follow_users.toString())
                  Span('\t\t\t\t')
                  Span('关注：')
                  Span(this.userDetail?.profile.total_mypixiv_users.toString())
                }.borderRadius($r('sys.float.ohos_id_blur_style_thin_radius'))
                .fontSize($r('sys.float.Subtitle_S'))
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
                IllustWaterFlow({firstPage:()=>this.getUserIllusts(),marginTop:56})
              }.tabBar(`作品 ${this.userDetail?.profile.total_illusts}`)
              TabContent(){
                IllustWaterFlow({firstPage:()=>this.getUserManga(),marginTop:56})
              }.tabBar(`漫画 ${this.userDetail?.profile.total_manga}`)
              TabContent(){
                IllustWaterFlow({firstPage:()=>this.getBookmarksIllust(),marginTop:56})
              }.tabBar(`收藏`)
              TabContent(){
                Column({space:16}){
                  Row().height(40).width('100%')
                  if(this.userDetail?.user.comment && this.userDetail?.user.comment.length > 0){
                    Row(){
                      Text(this.userDetail.user.comment)
                    }.width('100%')
                    .backgroundColor(Color.Gray)
                    .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
                    Divider()
                  }
                  Row(){
                    Text('昵称：')
                    Blank()
                    Text(this.userDetail?.user.name)
                  }.width('100%')
                  Divider()
                  Row(){
                    Text('ID:')
                    Blank()
                    Text(this.userDetail?.user.id.toString())
                  }.width('100%')
                  Divider()

                  if ((this.userDetail?.profile.birth && this.userDetail.profile.birth.length>0) ||
                      (this.userDetail?.profile.birth_day && this.userDetail.profile.birth_day.length > 0)
                  ){
                    Row(){
                      Text('生日：')
                      Blank()
                      Text(){
                        if (this.userDetail?.profile_publicity.birth_year === 'public'){
                          Span(this.userDetail.profile.birth)
                        }
                        Span(' ')
                        if (this.userDetail?.profile_publicity.birth_day === 'public'){
                          Span(this.userDetail.profile.birth_day)
                        }
                      }
                    }.width('100%')
                    Divider()
                  }
                  if (this.userDetail?.profile_publicity.gender === 'public' && this.userDetail?.profile.gender.length > 0 ){
                    Row(){
                      Text('性别：')
                      Blank()
                      Text(this.userDetail.profile.gender)
                    }.width('100%')
                    Divider()
                  }
                  if (this.userDetail?.profile_publicity.region === 'public' && this.userDetail?.profile.region.length > 0){
                    Row(){
                      Text('地区：')
                      Blank()
                      Text(this.userDetail.profile.region)
                    }.width('100%')
                    Divider()
                  }
                  if (this.userDetail?.profile_publicity.job === 'public' && this.userDetail?.profile.job.length > 0){
                    Row(){
                      Text('职业：')
                      Blank()
                      Text(this.userDetail.profile.job)
                    }.width('100%')
                    Divider()
                  }
                  if (this.userDetail?.profile_publicity.pawoo && this.userDetail?.profile.pawoo_url){
                    Row(){
                      Text('PAWOO：')
                      Blank()
                      Hyperlink(this.userDetail.profile.pawoo_url)
                    }.width('100%')
                    Divider()
                  }
                  if (this.userDetail?.profile.webpage && this.userDetail.profile.webpage.length > 0){
                    Row(){
                      Text('网站：')
                      Blank()
                      Hyperlink(this.userDetail.profile.webpage)
                    }.width('100%')
                    Divider()
                  }
                  if (this.userDetail?.profile.twitter_url){
                    Row(){
                      Text('Twitter：')
                      Blank()
                      Hyperlink(this.userDetail.profile.twitter_url,this.userDetail.profile.twitter_account)
                    }.width('100%')
                    Divider()
                  }
                }.width('100%')
                .height('100%')
              }.tabBar('详情')
            }.barOverlap(true)
            .barBackgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
          }.height('100%')
        }
      }.sticky(StickyStyle.Header)
      .height('100%')
      .width('100%')
      .scrollBar(BarState.Off)
    }.hideTitleBar(true)
  }
}
@Builder export function UserDetailPageBuilder(){
  UserDetailPage()
}