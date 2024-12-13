import { Illust } from "../../entity/Illust"
import { PrivacyPolicy } from "../../entity/PrivacyPolicy"
/**
 * 漫画推荐response
 * */
export interface MangaRecommendedResponse {
  /**
   * 插图信息
   * */
  illusts: Illust[]
  /**
   * 排行榜插图信息
   * */
  ranking_illusts: Illust[]
  /**
   * 隐私政策
   * */
  privacy_policy: PrivacyPolicy
  /**
   * 下一页的URL，如果存在
   * */
  next_url?: string
}
