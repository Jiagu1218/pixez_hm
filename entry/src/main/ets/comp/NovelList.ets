import { LazyDataSource } from "../entity/LazyDataSource"
import { ApiClient } from "../network/ApiClient"
import { Novel } from "../network/model/Novel"
import { NovelPageResponseBase } from "../network/response/NovelPageResponseBase"
import { NovelRouterParam } from "../param/NovelRouterParam"
import { NovelCard } from "./NovelCard"
import { BusinessError } from "@kit.BasicServicesKit"

@ComponentV2
export struct NovelList{
  private pathStack: NavPathStack|undefined = undefined
  private datasource: LazyDataSource<Novel> = new LazyDataSource<Novel>()
  private nextUrl:string |null = null
  @Require @Param firstPage:()=> Promise<NovelPageResponseBase |null>
  @Param scroller:Scroller = new Scroller()
  @Param marginTop:number = 0

  aboutToAppear(): void {
    this.pathStack = this.queryNavigationInfo()?.pathStack
    this.firstPage().then(res=>{
      if (res) {
        this.datasource.push(...res.novels)
        this.nextUrl = res.next_url
      }
    }).catch((error:BusinessError)=>{
      console.error('获取插画列表失败', error)
    })
  }
  aboutToDisappear(): void {

  }
  build() {
    Stack(){
      List({space:8,scroller:this.scroller}){
        if (this.marginTop>0){
          ListItem().height(this.marginTop)
        }
        LazyForEach(this.datasource, (item: Novel)=>{
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
      .width('100%')
      .height('100%')
      .onReachEnd(()=>{
        if (this.nextUrl) {
          ApiClient.getNext(this.nextUrl).then(res=>{
            const json = res?.toJSON()
            if (json) {
              const data = json as NovelPageResponseBase
              this.datasource.push(...data.novels)
              this.nextUrl = data.next_url
            }
          })
        }
      })

      SymbolGlyph($r('sys.symbol.arrow_up_circle'))
        .fontSize(40)
        .width(40)
        .height(40)
        .borderRadius(20)
        .onClick(()=>{
          this.scroller?.scrollTo({xOffset:0,yOffset:0})
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