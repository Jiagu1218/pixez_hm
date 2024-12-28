import { ApiClient } from '../network/ApiClient'
import { IllustRecommendedResponse } from '../network/response/IllustRecommendedResponse'
import { NovelRecommendedResponse } from '../network/response/NovelRecommendedResponse'
import { NovelRouterParam } from '../param/NovelRouterParam'
import { IllustWaterFlow } from '../comp/IllustWaterFlow'
import { NavRouterType } from '../param/NavRouterType'
import { UserRouterParam } from '../param/UserRouterParam'
import { IllustRouterParam } from '../param/IllustRouterParam'
import { NovelList } from '../comp/NovelList'

@Entry
@ComponentV2
struct HomePage {
  private pathStack: NavPathStack = new NavPathStack()
  private illustScroller:Scroller = new Scroller()
  private novelScroller:Scroller = new Scroller()
  private tabController:TabsController = new TabsController()
  @Local private currentIndex:number = 0
  onPageShow(){
    this.appRequire()
  }
  /**
   * 处理app被拉起的请求参数，跳转到指定页面
   */
  appRequire(){
    const routerType = AppStorage.get<NavRouterType>('routerType')
    if (routerType) {
      switch (routerType.name){
        case 'userDetailPage':
          this.pathStack.pushPath({
            name: 'userDetailPage',
            param: {userId: routerType.id} as UserRouterParam
          })
          break;
        case 'illustDetailPage':
          this.pathStack.pushPath({
            name: 'illustDetailPage',
            param: {illustId: routerType.id} as IllustRouterParam
          })
          break;
        case 'novelDetailPage':
          this.pathStack.pushPath({
            name: 'novelDetailPage',
            param: {novelId: routerType.id} as NovelRouterParam
          })
      }
    }
    AppStorage.delete('routerType')
  }
  aboutToAppear(): void {
  }

  getIllustRecommend():Promise<IllustRecommendedResponse|null>{
    return ApiClient.getIllustRecommend().then(res=>{
      const json = res?.toJSON()
      if (json) {
        return json as IllustRecommendedResponse
      }else {
        return null
      }
    })
  }

  getNovelRecommended():Promise<NovelRecommendedResponse|null>{
    return ApiClient.getNovelRecommended().then(res=>{
      const json = res?.toJSON()
      if (json) {
        return json as NovelRecommendedResponse
      }else {
        return null
      }
    })
  }

  aboutToDisappear(): void {
  }

  @Builder tabBarTitle(param: TabBarTitleParam){
    Column(){
      if (param.icon){
        SymbolGlyph(param.icon).fontColor(this.currentIndex===param.index?[Color.Blue]:[Color.Black])
      }
      Text(param.title).fontColor(this.currentIndex===param.index?Color.Blue:Color.Black)
    }
    .gesture(
      GestureGroup(
        GestureMode.Parallel,
        TapGesture({count:2}).onAction((event)=>{
          if (event) {
            param.doubleClick?.()
          }
        }),
        TapGesture({count:1}).onAction((event)=>{
          if (event) {
            this.tabController.changeIndex(param.index)
            param.click?.()
          }
        })
      )
    )
  }

  build() {
    Navigation(this.pathStack){
      Tabs({controller:this.tabController}){
        TabContent(){
          IllustWaterFlow({scroller:this.illustScroller,marginTop:56,firstPage:()=>this.getIllustRecommend()})
        }.tabBar(this.tabBarTitle({
          index:0,
          title:'推荐插画',
          doubleClick:()=>{
            this.illustScroller.scrollTo({xOffset:0,yOffset:0})
          }
        }))
        TabContent(){
          NovelList({scroller:this.novelScroller,marginTop:56,firstPage:()=>this.getNovelRecommended()})
        }.tabBar(this.tabBarTitle({
          index:1,
          title:'推荐小说',
          doubleClick:()=>{
            this.novelScroller.scrollTo({xOffset:0,yOffset:0})
          }
        }))
      }.width('100%')
      .height('100%')
      .barOverlap(true)
      .barBackgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
      .onChange((index)=>{
        this.currentIndex = index
      })
    }.height('100%')
    .width('100%')
    .hideToolBar(true)
  }
}

interface TabBarTitleParam{
  index:number
  title:string
  icon?:Resource
  click?:()=>void
  doubleClick?:()=>void
}