import { IllustDataSourcePrefetching } from "../entity/IllustDataSourcePrefetching";
import { BasicPrefetcher } from "@kit.ArkUI";
import { Illust } from "../network/model/Illust";
import { IllustRouterParam } from "../param/IllustRouterParam";
import { IllustCard } from "./IllustCard";
import { ApiClient } from "../network/ApiClient";
import { IllustPageResponseBase } from "../network/response/IllustPageResponseBase";
import { BusinessError } from "@kit.BasicServicesKit";

@ComponentV2
export struct IllustWaterFlow {
  private datasource: IllustDataSourcePrefetching = new IllustDataSourcePrefetching()
  private prefetcher = new BasicPrefetcher()
  private pathStack:NavPathStack|undefined = undefined
  private nextUrl:string|null = null
  @Require @Param firstPage:()=> Promise<IllustPageResponseBase |null>
  @Param scroller:Scroller = new Scroller()

  aboutToAppear(): void {
    this.pathStack = this.queryNavigationInfo()?.pathStack
    this.datasource.getSession()
    this.prefetcher.setDataSource(this.datasource)
    this.firstPage().then(res=>{
      if (res) {
        this.datasource.push(...res.illusts)
        this.nextUrl = res.next_url
      }
    }).catch((error:BusinessError)=>{
      console.error('获取插画列表失败', error)
    })
  }
  aboutToDisappear(): void {
    this.datasource.destroy()
  }
  build() {
    WaterFlow({scroller:this.scroller}){
      LazyForEach(this.datasource, (item: Illust)=>{
        if (item.visible) {
          FlowItem(){
            IllustCard({illust:item})
          }
          .onClick(()=>{
            this.pathStack?.pushPath({
              name: 'illustDetailPage',
              param: {illustId: item.id} as IllustRouterParam
            })
          })
        }
      },(item: Illust)=>item.id.toString())
    }
    .onScrollIndex((first,last)=>{
      this.prefetcher.visibleAreaChanged(first,last)
    })
    //嵌套滚动控制
    .nestedScroll({
      //滚动组件往末尾端滚动时的嵌套滚动选项
      scrollForward:NestedScrollMode.PARENT_FIRST,
      //滚动组件往起始端滚动时的嵌套滚动选项
      scrollBackward:NestedScrollMode.SELF_FIRST
    })
    .onReachEnd(()=>{
      if (this.nextUrl && this.nextUrl?.length>0) {
        ApiClient.getNext(this.nextUrl).then(res=>{
          const json = res?.toJSON()
          if (json) {
            const data = json as IllustPageResponseBase
            this.datasource.push(...data.illusts)
            this.nextUrl = data.next_url
          }
        })
      }
    }).cachedCount(4)
    .columnsTemplate('1fr 1fr')
    .columnsGap(8)
    .rowsGap(8)
    .height('100%')
    .width('100%')
  }
}