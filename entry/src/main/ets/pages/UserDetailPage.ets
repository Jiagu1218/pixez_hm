import { HttpImage } from '../comp/HttpImage'
import { IllustWaterFlow } from '../comp/IllustWaterFlow'
import { UserDetailViewModel } from '../viewmodel/UserDetailViewModel'

@Entry
@ComponentV2
struct UserDetailPage {
  @Local private model:UserDetailViewModel = new UserDetailViewModel()

  aboutToAppear(): void {
    this.model.init(this.queryNavigationInfo())
  }


  build() {
    NavDestination(){
      List(){
        ListItem(){
          Stack(){
            if (this.model.userDetail?.profile.background_image_url){
              HttpImage({url:this.model.userDetail.profile.background_image_url})
              // .blur(20)
            }
            if (this.model.userDetail){
              Column(){
                HttpImage({url:this.model.userDetail.user.profile_image_urls.medium,aRatio:1,br:30}).width(60)
                Text(this.model.userDetail.user.name).fontSize($r('sys.float.Subtitle_L')).fontWeight(FontWeight.Bold)
                  .borderRadius($r('sys.float.ohos_id_blur_style_thin_radius'))
                  .padding(4)
                  .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
                Text(){
                  Span('粉丝：')
                  Span(this.model.userDetail?.profile.total_follow_users.toString())
                  Span('\t\t\t\t')
                  Span('关注：')
                  Span(this.model.userDetail?.profile.total_mypixiv_users.toString())
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
                IllustWaterFlow({firstPage:()=>this.model.getUserIllusts(),marginTop:56})
              }.tabBar(`作品 ${this.model.userDetail?.profile.total_illusts}`)
              TabContent(){
                IllustWaterFlow({firstPage:()=>this.model.getUserManga(),marginTop:56})
              }.tabBar(`漫画 ${this.model.userDetail?.profile.total_manga}`)
              TabContent(){
                IllustWaterFlow({firstPage:()=>this.model.getBookmarksIllust(),marginTop:56})
              }.tabBar(`收藏`)
              TabContent(){
                Column({space:16}){
                  Row().height(40).width('100%')
                  if(this.model.userDetail?.user.comment && this.model.userDetail?.user.comment.length > 0){
                    Row(){
                      Text(this.model.userDetail.user.comment)
                    }.width('100%')
                    .backgroundColor(Color.Gray)
                    .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
                    Divider()
                  }
                  Row(){
                    Text('昵称：')
                    Blank()
                    Text(this.model.userDetail?.user.name)
                  }.width('100%')
                  Divider()
                  Row(){
                    Text('ID:')
                    Blank()
                    Text(this.model.userDetail?.user.id.toString())
                  }.width('100%')
                  Divider()

                  if ((this.model.userDetail?.profile.birth && this.model.userDetail.profile.birth.length>0) ||
                      (this.model.userDetail?.profile.birth_day && this.model.userDetail.profile.birth_day.length > 0)
                  ){
                    Row(){
                      Text('生日：')
                      Blank()
                      Text(){
                        if (this.model.userDetail?.profile_publicity.birth_year === 'public'){
                          Span(this.model.userDetail.profile.birth)
                        }
                        Span(' ')
                        if (this.model.userDetail?.profile_publicity.birth_day === 'public'){
                          Span(this.model.userDetail.profile.birth_day)
                        }
                      }
                    }.width('100%')
                    Divider()
                  }
                  if (this.model.userDetail?.profile_publicity.gender === 'public' && this.model.userDetail?.profile.gender.length > 0 ){
                    Row(){
                      Text('性别：')
                      Blank()
                      Text(this.model.userDetail.profile.gender)
                    }.width('100%')
                    Divider()
                  }
                  if (this.model.userDetail?.profile_publicity.region === 'public' && this.model.userDetail?.profile.region.length > 0){
                    Row(){
                      Text('地区：')
                      Blank()
                      Text(this.model.userDetail.profile.region)
                    }.width('100%')
                    Divider()
                  }
                  if (this.model.userDetail?.profile_publicity.job === 'public' && this.model.userDetail?.profile.job.length > 0){
                    Row(){
                      Text('职业：')
                      Blank()
                      Text(this.model.userDetail.profile.job)
                    }.width('100%')
                    Divider()
                  }
                  if (this.model.userDetail?.profile_publicity.pawoo && this.model.userDetail?.profile.pawoo_url){
                    Row(){
                      Text('PAWOO：')
                      Blank()
                      Hyperlink(this.model.userDetail.profile.pawoo_url)
                    }.width('100%')
                    Divider()
                  }
                  if (this.model.userDetail?.profile.webpage && this.model.userDetail.profile.webpage.length > 0){
                    Row(){
                      Text('网站：')
                      Blank()
                      Hyperlink(this.model.userDetail.profile.webpage)
                    }.width('100%')
                    Divider()
                  }
                  if (this.model.userDetail?.profile.twitter_url){
                    Row(){
                      Text('Twitter：')
                      Blank()
                      Hyperlink(this.model.userDetail.profile.twitter_url,this.model.userDetail.profile.twitter_account)
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