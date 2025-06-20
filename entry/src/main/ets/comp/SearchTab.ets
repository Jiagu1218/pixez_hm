import { ApiClient, IllustSearchTargetEnum, NovelSearchTargetEnum,
  SearchAutoCompleteResponse,
  TrendTag, TrendTagsResponse } from "pixez_network"
import { SearchRouterParam } from "../param/SearchRouterParam"
import { HttpImage } from "./HttpImage"

@ComponentV2
export struct SearchTab{
  private pathStack:NavPathStack|undefined = undefined
  private searchTypes: Array<string> = ['illust', 'novel', 'user']
  @Local private searchType: string = 'illust'
  @Param marginTop:number = 0
  @Param marginBottom:number = 0
  @Local private historyWord: Array<string> = []
  @Local private autoComplete: Array<string> = []
  @Local private showAutoComplete: boolean = false
  @Local private trendTags:Array<TrendTag> = []


  aboutToAppear(): void{
    this.pathStack = this.queryNavigationInfo()?.pathStack
    this.getIllustTrendTags()
  }
  getIllustTrendTags(){
    ApiClient.getIllustTrendTags().then(res=>{
      if (res){
        const resp = res.toJSON() as TrendTagsResponse
        this.trendTags = resp.trend_tags
      }
    })
  }
  @Monitor('autoComplete')
  watchAutoComplete(){
    if (this.autoComplete.length>0){
      this.showAutoComplete = true
    }else {
      this.showAutoComplete = false
    }
  }

  @Monitor('searchType')
  watch(){
    switch (this.searchType){
      case 'illust':
        this.getIllustTrendTags()
        break
      case 'novel':
        this.getNovelTrendTags()
        break
      case 'user':
        this.trendTags = []
        break
    }
  }

  getNovelTrendTags(){
    ApiClient.getNovelTrendTags().then(res=>{
      if (res){
        const resp = res.toJSON() as TrendTagsResponse
        this.trendTags = resp.trend_tags
      }
    })
  }

  @Builder popup(){
    Column({space:8}){
      Repeat<string>(this.autoComplete).each(item=>{
        Text(item.item).maxLines(1).onClick(()=>{
          this.showAutoComplete = false
          this.submit(item.item)
        })
      }).key(item=>item)
    }.width('100%')
  }

  submit(value:string){
    switch (this.searchType){
      case 'illust':
        this.pathStack?.pushPath({
          name: 'searchPage',
          param:  {
            word: value,
            type: 'illust',
            target: IllustSearchTargetEnum.EXACT_MATCH_FOR_TAGS
          } as SearchRouterParam
        })
        break
      case 'novel':
        this.pathStack?.pushPath({
          name: 'searchPage',
          param: {
            word: value,
            type: 'novel',
            target: NovelSearchTargetEnum.EXACT_MATCH_FOR_TAGS
          } as SearchRouterParam
        })
        break
      case 'user':
        this.pathStack?.pushPath({
          name: 'searchPage',
          param: {
            word: value,
            type: 'user'
          } as SearchRouterParam
        })
        break
    }
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
    Column({space:16}){
      if (this.marginTop>0){
        Row().width('100%').height(this.marginTop-16)
      }
      Column(){
        Search()
          .onChange((value: string) => {
            const word = value.trim()
            if(word.length>0){
              ApiClient.getSearchAutocomplete(word).then((res) => {
                if (res) {
                  const resp = res.toJSON() as SearchAutoCompleteResponse
                  this.autoComplete = resp.tags.map(tag=>tag.name)
                }
              })
            }else {
              this.autoComplete = []
            }
          })
          .onSubmit(value=>{
            const word = value.trim()
            this.submit(word)
          })
          .bindPopup(this.showAutoComplete,{
            builder: this.popup()
          })
        if (this.historyWord.length>0){
          Flex({wrap:FlexWrap.Wrap}){
            Repeat<string>(this.historyWord).each(item=>{
              Text(item.item).fontSize(12).maxLines(1).onClick(()=>{
                this.submit(item.item)
              })
            }).key(item=>item)
          }
        }
      }
      Divider()
      Row({space:32}){
        Repeat<string>(this.searchTypes).each(item=>{
          Text(item.item).fontSize(16).maxLines(1).onClick(()=>{
            this.searchType = item.item
          })
        }).key(item=>item)
      }
      Grid(){
        Repeat<TrendTag>(this.trendTags).each(item=>{
          GridItem(){
            HttpImage({url: item.item.illust.image_urls.square_medium,aRatio:1})
              .overlay(this.tagTitle(item.item),{
                align:Alignment.Bottom
              })
          }.onClick(()=>{
            this.submit(item.item.tag)
          })
        }).key(item=>item.tag)
      }.width('100%')
      .layoutWeight(1)
      .columnsTemplate('repeat(auto-fit, 120)')
      .columnsGap(8)
      .rowsGap(8)

      if (this.marginBottom>0){
        Row().width('100%').height(this.marginBottom - 16)
      }
    }
  }
}