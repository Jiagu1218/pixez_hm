import { NovelCard } from '../comp/NovelCard'
import { LazyDataSource } from '../entity/LazyDataSource'
import { ApiClient } from '../network/ApiClient'
import { Novel } from '../network/model/Novel'
import { IllustRecommendedResponse } from '../network/response/IllustRecommendedResponse'
import { NovelRecommendedResponse } from '../network/response/NovelRecommendedResponse'
import { NovelRouterParam } from '../param/NovelRouterParam'
import { IllustWaterFlow } from '../comp/IllustWaterFlow'

@Entry
@ComponentV2
struct HomePage {
  private pathStack: NavPathStack = new NavPathStack()
  private recommendNovels: LazyDataSource<Novel> = new LazyDataSource<Novel>()
  private nextNovelUrl:string|null = null
  private illustScroller:Scroller = new Scroller()
  private novelScroller:Scroller = new Scroller()
  private tabController:TabsController = new TabsController()
  @Local private currentIndex:number = 0

  aboutToAppear(): void {
    ApiClient.getNovelRecommended().then(res=>{
      const json = res?.toJSON()
      if (json) {
        const data = json as NovelRecommendedResponse
        this.recommendNovels.push(...data.novels)
        this.recommendNovels.push(...data.ranking_novels)
        this.nextNovelUrl = data.next_url
      }
    })
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
          IllustWaterFlow({scroller:this.illustScroller,firstPage:()=>this.getIllustRecommend()})
        }.tabBar(this.tabBarTitle({
          index:0,
          title:'推荐插画',
          doubleClick:()=>{
            this.illustScroller.scrollTo({xOffset:0,yOffset:0})
          }
        }))
        TabContent(){
          List({scroller:this.novelScroller}){
            LazyForEach(this.recommendNovels, (item: Novel)=>{
              ListItem(){
                NovelCard({novel:item})
              }.onClick(()=>{
                this.pathStack?.pushPath({
                  name: 'novelDetailPage',
                  param: {novelId: item.id} as NovelRouterParam
                })
              })
            },(item: Novel)=>item.id.toString())
          }.cachedCount(4)
          .onReachEnd(()=>{
            if (this.nextNovelUrl) {
              ApiClient.getNext(this.nextNovelUrl).then(res=>{
                const json = res?.toJSON()
                if (json) {
                  const data = json as NovelRecommendedResponse
                  this.recommendNovels.push(...data.novels)
                  this.recommendNovels.push(...data.ranking_novels)
                  this.nextNovelUrl = data.next_url
                }
              })
            }
          })
        }.tabBar(this.tabBarTitle({
          index:1,
          title:'推荐小说',
          doubleClick:()=>{
            this.novelScroller.scrollTo({xOffset:0,yOffset:0})
          }
        }))
      }.width('100%')
      .height('100%')
      .onChange((index)=>{
        this.currentIndex = index
      })
    }
  }
}

interface TabBarTitleParam{
  index:number
  title:string
  icon?:Resource
  click?:()=>void
  doubleClick?:()=>void
}