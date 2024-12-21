import { Illust } from "../model/Illust";

/**
 * 定义了一个接口，用于描述收藏插画的响应数据结构
 */
export interface BookmarksIllustResponse{
  /**
   * 一个Illust对象的数组，包含了收藏的插画信息
   */
  illusts:Illust[]
  /**
   * 下一页的URL，如果为null，则表示没有更多数据
   */
  next_url:string|null
}
