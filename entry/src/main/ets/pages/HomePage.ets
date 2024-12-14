import { IllustCard } from '../comp/IllustCard'
import { LazyDataSource } from '../entity/LazyDataSource'
import { ApiClient } from '../network/ApiClient'
import { Illust } from '../network/model/Illust'
import { IllustRecommendedResponse } from '../network/response/IllustRecommendedResponse'

@Entry
@ComponentV2
struct HomePage {
  private recommendIllusts: LazyDataSource<Illust> = new LazyDataSource<Illust>()
  private nextIllustUrl:string = ''

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
  }

  build() {
    Tabs(){
      TabContent(){
        WaterFlow(){
          LazyForEach(this.recommendIllusts, (item: Illust, index)=>{
            FlowItem(){
              IllustCard({illust:item})
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

      }.tabBar('推荐小说')
    }.width('100%')
    .height('100%')
  }
}