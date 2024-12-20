import { IllustCard } from '../comp/IllustCard'
import { NovelCard } from '../comp/NovelCard'
import { LazyDataSource } from '../entity/LazyDataSource'
import { ApiClient } from '../network/ApiClient'
import { Illust } from '../network/model/Illust'
import { Novel } from '../network/model/Novel'
import { IllustRecommendedResponse } from '../network/response/IllustRecommendedResponse'
import { NovelRecommendedResponse } from '../network/response/NovelRecommendedResponse'

@Entry
@ComponentV2
struct HomePage {
  private recommendIllusts: LazyDataSource<Illust> = new LazyDataSource<Illust>()
  private recommendNovels: LazyDataSource<Novel> = new LazyDataSource<Novel>()
  private nextIllustUrl:string = ''
  private nextNovelUrl:string = ''

  aboutToAppear(): void {
    ApiClient.getIllustRecommend().then(res=>{
      const json = res?.toJSON()
      if (json) {
        const data = json as IllustRecommendedResponse
        this.recommendIllusts.push(...data.illusts)
        this.recommendIllusts.push(...data.ranking_illusts)
        this.nextIllustUrl = data.next_url
      }
    })
    setTimeout(()=>{
      ApiClient.getNovelRecommended().then(res=>{
        const json = res?.toJSON()
        if (json) {
          const data = json as NovelRecommendedResponse
          this.recommendNovels.push(...data.novels)
          this.recommendNovels.push(...data.ranking_novels)
          this.nextNovelUrl = data.next_url
        }
      })
    },1000)
  }

  build() {
    Tabs(){
      TabContent(){
        WaterFlow(){
          LazyForEach(this.recommendIllusts, (item: Illust)=>{
            if (item.visible) {
              FlowItem(){
                IllustCard({illust:item})
              }
            }
          },(item: Illust)=>item.id.toString())
        }.onReachEnd(()=>{
          if (this.nextIllustUrl?.length>0) {
            ApiClient.getNext(this.nextIllustUrl).then(res=>{
              const json = res?.toJSON()
              if (json) {
                const data = json as IllustRecommendedResponse
                this.recommendIllusts.push(...data.illusts)
                this.recommendIllusts.push(...data.ranking_illusts)
                this.nextIllustUrl = data.next_url
              }
            })
          }
        }).cachedCount(8)
        .columnsTemplate('1fr 1fr')
        .columnsGap(8)
        .rowsGap(8)
      }.tabBar('推荐插图')
      TabContent(){
        List(){
          LazyForEach(this.recommendNovels, (item: Novel)=>{
            ListItem(){
              NovelCard({novel:item})
            }
          },(item: Novel)=>item.id.toString())
        }.onReachEnd(()=>{
          if (this.nextNovelUrl?.length>0) {
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
      }.tabBar('推荐小说')
    }.width('100%')
    .height('100%')
  }
}