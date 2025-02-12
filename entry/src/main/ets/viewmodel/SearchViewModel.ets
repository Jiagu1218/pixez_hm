import { IllustWaterFlowController } from "../controller/IllustWaterFlowController"
import { NovelListController } from "../controller/NovelListController"
import { LazyDataSource } from "../entity/LazyDataSource"
import { ApiClient } from "../network/ApiClient"
import { IllustSearchTargetEnum } from "../network/enums/IllustSearchTargetEnum"
import { NovelSearchTargetEnum } from "../network/enums/NovelSearchTargetEnum"
import { SearchSortEnum } from "../network/enums/SearchSortEnum"
import { UserPreview } from "../network/model/UserPreview"
import { IllustPageResponseBase } from "../network/response/IllustPageResponseBase"
import { NovelPageResponseBase } from "../network/response/NovelPageResponseBase"
import { SearchAutoCompleteResponse } from "../network/response/SearchAutoCompleteResponse"
import { SearchIllustResponse } from "../network/response/SearchIllustResponse"
import { SearchNovelResponse } from "../network/response/SearchNovelResponse"
import { SearchUserResponse } from "../network/response/SearchUserResponse"
import { DateTimeUtil } from "../network/util/DateTimeUtil"
import { SearchRouterParam } from "../param/SearchRouterParam"
import { UserRouterParam } from "../param/UserRouterParam"
/**
 * 搜索视图模型
 */
@ObservedV2
export class SearchViewModel {
  /**
   * 路由栈
   */
  private _pathStack: NavPathStack | undefined = undefined
  /**
   * 路由栈
   */
  public get pathStack(): NavPathStack | undefined {
    return this._pathStack
  }
  /**
   * 搜索控制器
   */
  private _searchController: SearchController = new SearchController()
  /**
   * 搜索控制器
   */
  public get searchController(): SearchController {
    return this._searchController
  }
  /**
   * 小说搜索目标
   */
  private _novelSearchTargets: Array<string> = Object.values(NovelSearchTargetEnum)
  /**
   * 小说搜索目标
   * @returns
   */
  public get novelSearchTargets(): Array<string> {
    return this._novelSearchTargets
  }
  /**
   * 小说搜索目标选项
   */
  private _novelSearchTargetOpt: Array<SelectOption> = Object.values(NovelSearchTargetEnum).map(e => {
    return { value: e } as SelectOption
  })
  /**
   * 小说搜索目标选项
   * @returns
   */
  public get novelSearchTargetOpt(): Array<SelectOption> {
    return this._novelSearchTargetOpt
  }
  /**
   * 画作搜索目标
   */
  private _illustSearchTargets: Array<string> = Object.values(IllustSearchTargetEnum)
  /**
   * 画作搜索目标
   * @returns
   */
  public get illustSearchTargets(): Array<string> {
    return this._illustSearchTargets
  }
  /**
   * 画作搜索目标选项
   * @returns
   */
  private _illustSearchTargetOpt: Array<SelectOption> = Object.values(IllustSearchTargetEnum).map(e => {
    return { value: e } as SelectOption
  })
  /**
   * 画作搜索目标选项
   * @returns
   */
  public get illustSearchTargetOpt(): Array<SelectOption> {
    return this._illustSearchTargetOpt
  }
  /**
   * 搜索类型
   */
  private _searchTypes: Array<string> = ['illust', 'novel', 'user']
  /**
   * 搜索类型
   * @returns
   */
  public get searchTypes(): Array<string> {
    return this._searchTypes
  }
  /**
   * 搜索类型选项
   * @returns
   */
  private _searchTypeOpts: Array<RadioOptions> = this.searchTypes.map(e => {
    return { value: e, group: 'searchType' } as RadioOptions
  })
  /**
   * 搜索类型选项
   * @returns
   */
  public get searchTypeOpts(): Array<RadioOptions> {
    return this._searchTypeOpts
  }
  /**
   * 排序选项
   * @returns
   */
  private _sortOpts: Array<RadioOptions> = Object.values(SearchSortEnum).map(e => {
    return { value: e, group: 'sort' } as RadioOptions
  })
  /**
   * 排序选项
   * @returns
   */
  public get sortOpts(): Array<RadioOptions> {
    return this._sortOpts
  }
  /**
   * 排序
   */
  private _sort: string | undefined = undefined
  /**
   * 排序
   * @param value
   */
  public set sort(value: string | undefined) {
    this._sort = value
  }
  /**
   * 排序
   * @returns
   */
  public get sort(): string | undefined {
    return this._sort
  }
  /**
   * 下一页URL
   */
  private _nextUrl: string | null = null
  /**
   * 下一页URL
   * @param value
   */
  public set nextUrl(value: string | null) {
    this._nextUrl = value
  }
  /**
   * 下一页URL
   * @returns
   */
  public get nextUrl(): string | null {
    return this._nextUrl
  }
  /**
   * 用户数据
   */
  private _users: LazyDataSource<UserPreview> = new LazyDataSource()
  /**
   * 用户数据
   * @returns
   */
  public get users(): LazyDataSource<UserPreview> {
    return this._users
  }
  /**
   * 画作列表控制器
   */
  private _illustController: IllustWaterFlowController = new IllustWaterFlowController()
  /**
   * 画作列表控制器
   * @returns
   */
  public get illustController(): IllustWaterFlowController {
    return this._illustController
  }
  /**
   * 小说列表控制器
   */
  private _novelController: NovelListController = new NovelListController()
  /**
   * 小说列表控制器
   * @returns
   */
  public get novelController(): NovelListController {
    return this._novelController
  }
  /**
   * 开始时间
   */
  @Trace startDate:Date|null = null
  /**
   * 结束时间
   */
  @Trace endDate:Date|null = null
  /**
   * 搜索目标选项
   */
  @Trace targetSelectOpt:Array<SelectOption> = []
  /**
   * 是否显示高级搜索面板
   */
  @Trace showSheet:boolean = false
  /**
   * 是否显示AI搜索
   */
  @Trace showAI:boolean = true
  /**
   * 搜索词
   */
  @Trace word: string = ''
  /**
   * 自动补全
   */
  @Trace autoComplete: Array<string> = []
  /**
   * 搜索类型
   */
  @Trace searchType: string = 'illust'
  /**
   * 搜索目标
   */
  @Trace searchTarget:string = IllustSearchTargetEnum.TITLE_AND_CAPTION
  /**
   * 搜索目标选项
   */
  @Trace searchTargets:Array<string> = this._illustSearchTargets

