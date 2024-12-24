import { IllustCard } from "../comp/IllustCard"
import { NovelCard } from "../comp/NovelCard"
import { LazyDataSource } from "../entity/LazyDataSource"
import { ApiClient } from "../network/ApiClient"
import { IllustSearchTargetEnum } from "../network/enums/IllustSearchTargetEnum"
import { NovelSearchTargetEnum } from "../network/enums/NovelSearchTargetEnum"
import { Illust } from "../network/model/Illust"
import { Novel } from "../network/model/Novel"
import { SearchAutoCompleteResponse } from "../network/response/SearchAutoCompleteResponse"
import { SearchIllustResponse } from "../network/response/SearchIllustResponse"
import { IllustRouterParam } from "../param/IllustRouterParam"
import { NovelRouterParam } from "../param/NovelRouterParam"
import { SearchRouterParam } from "../param/SearchRouterParam"

@ComponentV2
export struct SearchPage{
  private pathStack:NavPathStack|undefined = undefined
  private searchController:SearchController = new SearchController()
  private novelSearchTargets:Array<string> = Object.values(NovelSearchTargetEnum)
  private illustSearchTargets:Array<string> = Object.values(IllustSearchTargetEnum)
  private searchTypes: Array<string> = ['illust', 'novel']
  private nextUrl:string|null = null
  @Local private historyWord: Array<string> = []
  @Local private word: string = ''
  @Local private autoComplete: Array<string> = []
  @Local private searchType: string = 'illust'
  @Local private searchTarget:string = IllustSearchTargetEnum.TITLE_AND_CAPTION
  @Local private searchTargets:Array<string> = this.illustSearchTargets
  @Local private illusts:LazyDataSource<Illust> = new LazyDataSource()
  @Local private novels:LazyDataSource<Novel> = new LazyDataSource()
  aboutToAppear(): void {
    this.pathStack = this.queryNavigationInfo()?.pathStack
    if (this.pathStack) {
      const param = this.pathStack.getParamByName('searchPage').pop() as SearchRouterParam
      if (param) {
        this.word = param.word
        switch (param.type){
          case 'illust':
            this.searchType = 'illust'
            this.searchTargets = this.illustSearchTargets
            switch (param.target){
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
            this.searchIllust()
            break
          case 'novel':
            this.searchType = 'novel'
            this.searchTargets = this.novelSearchTargets
            switch (param.target){
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
            this.searchNovel()
            break
          default:
            this.searchType = 'illust'
        }
      }
    }
  }

  @Monitor('searchType')
  watch(){
    switch (this.searchType){
      case 'illust':
        this.searchTargets = this.illustSearchTargets
        this.searchTarget = IllustSearchTargetEnum.TITLE_AND_CAPTION
        this.nextUrl = null
        this.illusts.clean()
        this.novels.clean()
        break
      case 'novel':
        this.searchTargets = this.novelSearchTargets
        this.searchTarget = NovelSearchTargetEnum.PARTIAL_MATCH_FOR_TAGS
        this.nextUrl = null
        this.illusts.clean()
        this.novels.clean()
        break
    }
  }

  searchIllust(){
    ApiClient.getSearchIllust({
      word: this.word,
      searchTarget:this.searchTarget,
      sort: 'date_desc'
    }).then(res=>{
      if (res) {
        const resp = res.toJSON() as SearchIllustResponse
        this.nextUrl = resp.next_url
        this.illusts.push(...resp.illusts)
      }
    })
  }
  searchNovel(){
    ApiClient.getSearchNovel({
      word: this.word,
      searchTarget:this.searchTarget,
      sort: 'date_desc'
    }).then(res=>{
      if (res) {
        const resp = res.toJSON()
        console.info('11111', resp)
      }
    })
  }

  @Builder searchTitle(){
    Search({value: this.word!!,controller: this.searchController})
      .onChange((value: string) => {
        ApiClient.getSearchAutocomplete(value).then((res) => {
          if (res) {
            const resp = res.toJSON() as SearchAutoCompleteResponse
            this.autoComplete = resp.tags.map(tag=>tag.name)
          }
        })
      })
      .onSubmit(value=>{
        this.illusts.clean()
        this.novels.clean()
        switch (this.searchType){
          case 'illust':
            this.searchIllust()
            break
          case 'novel':
            this.searchNovel()
            break
        }
      })
  }
  build() {
    NavDestination(){
      if (this.searchType === 'illust'){
        WaterFlow(){
          LazyForEach(this.illusts, (item:Illust)=>{
            FlowItem(){
              IllustCard({illust: item})
            }.onClick(()=>{
              this.pathStack?.pushPath({
                name: 'illustDetailPage',
                param: {illustId: item.id} as IllustRouterParam
              })
            })
          })
        }.cachedCount(8)
        .columnsTemplate('1fr 1fr')
        .columnsGap(8)
        .rowsGap(8)
      }else if (this.searchType === 'novel'){
        List(){
          LazyForEach(this.novels, (item:Novel)=>{
            ListItem(){
              NovelCard({novel: item})
            }.onClick(()=>{
              this.pathStack?.pushPath({
                name: 'novelDetailPage',
                param: {novelId: item.id} as NovelRouterParam
              })
            })
          })
        }
      }
    }
    .title(this.searchTitle())
  }
}

@Builder export function SearchPageBuilder(){
  SearchPage()
}