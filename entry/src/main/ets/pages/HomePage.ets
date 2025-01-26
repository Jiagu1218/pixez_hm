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
import { SymbolGlyphModifier } from '@kit.ArkUI'
import { RankingTab } from '../comp/RankingTab'

@Entry
@ComponentV2
struct HomePage {
  private pathStack: NavPathStack = new NavPathStack()
  private novelController:NovelListController = new NovelListController()
  private tabController:TabsController = new TabsController()
  private illustController:IllustWaterFlowController = new IllustWaterFlowController()
  private mangaController:IllustWaterFlowController = new IllustWaterFlowController()

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
  private rankingBar: BottomTabBarStyle | SubTabBarStyle = BottomTabBarStyle.of({
    normal: new SymbolGlyphModifier($r('sys.symbol.sort'))
  }, '排行榜')
  private searchBar: BottomTabBarStyle | SubTabBarStyle = BottomTabBarStyle.of({
    normal: new SymbolGlyphModifier($r('sys.symbol.magnifyingglass')),
  }, '搜索')

  @Local private tabLoad:Array<boolean> = [true,false,false,false,false,false]
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
        case 'artWorksPage':
          this.pathStack.pushPath({
            name: 'artWorksPage',
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
    this.rankingBar.padding({bottom:barHeight})
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
            RankingTab()
          }
        }.tabBar(this.rankingBar)
        TabContent(){
          if (this.tabLoad[4]){
            SearchTab({marginTop:56,marginBottom:56})
          }
        }.tabBar(this.searchBar)
      }.width('100%')
      .height('100%')
      .barOverlap(true)
      .barPosition(BarPosition.End)
      .barBackgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
      .onChange((index)=>{
        this.tabLoad[index] = true
      })
    }.height('100%')
    .width('100%')
    .hideToolBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}