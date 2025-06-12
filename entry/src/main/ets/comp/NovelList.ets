import { LazyDataSource } from "../entity/LazyDataSource"
import { ApiClient } from "../network/ApiClient"
import { Novel } from "../network/model/Novel"
import { NovelPageResponseBase } from "../network/response/NovelPageResponseBase"
import { NovelRouterParam } from "../param/NovelRouterParam"
import { NovelCard } from "./NovelCard"
import { BusinessError } from "@kit.BasicServicesKit"
import { NovelListController } from "../controller/NovelListController"

@ComponentV2
export struct NovelList{
  private pathStack: NavPathStack|undefined = undefined
  private datasource: Novel[] = []
  private nextUrl:string |null = null
  private listScroller:Scroller = new Scroller()
  private top = ()=> {
    this.listScroller.scrollTo({xOffset:0,yOffset:0})
  }
  private clean = ()=> {
    this.datasource.length = 0
  }
  private getFirstPage = ()=>{
    this.firstPage().then(res=>{
      if (res) {
        this.datasource.push(...res.novels)
        this.nextUrl = res.next_url
      }
    }).catch((error:BusinessError)=>{
      console.error('获取小说列表失败', error)
    })
  }
  @Param controller:NovelListController = new NovelListController()
  @Require @Param firstPage:()=> Promise<NovelPageResponseBase |null>
  @Param marginTop:number = 0
  @Param marginBottom:number = 0
  @Local private showBottom:boolean = false

  aboutToAppear(): void {
    this.controller.top = this.top
    this.controller.clean = this.clean
    this.controller.getFirstPage = this.getFirstPage
    this.pathStack = this.queryNavigationInfo()?.pathStack
    this.firstPage().then(res=>{
      if (res) {
        this.datasource.push(...res.novels)
        this.nextUrl = res.next_url
      }
    }).catch((error:BusinessError)=>{
      console.error('获取小说列表失败', error)
    })
  }
  aboutToDisappear(): void {
  }

  build() {
    Stack(){
      List({space:8,scroller:this.listScroller}){
        ListItemGroup({
          style:ListItemGroupStyle.CARD,
          space:8,
          header: this.groupHeader() ,
          footer:this.groupFooter(),
        }){
          Repeat(this.datasource)
            .virtualScroll()
            .each(item=>{
              ListItem({style:ListItemStyle.CARD}){
                NovelCard({novel:item.item})
              }.onClick(()=>{
                this.pathStack?.pushPath({
                  name: 'novelDetailPage',
                  param: {novelId: item.item.id} as NovelRouterParam
                })
              }).height(undefined)
            })
            .key(item=>item.id.toString())
        }
        .divider({strokeWidth:2,startMargin:16,endMargin:16})

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
        }else {
          this.showBottom = true
        }
      })

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

  @Builder groupHeader(){
    Row().height(this.marginTop).width('100%')
  }
  @Builder groupFooter(){
    Text().height(this.marginBottom).width('100%')
  }
}