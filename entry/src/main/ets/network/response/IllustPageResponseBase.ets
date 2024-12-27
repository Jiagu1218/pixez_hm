import { Illust } from "../model/Illust"

/**
 * 插画（漫画）页面响应的基础接口
 */
export interface IllustPageResponseBase{
  /**
   * 插画列表
   */
  illusts:Illust[]
  /**
   * 下一页URL，如果为空则表示没有更多页面
   */
  next_url:string|null
}

