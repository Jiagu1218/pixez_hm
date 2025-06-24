import { SymbolGlyphModifier } from '@kit.ArkUI'
import { ApiClient, NovelRankingModeEnum, NovelRankingResponse, NovelRecommendedResponse } from 'common'
import { NovelList } from '../comp/NovelList'
import { NovelListController } from '../controller/NovelListController'

@Entry
@ComponentV2
struct Index {
  private pathStack: NavPathStack = new NavPathStack()
  private novelController: NovelListController = new NovelListController()
  private novelRankingController:NovelListController = new NovelListController()

  novelBar: BottomTabBarStyle | SubTabBarStyle = BottomTabBarStyle.of({
    normal: new SymbolGlyphModifier($r('sys.symbol.doc_text')),
    selected: new SymbolGlyphModifier($r('sys.symbol.doc_text_fill'))
  }, '推荐')

  rankingBar: BottomTabBarStyle | SubTabBarStyle = BottomTabBarStyle.of({
    normal: new SymbolGlyphModifier($r('sys.symbol.sort'))
  }, '排行榜')

  searchBar: BottomTabBarStyle | SubTabBarStyle = BottomTabBarStyle.of({
    normal: new SymbolGlyphModifier($r('sys.symbol.magnifyingglass')),
  }, '搜索')

  /**
   * 获取小说推荐
   * @returns
   */
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

  build() {
    Navigation(this.pathStack) {
      Tabs(){
        TabContent(){
          NovelList({controller:this.novelController,marginBottom:56,firstPage:()=>this.getNovelRecommended()})
        }.tabBar(this.novelBar)
        TabContent(){
          NovelList({controller:this.novelRankingController,marginBottom:56,firstPage:()=>this.getNovelRanking()})
        }.tabBar(this.rankingBar)
        TabContent(){

        }.tabBar(this.searchBar)
      }
      .barPosition(BarPosition.End)
      .barOverlap(true)
      .barBackgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
      .height('100%')
      .width('100%')
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }
    .height('100%')
    .width('100%')
    .hideToolBar(true)
  }
}

@Builder
export function IndexBuilder() {
  Index()
}