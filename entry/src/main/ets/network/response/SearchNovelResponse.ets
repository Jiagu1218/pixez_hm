import { Novel } from "../model/Novel"

/**
 * 定义搜索小说响应的接口
 */
export interface SearchNovelResponse{
  /**
   * 小说列表
   */
  novels: Novel[]
  /**
   * 下一页的URL，如果为空则表示没有更多结果
   */
  next_url: string|null
  /**
   * 搜索跨度限制，用于控制搜索结果的时间范围或相关性
   */
  search_span_limit: number
  /**
   * 是否展示AI生成的内容
   */
  show_ai: boolean
}