  /**
   * 初始化搜索页面
   */
  init(navInfo:NavigationInfo|undefined){
    if (navInfo) {
      this._pathStack = navInfo.pathStack
      const param = navInfo.pathStack.getParamByName('searchPage').pop() as SearchRouterParam
      this.word = param.word
      switch (param.type){
        case 'illust':
          this.illustDefaultSearch(param)
          break
        case 'novel':
          this.novelDefaultSearch(param)
          break
        case 'user':
          this.userDefaultSearch()
          break
        default:
          this.searchType = 'illust'
      }
    }
  }
  /**
   * 初始化用户搜索
   */
  private userDefaultSearch() {
    this.searchType = 'user'
    this.searchTargets = []
    this.targetSelectOpt = []
    this.searchUser()
  }
  /**
   * 初始化小说搜索
   */
  private novelDefaultSearch(param: SearchRouterParam) {
    this.searchType = 'novel'
    this.searchTargets = this._novelSearchTargets
    this.targetSelectOpt = this._novelSearchTargetOpt
    switch (param.target) {
      case NovelSearchTargetEnum.PARTIAL_MATCH_FOR_TAGS:
        this.searchTarget = NovelSearchTargetEnum.PARTIAL_MATCH_FOR_TAGS
        break
      case NovelSearchTargetEnum.EXACT_MATCH_FOR_TAGS:
        this.searchTarget = NovelSearchTargetEnum.EXACT_MATCH_FOR_TAGS
        break
      case NovelSearchTargetEnum.TEXT:
        this.searchTarget = NovelSearchTargetEnum.TEXT
        break
      case NovelSearchTargetEnum.KEYWORD:
        this.searchTarget = NovelSearchTargetEnum.KEYWORD
        break
      case NovelSearchTargetEnum.FULL_TEXT_SEARCH:
        this.searchTarget = NovelSearchTargetEnum.FULL_TEXT_SEARCH
        break
      default:
        this.searchTarget = NovelSearchTargetEnum.EXACT_MATCH_FOR_TAGS
    }
    this._novelController.getFirstPage()
  }
  /**
   * 初始化插画搜索
   */
  private illustDefaultSearch(param: SearchRouterParam) {
    this.searchType = 'illust'
    this.searchTargets = this._illustSearchTargets
    this.targetSelectOpt = this._illustSearchTargetOpt
    switch (param.target) {
      case IllustSearchTargetEnum.TITLE_AND_CAPTION:
        this.searchTarget = IllustSearchTargetEnum.TITLE_AND_CAPTION
        break
      case IllustSearchTargetEnum.PARTIAL_MATCH_FOR_TAGS:
        this.searchTarget = IllustSearchTargetEnum.PARTIAL_MATCH_FOR_TAGS
        break
      case IllustSearchTargetEnum.EXACT_MATCH_FOR_TAGS:
        this.searchTarget = IllustSearchTargetEnum.EXACT_MATCH_FOR_TAGS
        break
      default:
        this.searchTarget = IllustSearchTargetEnum.EXACT_MATCH_FOR_TAGS
    }
    this._illustController.getFirstPage()
  }
  /**
   * 搜索插画
   */
  searchIllust(): Promise<IllustPageResponseBase|null>{
    return ApiClient.getSearchIllust({
      word: this.word,
      searchTarget:this.searchTarget,
      sort: this._sort,
      searchAiType: this.showAI ? 1 : 0,
      startDate:this.startDate ? DateTimeUtil.parseDateToLocalFormatTime(this.startDate,'YYYY-MM-DD') : undefined,
      endDate:this.endDate ? DateTimeUtil.parseDateToLocalFormatTime(this.endDate,'YYYY-MM-DD') : undefined,
    }).then(res=>{
      if (res) {
        const resp = res.toJSON() as SearchIllustResponse
        this.showAI = resp.show_ai
        return resp
      }else {
        return null
      }
    })
  }
  /**
   * 搜索小说
   */
  searchNovel(): Promise<NovelPageResponseBase|null>{
    return ApiClient.getSearchNovel({
      word: this.word,
      searchTarget:this.searchTarget,
      sort: this._sort,
      startDate:this.startDate ? DateTimeUtil.parseDateToLocalFormatTime(this.startDate,'YYYY-MM-DD') : undefined,
      endDate:this.endDate ? DateTimeUtil.parseDateToLocalFormatTime(this.endDate,'YYYY-MM-DD') : undefined,
    }).then(res=>{
      if (res) {
        const resp = res.toJSON() as SearchNovelResponse
        this.showAI = resp.show_ai
        return resp
      }else {
        return null
      }
    })
  }
  /**
   * 搜索用户
   */
  searchUser(){
    ApiClient.getSearchUser(this.word).then(res=>{
      if (res){
        const resp = res.toJSON() as SearchUserResponse
        this._nextUrl = resp.next_url
        this._users.setData(resp.user_previews)
      }
    })
  }
  /**
   * 自动补全
   */
  searchAutocomplete(value:string){
    ApiClient.getSearchAutocomplete(value).then((res) => {
      if (res) {
        const resp = res.toJSON() as SearchAutoCompleteResponse
        this.autoComplete = resp.tags.map(tag=>tag.name)
      }
    })
  }
  /**
   * 监听搜索类型
   */
  watchSearchType(){
    switch (this.searchType){
      case 'illust':
        this.targetSelectOpt = this.illustSearchTargetOpt
        this.searchTargets = this.illustSearchTargets
        this.searchTarget = IllustSearchTargetEnum.TITLE_AND_CAPTION
        break
      case 'novel':
        this.targetSelectOpt = this.novelSearchTargetOpt
        this.searchTargets = this.novelSearchTargets
        this.searchTarget = NovelSearchTargetEnum.PARTIAL_MATCH_FOR_TAGS
        this.nextUrl = null
        break
      case 'user':
        break
    }
  }

  /**
   * 搜索提交
   */
  searchSubmitAction(value:string){
    this.word = value
    this._nextUrl = null
    this._illustController.clean()
    this._novelController.clean()
    switch (this.searchType){
      case 'illust':
        this._illustController.getFirstPage()
        break
      case 'novel':
        this._novelController.getFirstPage()
        break
      case 'user':
        this.searchUser()
        break
    }
  }
  /**
   * 用户详情
   */
  userDetailAction(item:UserPreview){
    this._pathStack?.pushPath({
      name: 'userDetailPage',
      param: {userId: item.user.id} as UserRouterParam
    })
  }
  /**
   * 用户下一页
   */
  nextPageUserAction(){
    if (this._nextUrl){
      ApiClient.getNext(this._nextUrl).then(res=>{
        if (res) {
          const resp = res.toJSON() as SearchUserResponse
          this._nextUrl = resp.next_url
          this._users.push(...resp.user_previews)
        }
      })
    }
  }

}