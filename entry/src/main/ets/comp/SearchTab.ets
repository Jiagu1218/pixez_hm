import { LengthUnit } from "@kit.ArkUI"
import { ApiClient,
  HttpImage,
  IllustSearchTargetEnum, NovelSearchTargetEnum,
  SearchAutoCompleteResponse,
  TrendTag, TrendTagsResponse } from "common"
import { SearchRouterParam } from "../param/SearchRouterParam"

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
    Column({ space: 0 }){
      Repeat<string>(this.autoComplete).each(item=>{
        Text(item.item)
          .maxLines(1)
          .fontSize(14)
          .fontColor('#334155')
          .padding({ left: 12, right: 12, top: 10, bottom: 10 })
          .width('100%')
          .backgroundColor('#F8FAFC')
          .onClick(()=>{
            this.showAutoComplete = false
            this.submit(item.item)
          })
      }).key(item=>item)
    }.width('100%')
    .borderRadius(10)
    .clip(true)
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
    Column({ space: 2 }){
      Text(tag.tag)
        .fontSize(11)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      if (tag.translated_name){
        Text(tag.translated_name)
          .fontSize(10)
          .fontColor('#E2E8F0')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .width('100%')
    .padding({ left: 8, right: 8, top: 8, bottom: 8 })
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['#00000000', 0.0], ['#000000AA', 0.55], ['#000000CC', 1.0]]
    })
  }

  build() {
    Column({ space: 16 }){
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
          Flex({ wrap: FlexWrap.Wrap, space: { main: { value: 8, unit: LengthUnit.VP } } }){
            Repeat<string>(this.historyWord).each(item=>{
              Text(item.item)
                .fontSize(12)
                .maxLines(1)
                .fontColor('#475569')
                .padding({ left: 10, right: 10, top: 6, bottom: 6 })
                .backgroundColor('#F1F5F9')
                .borderRadius(16)
                .onClick(()=>{
                  this.submit(item.item)
                })
            }).key(item=>item)
          }
          .margin({ top: 10 })
        }
      }
      .padding({ left: 4, right: 4 })
      Divider()
        .color('#EEF2F7')
        .strokeWidth(1)
      Row({ space: 28 }){
        Repeat<string>(this.searchTypes).each(item=>{
          Text(item.item)
            .fontSize(15)
            .fontWeight(this.searchType === item.item ? FontWeight.Medium : FontWeight.Regular)
            .fontColor(this.searchType === item.item ? '#2563EB' : '#64748B')
            .padding({ bottom: 6 })
            .maxLines(1)
            .onClick(()=>{
              this.searchType = item.item
            })
        }).key(item=>item)
      }
      .width('100%')
      .justifyContent(FlexAlign.Center)
      Grid(){
        Repeat<TrendTag>(this.trendTags).each(item=>{
          GridItem(){
            HttpImage({
              url: item.item.illust.image_urls.square_medium,
              aRatio: 1,
              br: 12
            })
              .clip(true)
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
      .columnsGap(10)
      .rowsGap(10)

      if (this.marginBottom>0){
        Row().width('100%').height(this.marginBottom - 16)
      }
    }
  }
}