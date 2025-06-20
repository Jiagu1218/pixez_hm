import { NovelPageResponseBase } from "./NovelPageResponseBase"

/**
 * 定义搜索小说响应的接口
 */
export interface SearchNovelResponse extends NovelPageResponseBase{
  /**
   * 搜索跨度限制，用于控制搜索结果的时间范围或相关性
   */
  search_span_limit: number
  /**
   * 是否展示AI生成的内容
   */
  show_ai: boolean
}
