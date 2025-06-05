import { IllustDataSourcePrefetching } from "../../entity/IllustDataSourcePrefetching"
import { BasicPrefetcher } from "@kit.ArkUI"
import { BusinessError } from "@kit.BasicServicesKit"
import { IllustPageResponseBase } from "../../network/response/IllustPageResponseBase"
import { IllustWaterFlowController } from "../../controller/IllustWaterFlowController"
import { ApiClient } from "../../network/ApiClient"
import { IllustRouterParam } from "../../param/IllustRouterParam"

@ObservedV2
export class IllustWaterFlowViewModel{
  /**
   * 插画瀑布流数据源
   */
  private _datasource: IllustDataSourcePrefetching = new IllustDataSourcePrefetching()
  /**
   * 插画瀑布流数据源
   */
  public get datasource(): IllustDataSourcePrefetching {
    return this._datasource
  }
  /**
   * 预处理
   */
  private _prefetcher = new BasicPrefetcher()
  /**
   * 预处理
   */
  public get prefetcher() {
    return this._prefetcher
  }
  /**
   * 路径栈
   */
  private pathStack:NavPathStack|undefined = undefined
  /**
   * 下一页url
   */
  private nextUrl:string|null = null
  /**
   * 滚动器
   */
  private _scroller: Scroller = new Scroller()
  /**
   * 滚动器
   */
  public get scroller(): Scroller {
    return this._scroller
  }
  /**
   * 顶部
   */
  public top = ()=> {
    this._scroller.scrollTo({xOffset:0,yOffset:0})
  }
  /**
   * 清理
   */
  private clean = ()=>{
    this._datasource.clean()
  }
  /**
   * 获取第一页
   */
  private getFirstPage = ()=>{
    this.firstPage().then(res=>{
      if (res) {
        this._datasource.push(...res.illusts)
        this.nextUrl = res.next_url
      }
    }).catch((error:BusinessError)=>{
      console.error('获取插画列表失败', error)
    })
  }
  /**
   * 瀑布流控制器
   */
  private controller:IllustWaterFlowController = new IllustWaterFlowController()
  /**
   * 第一页
   */
  firstPage:()=> Promise<IllustPageResponseBase |null>
  /**
   * 上边距
   */
  @Trace marginTop:number = 0
  /**
   * 下边距
   */
  @Trace marginBottom:number = 0
  /**
   * 瀑布流列数
   */
  @Trace columnCount:number = 2
  /**
   * 瀑布流预留id
   */
  @Trace columnArr:number[] = [-1,-2]

  @Trace showBackToTop: boolean = false;

  private scrollThreshold: number = 1; // 显示返回顶部按钮的滚动阈值
  private lastScrollTime: number = 0;
  private scrollDebounceTime: number = 100; // 滚动防抖时间



  constructor(firstPage:()=> Promise<IllustPageResponseBase |null>,navInfo:NavigationInfo|undefined) {
    this.controller.top = this.top
    this.controller.clean = this.clean
    this.controller.getFirstPage = this.getFirstPage
    this.pathStack = navInfo?.pathStack
    this._datasource.getSession()
    this._prefetcher.setDataSource(this._datasource)
    this.firstPage = firstPage
  }

  loadInitialData(){
    this.firstPage().then(res=>{
      if (res) {
        this._datasource.push(...res.illusts)
        this.nextUrl = res.next_url
      }
    }).catch((error:BusinessError)=>{
      console.error('获取插画列表失败', error)
    })
  }

  destroy(){
    this._datasource.destroy()
  }

  handleScroll(yOffset: number): void {
    const currentTime = new Date().getTime();
    if (currentTime - this.lastScrollTime < this.scrollDebounceTime) {
      return;
    }
    this.lastScrollTime = currentTime;

    this.showBackToTop = yOffset > this.scrollThreshold;
  }

  nextPage(){
    if (this.nextUrl) {
      ApiClient.getNext(this.nextUrl).then(res=>{
        const json = res?.toJSON()
        if (json) {
          const data = json as IllustPageResponseBase
          this._datasource.push(...data.illusts)
          this.nextUrl = data.next_url
        }
      })
    }
  }

  arkItemAction(id:number){
    this.pathStack?.pushPath({
      name: 'artWorksPage',
      param: {illustId: id} as IllustRouterParam
    })
  }
}