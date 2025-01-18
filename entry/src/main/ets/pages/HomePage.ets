import { ApiClient } from '../network/ApiClient'
import { IllustRecommendedResponse } from '../network/response/IllustRecommendedResponse'
import { NovelRecommendedResponse } from '../network/response/NovelRecommendedResponse'
import { NovelRouterParam } from '../param/NovelRouterParam'
import { IllustWaterFlow } from '../comp/IllustWaterFlow'
import { NavRouterType } from '../param/NavRouterType'
import { UserRouterParam } from '../param/UserRouterParam'
import { IllustRouterParam } from '../param/IllustRouterParam'
import { NovelList } from '../comp/NovelList'
import { MangaRecommendedResponse } from '../network/response/MangaRecommendedResponse'
import { IllustWaterFlowController } from '../controller/IllustWaterFlowController'
import { NovelListController } from '../controller/NovelListController'
import { SearchTab } from '../comp/SearchTab'
import { IllustRankingModeEnum } from '../network/enums/IllustRankingModeEnum'
import { IllustRankingResponse } from '../network/response/IllustRankingResponse'
import { NovelRankingModeEnum } from '../network/enums/NovelRankingModeEnum'
import { NovelRankingResponse } from '../network/response/NovelRankingResponse'
import { SymbolGlyphModifier } from '@kit.ArkUI'

@Entry
@ComponentV2
struct HomePage {
  private pathStack: NavPathStack = new NavPathStack()
  private novelController:NovelListController = new NovelListController()
  private tabController:TabsController = new TabsController()
  private illustController:IllustWaterFlowController = new IllustWaterFlowController()
  private mangaController:IllustWaterFlowController = new IllustWaterFlowController()
  private illustRankingController:IllustWaterFlowController = new IllustWaterFlowController()
  private novelRankingController:NovelListController = new NovelListController()

  private illustBar: BottomTabBarStyle | SubTabBarStyle = BottomTabBarStyle.of({
    normal: new SymbolGlyphModifier($r('sys.symbol.picture')),
    selected: new SymbolGlyphModifier($r('sys.symbol.picture_fill')),
  }, '推荐插画')
  private novelBar: BottomTabBarStyle | SubTabBarStyle = BottomTabBarStyle.of({
    normal: new SymbolGlyphModifier($r('sys.symbol.doc_text')),
    selected: new SymbolGlyphModifier($r('sys.symbol.doc_text_fill'))
  }, '推荐小说')
  private mangaBar: BottomTabBarStyle | SubTabBarStyle = BottomTabBarStyle.of({
    normal: new SymbolGlyphModifier($r('sys.symbol.picture_2')),
    selected: new SymbolGlyphModifier($r('sys.symbol.picture_2_fill'))
  }, '推荐漫画')
  private illustRankingBar: BottomTabBarStyle | SubTabBarStyle = BottomTabBarStyle.of({
    normal: new SymbolGlyphModifier($r('sys.symbol.sort'))
  }, '插画排行')
  private novelRankingBar: BottomTabBarStyle | SubTabBarStyle = BottomTabBarStyle.of({
    normal: new SymbolGlyphModifier($r('sys.symbol.sort'))
  }, '小说排行')
  private searchBar: BottomTabBarStyle | SubTabBarStyle = BottomTabBarStyle.of({
    normal: new SymbolGlyphModifier($r('sys.symbol.magnifyingglass')),
  }, '搜索')

  @Local private tabLoad:Array<boolean> = [true,false,false,false,false,false]
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
    this.setBarPadding(10)
  }
  setBarPadding(barHeight: number){
    this.illustBar.padding({bottom:barHeight})
    this.novelBar.padding({bottom:barHeight})
    this.mangaBar.padding({bottom:barHeight})
    this.illustRankingBar.padding({bottom:barHeight})
    this.novelRankingBar.padding({bottom:barHeight})
    this.searchBar.padding({bottom:barHeight})
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

  getMangaRecommend():Promise<MangaRecommendedResponse|null>{
    return ApiClient.getMangaRecommend().then(res=>{
      const json = res?.toJSON()
      if (json) {
        return json as MangaRecommendedResponse
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

  getIllustRanking():Promise<IllustRankingResponse|null>{
    return ApiClient.getIllustRanking(IllustRankingModeEnum.DAY).then(res=>{
      const json = res?.toJSON()
      if (json) {
        return json as IllustRankingResponse
      }else {
        return null
      }
    })
  }

  getNovelRanking():Promise<NovelRankingResponse|null>{
    return ApiClient.getNovelRanking(NovelRankingModeEnum.DAY).then(res=>{
      const json = res?.toJSON()
      if (json) {
        return json as NovelRankingResponse
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
      Text(param.title)
        .fontSize(12)
        .fontColor(this.currentIndex===param.index?Color.Blue:Color.Black)
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
            this.tabLoad[param.index] = true
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
          IllustWaterFlow({controller:this.illustController,marginBottom:56,firstPage:()=>this.getIllustRecommend()})
        }.tabBar(this.illustBar)
        TabContent(){
          if (this.tabLoad[1]){
            NovelList({controller:this.novelController,marginBottom:56,firstPage:()=>this.getNovelRecommended()})
          }
        }.tabBar(this.novelBar)
        TabContent(){
          if (this.tabLoad[2]){
            IllustWaterFlow({controller:this.mangaController,marginBottom:56,firstPage:()=>this.getMangaRecommend()})
          }
        }.tabBar(this.mangaBar)
        TabContent(){
          if (this.tabLoad[3]){
            IllustWaterFlow({controller:this.illustRankingController,marginBottom:56,firstPage:()=>this.getIllustRanking()})
          }
        }.tabBar(this.illustRankingBar)
        TabContent(){
          if (this.tabLoad[4]){
            NovelList({controller:this.novelRankingController,marginBottom:56,firstPage:()=>this.getNovelRanking()})
          }
        }.tabBar(this.novelRankingBar)
        TabContent(){
          if (this.tabLoad[5]){
            SearchTab({marginTop:56,marginBottom:56})
          }
        }.tabBar(this.searchBar)
      }.width('100%')
      .height('100%')
      .barOverlap(true)
      .barPosition(BarPosition.End)
      .barBackgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
      .onChange((index)=>{
        this.currentIndex = index
        this.tabLoad[index] = true
      })
    }.height('100%')
    .width('100%')
    .hideToolBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}

interface TabBarTitleParam{
  index:number
  title:string
  icon?:Resource
  click?:()=>void
  doubleClick?:()=>void
}