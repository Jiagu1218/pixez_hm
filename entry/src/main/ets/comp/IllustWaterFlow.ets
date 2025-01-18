import { IllustDataSourcePrefetching } from "../entity/IllustDataSourcePrefetching";
import { BasicPrefetcher } from "@kit.ArkUI";
import { Illust } from "../network/model/Illust";
import { IllustRouterParam } from "../param/IllustRouterParam";
import { IllustCard } from "./IllustCard";
import { ApiClient } from "../network/ApiClient";
import { IllustPageResponseBase } from "../network/response/IllustPageResponseBase";
import { BusinessError } from "@kit.BasicServicesKit";
import { IllustWaterFlowController } from "../controller/IllustWaterFlowController";

@ComponentV2
export struct IllustWaterFlow {
  private datasource: IllustDataSourcePrefetching = new IllustDataSourcePrefetching()
  private prefetcher = new BasicPrefetcher()
  private pathStack:NavPathStack|undefined = undefined
  private nextUrl:string|null = null
  private scroller:Scroller = new Scroller()
  private waterFlowOpt:WaterFlowOptions = {scroller:this.scroller}
  private top = ()=> {
    this.scroller.scrollTo({xOffset:0,yOffset:0})
  }
  private clean = ()=>{
    this.datasource.clean()
  }
  private getFirstPage = ()=>{
    this.firstPage().then(res=>{
      if (res) {
        this.datasource.push(...res.illusts)
        this.nextUrl = res.next_url
      }
    }).catch((error:BusinessError)=>{
      console.error('获取插画列表失败', error)
    })
  }
  @Param controller:IllustWaterFlowController = new IllustWaterFlowController()
  @Require @Param firstPage:()=> Promise<IllustPageResponseBase |null>
  @Param marginTop:number = 0
  @Param marginBottom:number = 0
  @Param columnCount:number = 2
  @Local private columnArr:number[] = [-1,-2]


  aboutToAppear(): void {
    this.controller.top = this.top
    this.controller.clean = this.clean
    this.controller.getFirstPage = this.getFirstPage
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
    if (this.marginBottom>0) {
      this.waterFlowOpt.footer = this.footer
    }
  }

  aboutToDisappear(): void {
    this.datasource.destroy()
  }
  @Builder footer(){
    Row(){}.height(this.marginBottom).width('100%')
  }
  build() {
    Stack(){
      WaterFlow({scroller:this.scroller,footer:this.footer}){
        if (this.marginTop>0){
          ForEach(this.columnArr, (item: number)=>{
            FlowItem().height(this.marginTop)
              .width('100%')
          },(item: number)=>item.toString())
        }
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
        if (this.nextUrl) {
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
      .columnsTemplate('1fr '.repeat(this.columnCount))
      .columnsGap(8)
      .rowsGap(8)
      .height('100%')
      .width('100%')

      SymbolGlyph($r('sys.symbol.arrow_up_circle'))
        .fontSize(40)
        .width(40)
        .height(40)
        .borderRadius(20)
        .onClick(()=>{
          this.controller.top()
        })
        .offset({
          x: -20,
          y: -80
        })
        .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
    }.width('100%')
    .height('100%')
    .alignContent(Alignment.BottomEnd)
  }
}