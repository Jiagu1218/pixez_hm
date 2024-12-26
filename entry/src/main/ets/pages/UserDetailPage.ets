import { ApiClient } from '../network/ApiClient'
import { router } from '@kit.ArkUI'
import { UserDetailResponse } from '../network/response/UserDetailResponse'
import { HttpImage } from '../comp/HttpImage'
import { LazyDataSource } from '../entity/LazyDataSource'
import { Illust } from '../network/model/Illust'
import { UserIllustResponse } from '../network/response/UserIllustResponse'
import { IllustCard } from '../comp/IllustCard'
import { BookmarksIllustResponse } from '../network/response/BookmarksIllustResponse'
import { UserBookmarkTagsIllustResponse } from '../network/response/UserBookmarkTagsIllustResponse'
import { UserRouterParam } from '../param/UserRouterParam'
import { IllustRouterParam } from '../param/IllustRouterParam'
import { BusinessError } from '@kit.BasicServicesKit'

@Entry
@ComponentV2
struct UserDetailPage {
  private userId:number = 0
  private nextIllustUrl:string|null = null
  private nextMangaUrl:string|null = null
  private nextBookmarkUrl:string|null = null
  private pathStack:NavPathStack|undefined = undefined
  @Local private userDetail:UserDetailResponse|null = null
  @Local private illusts:LazyDataSource<Illust> = new LazyDataSource()
  @Local private mangas:LazyDataSource<Illust> = new LazyDataSource()
  @Local private bookmarkIllusts:LazyDataSource<Illust> = new LazyDataSource()

  aboutToAppear(): void {
    this.pathStack = this.queryNavigationInfo()?.pathStack
    const params = router.getParams() as UserRouterParam
    if (params) {
      this.userId = params.userId
    }
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
    ApiClient.getUserIllusts(this.userId).then(res => {
      if (res) {
        const resp=res.toJSON() as UserIllustResponse
        this.illusts.push(...resp.illusts)
        this.nextIllustUrl = resp.next_url
      }
    })
    ApiClient.getUserIllusts(this.userId,'manga').then(res => {
      if (res) {
        const resp=res.toJSON() as UserIllustResponse
        this.mangas.push(...resp.illusts)
        this.nextMangaUrl = resp.next_url
      }
    })
    // ApiClient.getUserBookmarkTagsIllust(this.userId).then(res => {
    //   if (res) {
    //     const resp = res.toJSON() as UserBookmarkTagsIllustResponse
    //   }
    // })
    ApiClient.getBookmarksIllust({
      userId:this.userId,
      restrict:'public'
    }).then(res => {
      if (res) {
        const resp = res.toJSON() as BookmarksIllustResponse
        this.bookmarkIllusts.push(...resp.illusts)
        this.nextBookmarkUrl = resp.next_url
      }
    }).catch((e:BusinessError)=>{
      console.info('error',e)
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
              }
              if (this.userDetail){
                Row(){
                  Column(){
                    HttpImage({url:this.userDetail.user.profile_image_urls.medium,aRatio:1,br:40}).width(80)
                    Text(this.userDetail.user.name).fontSize(30).fontWeight(FontWeight.Bold)
                  }
                }
              }
            }.width('100%')
            .backgroundColor(Color.Orange)
          }
          ListItemGroup(){
            ListItem(){
              Tabs(){
                TabContent(){
                  WaterFlow(){
                    LazyForEach(this.illusts, (item:Illust) => {
                      FlowItem(){
                        IllustCard({illust:item})
                      }.onClick(()=> {
                        this.pathStack?.pushPath({
                          name: 'illustDetailPage',
                          param: { illustId: item.id } as IllustRouterParam
                        })
                      })
                    }, (item:Illust) => item.id.toString())
                  }.columnsTemplate('1fr 1fr')
                  .columnsGap(8)
                  .rowsGap(8)
                  //嵌套滚动控制
                  .nestedScroll({
                    //滚动组件往末尾端滚动时的嵌套滚动选项
                    scrollForward:NestedScrollMode.PARENT_FIRST,
                    //滚动组件往起始端滚动时的嵌套滚动选项
                    scrollBackward:NestedScrollMode.SELF_FIRST
                  })
                  .onReachEnd(()=>{
                    if (this.nextIllustUrl) {
                      ApiClient.getNext(this.nextIllustUrl).then(res=>{
                        const json = res?.toJSON()
                        if (json) {
                          const data = json as UserIllustResponse
                          this.illusts.push(...data.illusts)
                          this.nextIllustUrl = data.next_url
                        }
                      })
                    }
                  })
                }.tabBar('作品')
                TabContent(){
                  WaterFlow(){
                    LazyForEach(this.mangas, (item:Illust) => {
                      FlowItem(){
                        IllustCard({illust:item})
                      }.onClick(()=> {
                        this.pathStack?.pushPath({
                          name: 'illustDetailPage',
                          param: { illustId: item.id } as IllustRouterParam
                        })
                      })
                    }, (item:Illust) => item.id.toString())
                  }.columnsTemplate('1fr 1fr')
                  .columnsGap(8)
                  .rowsGap(8)
                  //嵌套滚动控制
                  .nestedScroll({
                    //滚动组件往末尾端滚动时的嵌套滚动选项
                    scrollForward:NestedScrollMode.PARENT_FIRST,
                    //滚动组件往起始端滚动时的嵌套滚动选项
                    scrollBackward:NestedScrollMode.SELF_FIRST
                  })
                  .onReachEnd(()=>{
                    if (this.nextMangaUrl) {
                      ApiClient.getNext(this.nextMangaUrl).then(res=>{
                        const json = res?.toJSON()
                        if (json) {
                          const data = json as UserIllustResponse
                          this.illusts.push(...data.illusts)
                          this.nextMangaUrl = data.next_url
                        }
                      })
                    }
                  })
                }.tabBar('漫画')
                TabContent(){
                  WaterFlow(){
                    LazyForEach(this.bookmarkIllusts, (item:Illust) => {
                      FlowItem(){
                        IllustCard({illust:item})
                      }.onClick(()=> {
                        this.pathStack?.pushPath({
                          name: 'illustDetailPage',
                          param: { illustId: item.id } as IllustRouterParam
                        })
                      })
                    }, (item:Illust) => item.id.toString())
                  }.columnsTemplate('1fr 1fr')
                  .columnsGap(8)
                  .rowsGap(8)
                  //嵌套滚动控制
                  .nestedScroll({
                    //滚动组件往末尾端滚动时的嵌套滚动选项
                    scrollForward:NestedScrollMode.PARENT_FIRST,
                    //滚动组件往起始端滚动时的嵌套滚动选项
                    scrollBackward:NestedScrollMode.SELF_FIRST
                  })
                  .onReachEnd(()=>{
                    if (this.nextBookmarkUrl) {
                      ApiClient.getNext(this.nextBookmarkUrl).then(res=>{
                        const json = res?.toJSON()
                        if (json) {
                          const data = json as BookmarksIllustResponse
                          this.bookmarkIllusts.push(...data.illusts)
                          this.nextBookmarkUrl= data.next_url
                        }
                      })
                    }
                  })
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