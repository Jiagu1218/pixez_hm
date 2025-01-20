import { LazyDataSource } from "../entity/LazyDataSource"
import { ApiClient } from "../network/ApiClient"
import { IllustSearchTargetEnum } from "../network/enums/IllustSearchTargetEnum"
import { NovelSearchTargetEnum } from "../network/enums/NovelSearchTargetEnum"
import { SearchAutoCompleteResponse } from "../network/response/SearchAutoCompleteResponse"
import { SearchIllustResponse } from "../network/response/SearchIllustResponse"
import { SearchRouterParam } from "../param/SearchRouterParam"
import { SymbolGlyphModifier } from "@kit.ArkUI"
import { DateTimeUtil } from "../network/util/DateTimeUtil"
import { SearchSortEnum } from "../network/enums/SearchSortEnum"
import { SearchNovelResponse } from "../network/response/SearchNovelResponse"
import { SearchUserResponse } from "../network/response/SearchUserResponse"
import { UserPreview } from "../network/model/UserPreview"
import { UserPreviewCard } from "../comp/UserPreviewCard"
import { UserRouterParam } from "../param/UserRouterParam"
import { TrendTag, TrendTagsResponse } from "../network/response/TrendTagsResponse"
import { HttpImage } from "../comp/HttpImage"
import { IllustPageResponseBase } from "../network/response/IllustPageResponseBase"
import { IllustWaterFlowController } from "../controller/IllustWaterFlowController"
import { IllustWaterFlow } from "../comp/IllustWaterFlow"
import { NovelList } from "../comp/NovelList"
import { NovelListController } from "../controller/NovelListController"
import { NovelPageResponseBase } from "../network/response/NovelPageResponseBase"

@ComponentV2
export struct SearchPage{
  private pathStack:NavPathStack|undefined = undefined
  private searchController:SearchController = new SearchController()
  private novelSearchTargets:Array<string> = Object.values(NovelSearchTargetEnum)
  private novelSearchTargetOpt:Array<SelectOption> = Object.values(NovelSearchTargetEnum).map(e=>{return {value:e} as SelectOption})
  private illustSearchTargets:Array<string> = Object.values(IllustSearchTargetEnum)
  private illustSearchTargetOpt:Array<SelectOption> = Object.values(IllustSearchTargetEnum).map(e=>{return {value:e} as SelectOption})
  private searchTypes: Array<string> = ['illust', 'novel', 'user']
  private searchTypeOpts:Array<RadioOptions> = this.searchTypes.map(e=>{return {value:e,group:'searchType'} as RadioOptions})
  private sortOpts:Array<RadioOptions> = Object.values(SearchSortEnum).map(e=>{return {value:e,group:'sort'} as RadioOptions})
  private sort:string|undefined = undefined
  private nextUrl:string|null = null

  private users:LazyDataSource<UserPreview> = new LazyDataSource()
  private illustController:IllustWaterFlowController = new IllustWaterFlowController()
  private novelController:NovelListController = new NovelListController()
  @Local private startDate:Date|null = null
  @Local private endDate:Date|null = null
  @Local private targetSelectOpt:Array<SelectOption> = []
  @Local private showSheet:boolean = false
  @Local private showAI:boolean = true
  @Local private word: string = ''
  @Local private autoComplete: Array<string> = []
  @Local private searchType: string = 'illust'
  @Local private searchTarget:string = IllustSearchTargetEnum.TITLE_AND_CAPTION
  @Local private searchTargets:Array<string> = this.illustSearchTargets

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
            this.targetSelectOpt = this.illustSearchTargetOpt
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
            this.illustController.getFirstPage()
            break
          case 'novel':
            this.searchType = 'novel'
            this.searchTargets = this.novelSearchTargets
            this.targetSelectOpt = this.novelSearchTargetOpt
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
            this.novelController.getFirstPage()
            break
          case 'user':
            this.searchType = 'user'
            this.searchTargets = []
            this.targetSelectOpt = []
            this.searchUser()
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

