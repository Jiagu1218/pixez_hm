import { ApiClient } from "../network/ApiClient"
import { BookmarksIllustResponse } from "../network/response/BookmarksIllustResponse"
import { UserBookmarkTagsIllustResponse } from "../network/response/UserBookmarkTagsIllustResponse"
import { UserDetailResponse } from "../network/response/UserDetailResponse"
import { UserIllustResponse } from "../network/response/UserIllustResponse"
import { UserRouterParam } from "../param/UserRouterParam"
/**
 * 用户详情页视图模型
 */
@ObservedV2
export class UserDetailViewModel{
  /**
   * 用户id
   */
  private userId:number = 0
  /**
   * 路径栈
   */
  private pathStack:NavPathStack|undefined = undefined
  /**
   * 用户详情
   */
  @Trace userDetail:UserDetailResponse|null = null

  /**
   * 初始化
   * @param navInfo
   */
  init(navInfo:NavigationInfo|undefined){
    this.pathStack = navInfo?.pathStack
    if (this.pathStack){
      const param = this.pathStack.getParamByName('userDetailPage').pop() as UserRouterParam
      this.userId = param.userId
      this.getUserDetail()
    }
  }
  /**
   * 获取用户详情
   */
  getUserDetail(){
    ApiClient.getUserDetail(this.userId).then(res => {
      if (res) {
        const resp = res.toJSON() as UserDetailResponse
        this.userDetail = resp
      }
    })
  }

  /**
   * 获取用户详情
   */
  getUserIllusts(): Promise<UserIllustResponse|null>{
    return ApiClient.getUserIllusts(this.userId).then(res => {
      if (res) {
        return res.toJSON() as UserIllustResponse
      }else {
        return null
      }
    })
  }
  /**
   * 获取用户漫画
   */
  getUserManga(): Promise<UserIllustResponse|null>{
    return ApiClient.getUserIllusts(this.userId,'manga').then(res => {
      if (res) {
        return res.toJSON() as UserIllustResponse
      }else {
        return null
      }
    })
  }
  /**
   * 获取用户收藏
   */
  getBookmarksIllust(): Promise<BookmarksIllustResponse|null>{
    return ApiClient.getBookmarksIllust({
      userId:this.userId,
      restrict:'public'
    }).then(res => {
      if (res) {
        return res.toJSON() as BookmarksIllustResponse
      }else {
        return null
      }
    })
  }
  /**
   * 获取用户收藏标签
   */
  getUserBookmarkTagsIllust(): Promise<UserBookmarkTagsIllustResponse|null>{
    return ApiClient.getUserBookmarkTagsIllust(this.userId).then(res => {
      if (res) {
        return res.toJSON() as UserBookmarkTagsIllustResponse
      }else {
        return null
      }
    })
  }
}