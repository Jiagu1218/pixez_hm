import { Illust } from "../model/Illust"
/**
 * 获取热门标签
 */
export interface TrendTagsResponse {
  /**
   * 热门标签
   */
  trend_tags: TrendTag[]
}

export interface TrendTag {
  /**
   * 标签
   */
  tag: string
  /**
   * 翻译
   */
  translated_name?: string
  /**
   * 插画
   */
  illust: Illust
}