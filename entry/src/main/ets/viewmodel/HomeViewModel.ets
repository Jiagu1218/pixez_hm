import { SymbolGlyphModifier } from "@kit.ArkUI"
import { IllustWaterFlowController } from "../controller/IllustWaterFlowController"
import { NovelListController } from "../controller/NovelListController"
import { ApiClient } from "../network/ApiClient"
import { IllustRecommendedResponse } from "../network/response/IllustRecommendedResponse"
import { MangaRecommendedResponse } from "../network/response/MangaRecommendedResponse"
import { NovelRecommendedResponse } from "../network/response/NovelRecommendedResponse"
import { IllustRouterParam } from "../param/IllustRouterParam"
import { NavRouterType } from "../param/NavRouterType"
import { NovelRouterParam } from "../param/NovelRouterParam"
import { UserRouterParam } from "../param/UserRouterParam"
/**
 * 首页ViewModel
 */
@ObservedV2
export class HomeViewModel{
  @Trace tabLoad:Array<boolean> = [true,false,false,false,false,false]
  /**
   * 路径栈
   */
  private _pathStack: NavPathStack = new NavPathStack()

  public get pathStack(): NavPathStack {
    return this._pathStack
  }
  /**
   * tab控制器
   */
  private _tabController: TabsController = new TabsController()

  public get tabController(): TabsController {
    return this._tabController
  }
  /**
   * 小说列表控制器
   */
  private _novelController: NovelListController = new NovelListController()
  /**
   * 小说列表控制器
   */
  public get novelController(): NovelListController {
    return this._novelController
  }
  /**
   * 插画列表控制器
   */
  private _illustController: IllustWaterFlowController = new IllustWaterFlowController()
  /**
   * 插画列表控制器
   */
  public get illustController(): IllustWaterFlowController {
    return this._illustController
  }
  /**
   * 漫画列表控制器
   */
  private _mangaController: IllustWaterFlowController = new IllustWaterFlowController()
  /**
   * 漫画列表控制器
   */
  public get mangaController(): IllustWaterFlowController {
    return this._mangaController
  }
  /**
   * 插画tabBar
   */
  private _illustBar: BottomTabBarStyle | SubTabBarStyle = BottomTabBarStyle.of({
    normal: new SymbolGlyphModifier($r('sys.symbol.picture')),
    selected: new SymbolGlyphModifier($r('sys.symbol.picture_fill')),
  }, '推荐插画')
  /**
   * 插画tabBar
   */
  public get illustBar(): BottomTabBarStyle | SubTabBarStyle {
    return this._illustBar
  }
  /**
   * 小说tabBar
   */
  private _novelBar: BottomTabBarStyle | SubTabBarStyle = BottomTabBarStyle.of({
    normal: new SymbolGlyphModifier($r('sys.symbol.doc_text')),
    selected: new SymbolGlyphModifier($r('sys.symbol.doc_text_fill'))
  }, '推荐小说')
  /**
   * 小说tabBar
   */
  public get novelBar(): BottomTabBarStyle | SubTabBarStyle {
    return this._novelBar
  }
  /**
   * 漫画tabBar
   */
  private _mangaBar: BottomTabBarStyle | SubTabBarStyle = BottomTabBarStyle.of({
    normal: new SymbolGlyphModifier($r('sys.symbol.picture_2')),
    selected: new SymbolGlyphModifier($r('sys.symbol.picture_2_fill'))
  }, '推荐漫画')
  /**
   * 漫画tabBar
   */
  public get mangaBar(): BottomTabBarStyle | SubTabBarStyle {
    return this._mangaBar
  }
  /**
   * 排行榜tabBar
   */
  private _rankingBar: BottomTabBarStyle | SubTabBarStyle = BottomTabBarStyle.of({
    normal: new SymbolGlyphModifier($r('sys.symbol.sort'))
  }, '排行榜')
  /**
   * 排行榜tabBar
   */
  public get rankingBar(): BottomTabBarStyle | SubTabBarStyle {
    return this._rankingBar
  }
  /**
   * 搜索tabBar
   */
  private _searchBar: BottomTabBarStyle | SubTabBarStyle = BottomTabBarStyle.of({
    normal: new SymbolGlyphModifier($r('sys.symbol.magnifyingglass')),
  }, '搜索')
  /**
   * 搜索tabBar
   */
  public get searchBar(): BottomTabBarStyle | SubTabBarStyle {
    return this._searchBar
  }

  /**
   * 处理app被拉起的请求参数，跳转到指定页面
   */
  appRequire(){
    const routerType = AppStorage.get<NavRouterType>('routerType')
    if (routerType) {
      switch (routerType.name){
        case 'userDetailPage':
          this._pathStack.pushPath({
            name: 'userDetailPage',
            param: {userId: routerType.id} as UserRouterParam
          })
          break;
        case 'artWorksPage':
          this._pathStack.pushPath({
            name: 'artWorksPage',
            param: {illustId: routerType.id} as IllustRouterParam
          })
          break;
        case 'novelDetailPage':
          this._pathStack.pushPath({
            name: 'novelDetailPage',
            param: {novelId: routerType.id} as NovelRouterParam
          })
      }
    }
    AppStorage.delete('routerType')
  }
  /**
   * 设置底部tabBar的padding
   * @param barHeight
   */
  setBarPadding(barHeight: number){
    this._illustBar.padding({bottom:barHeight})
    this._novelBar.padding({bottom:barHeight})
    this._mangaBar.padding({bottom:barHeight})
    this._rankingBar.padding({bottom:barHeight})
    this._searchBar.padding({bottom:barHeight})
  }
  /**
   * 获取插画推荐
   * @returns
   */
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
  /**
   * 获取漫画推荐
   * @returns
   */
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
}