import { IllustDataSourcePrefetching } from "../entity/IllustDataSourcePrefetching"
import { Illust, Tag } from "../network/model/Illust"
import { BasicPrefetcher } from "@kit.ArkUI"
import { CommentsResponse } from "../network/response/CommentsResponse"
import { ApiClient } from "../network/ApiClient"
import { IllustDetailResponse } from "../network/response/IllustDetailResponse"
import { IllustRelatedResponse } from "../network/response/IllustRelatedResponse"
import { IllustRouterParam } from "../param/IllustRouterParam"
import { UserRouterParam } from "../param/UserRouterParam"
import { IllustSearchTargetEnum } from "../network/enums/IllustSearchTargetEnum"
import { SearchRouterParam } from "../param/SearchRouterParam"

/**
 * 插画详情页视图模型
 */
@ObservedV2
export class ArtWorksViewModel{
  /**
   * 插画id
   */
  @Trace illustId: number = 0
  /**
   * 插画数据
   */
  @Trace illust: Illust|null = null
  /**
   * 相关作品下一页url
   */
  @Trace nextUrl:string|null = null
  /**
   * 是否关注
   */
  @Trace followed: boolean = false
  /**
   * 插画原图url
   */
  @Trace illustsRawUrl:Array<string> = []
  /**
   * 是否显示原图
   */
  @Trace showRaw:boolean = false
  /**
   * 是否显示评论
   */
  @Trace showComments:boolean = false
  /**
   * 原图索引
   */
  @Trace initIndex:number = 0
  /**
   * 当前原图url
   */
  @Trace currentRawUrl:string = ''
  /**
   * 导航栈
   */
  pathStack:NavPathStack|undefined = undefined
  /**
   * 相关作品
   */
  @Trace relatedIllusts: Illust[] = []
  /**
   * 相关作品预加载器
   */
  // illustPrefetcher = new BasicPrefetcher(this.relatedIllusts)

  /**
   * 初始化
   * @param navInfo 导航栈
   */
  init(navInfo:NavigationInfo|undefined) {
    if (navInfo) {
      this.pathStack = navInfo.pathStack
      const param = navInfo.pathStack.getParamByName('artWorksPage').pop() as IllustRouterParam
      // this.relatedIllusts.getSession()
      this.illustId = param.illustId
      this.getIllustDetail()
      this.getIllustRelated()
    }
  }
  /**
   * 跳转到用户详情页
   */
  userDetailAction(){
    if(this.illust?.user.id){
      this.pathStack?.pushPath({
        name: 'userDetailPage',
        param:{
          userId: this.illust.user.id
        } as UserRouterParam
      })
    }
  }
  /**
   * 标签跳转到搜索页
   */
  tagAction(item:Tag){
    this.pathStack?.pushPath({
      name: 'searchPage',
      param: {
        word: item.name,
        type: 'illust',
        target: IllustSearchTargetEnum.EXACT_MATCH_FOR_TAGS
      } as SearchRouterParam
    })
  }
  /**
   * 关注用户
   */
  followAction(){
    if (!this.illust){
      return
    }
    if (this.followed) {
      ApiClient.postUnFollowUser(this.illust.user.id).then(()=>{
        this.followed = false
      })
    }else {
      ApiClient.postFollowUser(this.illust.user.id,'public').then(()=>{
        this.followed = true
      })
    }
  }
  /**
   * 相关作品点击事件
   */
  relatedAction(item:Illust){
    this.pathStack?.pushPath({
      name: 'artWorksPage',
      param: {illustId:item.id} as IllustRouterParam
    })
  }
  /**
   * 相关作品加载更多
   */
  relatedPageAction(){
    if (this.nextUrl){
      ApiClient.getNext(this.nextUrl).then(res=>{
        const resp = res?.toJSON() as IllustRelatedResponse
        this.relatedIllusts.push(...resp.illusts)
        this.nextUrl = resp.next_url
      })
    }
  }

  /**
   * 获取插画详情
   */
  private getIllustDetail(){
    ApiClient.getIllustDetail(this.illustId).then(res=>{
      const resp = res?.toJSON() as IllustDetailResponse
      this.illustId = resp.illust.id
      this.illust = resp.illust
      this.followed = resp.illust.user.is_followed
      this.illustsRawUrl = resp.illust.meta_single_page.original_image_url?[resp.illust.meta_single_page.original_image_url]:resp.illust.meta_pages.map(item=>item.image_urls.original)
    })
  }
  /**
   * 获取相关作品
   */
  private getIllustRelated(){
    ApiClient.getIllustRelated(this.illustId).then(res=>{
      const resp = res?.toJSON() as IllustRelatedResponse
      this.relatedIllusts.push(...resp.illusts)
      this.nextUrl = resp.next_url
    })
  }

  /**
   * 获取评论
   */
  getComments():Promise<CommentsResponse|null>{
    return ApiClient.getIllustComments(this.illustId).then(res=>{
      if (res) {
        return res.toJSON() as CommentsResponse
      }else {
        return null
      }
    })
  }
  /**
   * 获取评论回复
   */
  getCommentReply(commentId:number): Promise<CommentsResponse | null>{
    return ApiClient.getIllustCommentsReplies(commentId).then(res=>{
      if (res) {
        return res.toJSON() as CommentsResponse
      }else {
        return null
      }
    })
  }
  /**
   * 发表评论
   */
  postComment(relateId: number, comment: string, parentCommentId?: number):Promise<boolean>{
    return ApiClient.postIllustComment(relateId,comment,parentCommentId).then(res=>{
      if (res) {
        return true
      }
      return false
    })
  }

  /**
   * 销毁
   */
  destroy(){
    // this.relatedIllusts.destroy()
  }
}