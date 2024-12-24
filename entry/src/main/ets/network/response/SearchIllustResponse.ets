import { Illust } from "../model/Illust"

export interface SearchIllustResponse{
  /**
   * 插画列表
   */
  illusts: Illust[]
  /**
   * 下一页的URL，如果为空则表示没有更多数据
   */
  next_url: string|null
  /**
   * 搜索结果的时间跨度限制，表示搜索结果覆盖的天数
   */
  search_span_limit: number
  /**
   * 是否展示AI生成的内容
   */
  show_ai: boolean
}
