import { ApiClient } from "../network/ApiClient";
import { NovelSearchTargetEnum } from "../network/enums/NovelSearchTargetEnum";
import { WebViewNovel } from "../network/model/WebViewNovel";
import { CommentsResponse } from "../network/response/CommentsResponse";
import { HtmlUtil } from "../network/util/HtmlUtil";
import { NovelRouterParam } from "../param/NovelRouterParam";
import { SearchRouterParam } from "../param/SearchRouterParam";

/**
 * 小说详情页视图模型
 */
@ObservedV2
export class NovelDetailViewModel{
  /**
   * 是否显示评论
   */
  @Trace showComments: boolean = false;
  /**
   * 小说id
   */
  @Trace novelId: number = 0
  /**
   * 小说信息
   */
  @Trace webViewNovel: WebViewNovel | null = null
  /**
   * 富文本内容
   */
  @Trace content:Array<string> = []
  /**
   * 路由栈
   */
  private _pathStack: NavPathStack | undefined = undefined;
  /**
   * 路由栈
   */
  public get pathStack(): NavPathStack | undefined {
    return this._pathStack;
  }
  /**
   * 滚动控制器
   */
  private _scroller: Scroller = new Scroller();
  /**
   * 滚动控制器
   */
  public get scroller(): Scroller {
    return this._scroller;
  }
  /**
   * 初始化
   * @param navInfo 路由信息
   */
  init(navInfo:NavigationInfo|undefined){
    if (navInfo?.pathStack) {
      this._pathStack = navInfo?.pathStack
      const param = navInfo!.pathStack.getParamByName('novelDetailPage').pop() as NovelRouterParam
      this.novelId = param.novelId
    }
    this.getWebViewNovel()
  }

  /**
   * 获取小说信息
   */
  getWebViewNovel() {
    ApiClient.webviewNovel(this.novelId).then(res => {
      if (res) {
        if (res?.headers['content-type']?.match('text/html')) {
          const body = res.toString()
          const jsonStr = HtmlUtil.getNovelJson(body!)
          if (jsonStr) {
            const json = JSON.parse(jsonStr) as WebViewNovel
            this.webViewNovel = json
            this.scroller.scrollTo({ yOffset:0,xOffset:0,animation:true})
          }
        }
      }
    })
  }

  /**
   * 获取评论
   * @returns 评论信息
   */
  getComments(): Promise<CommentsResponse | null> {
    return ApiClient.getNovelComments(this.novelId).then(res=>{
      if (res) {
        return res.toJSON() as CommentsResponse
      }else {
        return null
      }
    })
  }
  /**
   * 获取评论回复
   * @param commentId 评论id
   * @returns 评论回复信息
   */
  getCommentReply(commentId:number): Promise<CommentsResponse | null>{
    return ApiClient.getNovelCommentsReplies(commentId).then(res=>{
      if (res) {
        return res.toJSON() as CommentsResponse
      }else {
        return null
      }
    })
  }
  /**
   * 发表评论
   * @param relateId 关联id
   * @param comment 评论内容
   * @param parentCommentId 父评论id
   * @returns 是否发表成功
   */
  postComment(relateId: number, comment: string, parentCommentId?: number):Promise<boolean>{
    return ApiClient.postNovelComment(relateId,comment,parentCommentId).then(res=>{
      if (res) {
        return true
      }
      return false
    })
  }
  /**
   * 标签点击事件
   * @param item 标签内容
   */
  tagAction(item: string){
    this.pathStack?.pushPath({
      name: 'searchPage',
      param: {
        word: item,
        type: 'novel',
        target: NovelSearchTargetEnum.EXACT_MATCH_FOR_TAGS
      } as SearchRouterParam
    })
  }
  /**
   * 上一话点击事件
   */
  prevNovelAction(){
    if (this.webViewNovel!.seriesNavigation?.prevNovel) {
      this.novelId = this.webViewNovel!.seriesNavigation.prevNovel.id
    }
  }
  /**
   * 下一话点击事件
   */
  nextNovelAction(){
    if (this.webViewNovel!.seriesNavigation?.nextNovel) {
      this.novelId = this.webViewNovel!.seriesNavigation.nextNovel.id
    }
  }
}