  searchIllust(): Promise<IllustPageResponseBase|null>{
    return ApiClient.getSearchIllust({
      word: this.word,
      searchTarget:this.searchTarget,
      sort: this.sort,
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
  searchNovel(): Promise<NovelPageResponseBase|null>{
    return ApiClient.getSearchNovel({
      word: this.word,
      searchTarget:this.searchTarget,
      sort: this.sort,
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

  searchUser(){
    ApiClient.getSearchUser(this.word).then(res=>{
      if (res){
        const resp = res.toJSON() as SearchUserResponse
        this.nextUrl = resp.next_url
        this.users.setData(resp.user_previews)
      }
    })
  }


  @Builder searchSetting(){
    Column({space:16}){
      Row(){
        Text('AI生成')
        Blank()
        Toggle({type:ToggleType.Switch,isOn:this.showAI}).onChange(isOn=>{
          this.showAI = isOn
        })
      }.width('100%')
      Divider()
      Row(){
        Text('搜索类型')
        Blank()
        Repeat(this.searchTypeOpts).each(item=>{
          Row(){
            Text(item.item.value)
            Radio(item.item).onChange(choose=>{
              if (choose){
                this.searchType = item.item.value
              }
            }).checked(item.item.value === this.searchType)
          }
        }).key(item=>item.value)
      }.width('100%')
      Divider()
      Row(){
        Text('排序')
        Blank()
        Row({space:6}){
          Repeat(this.sortOpts).each(item=>{
            Row(){
              Text(item.item.value)
              Radio(item.item).onChange(choose=>{
                if (choose){
                  this.sort = item.item.value
                }
              }).checked(item.item.value === this.sort)
            }
          }).key(item=>item.value)
        }
      }.width('100%')
      Divider()
      Row(){
        Text('搜索条件')
        Blank()
        Select(this.targetSelectOpt)
          .selected(this.searchTargets.indexOf(this.searchTarget))
          .value(this.searchTarget)
          .onSelect((index,value)=>{
            this.searchTarget = value
          })
      }.width('100%')
      Divider()
      Row(){
        Text('日期范围')
        Blank()
        Row({space:6}){
          Text(this.startDate? DateTimeUtil.parseDateToLocalFormatTime(this.startDate,'YYYY-MM-DD') : '选择日期')
            .onClick(()=>{
              DatePickerDialog.show({
                selected:this.startDate,
                end:this.endDate,
                onDateAccept:(date)=>{
                  this.startDate = date
                }
              })
            })
          Text('/')
          Text(this.endDate? DateTimeUtil.parseDateToLocalFormatTime(this.endDate,'YYYY-MM-DD') : '选择日期')
            .onClick(()=>{
              DatePickerDialog.show({
                selected:this.endDate,
                start:this.startDate,
                end:new Date(),
                onDateAccept:(date)=>{
                  this.endDate = date
                }
              })
            })
        }
      }.width('100%')
    }
  }

  @Builder searchTitle(){
    Search({value: this.word,controller: this.searchController})
      .onChange((value: string) => {
        ApiClient.getSearchAutocomplete(value).then((res) => {
          if (res) {
            const resp = res.toJSON() as SearchAutoCompleteResponse
            this.autoComplete = resp.tags.map(tag=>tag.name)
          }
        })
      })
      .onSubmit(value=>{
        this.word = value
        this.nextUrl = null
        this.illustController.clean()
        this.novelController.clean()
        switch (this.searchType){
          case 'illust':
            this.illustController.getFirstPage()
            break
          case 'novel':
            this.novelController.getFirstPage()
            break
          case 'user':
            this.searchUser()
            break
        }
      })

  }
  @Builder tagTitle(tag:TrendTag){
    Column(){
      Text(tag.tag).fontSize(12).maxLines(1)
      if (tag.translated_name){
        Text(tag.translated_name).fontSize(10).maxLines(1)
      }
    }.width('100%')
    .height(30)
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
  }

  build() {
    NavDestination(){
      if (this.searchType === 'illust'){
        IllustWaterFlow({controller:this.illustController,firstPage:()=>this.searchIllust()})
      }else if (this.searchType === 'novel'){
        NovelList({controller:this.novelController,firstPage:()=>this.searchNovel()})
      }else if (this.searchType === 'user'){
        List({space:8}){
          ListItemGroup({
            style:ListItemGroupStyle.CARD,
            space:8
          }){
            LazyForEach(this.users, (item:UserPreview)=>{
              ListItem({style:ListItemStyle.CARD}){
                UserPreviewCard({userPreview: item})
              }.onClick(()=>{
                this.pathStack?.pushPath({
                  name: 'userDetailPage',
                  param: {userId: item.user.id} as UserRouterParam
                })
              }).height(undefined)
            },(item:UserPreview)=>item.user.id.toString())
          }.divider({strokeWidth:2,startMargin:16,endMargin:16})
        }.cachedCount(4)
        .onReachEnd(()=>{
          if (this.nextUrl){
            ApiClient.getNext(this.nextUrl).then(res=>{
              if (res) {
                const resp = res.toJSON() as SearchUserResponse
                this.nextUrl = resp.next_url
                this.users.push(...resp.user_previews)
              }
            })
          }
        })
      }
    }
    .title(this.searchTitle,{
      backgroundBlurStyle: BlurStyle.BACKGROUND_THIN,
      enableHoverMode:true
    })
    .menus([{
      value: '搜索设置',
      symbolIcon:new SymbolGlyphModifier($r('sys.symbol.more')),
      action:()=>{
        this.showSheet = true
      }
    }])
    .padding({top:32})
    .bindSheet(this.showSheet,this.searchSetting(),{
      title: { title:'搜索设置' },
      height:SheetSize.MEDIUM,
      blurStyle:BlurStyle.Thin,
      shouldDismiss:()=>{
        this.showSheet = false
      }
    })
  }
}

@Builder export function SearchPageBuilder(){
  SearchPage()
}