import { Illust } from "../model/Illust"
import { PrivacyPolicy } from "../model/PrivacyPolicy"
import { IllustPageResponseBase } from "./IllustPageResponseBase"

/**
 * 漫画推荐response
 * */
export interface MangaRecommendedResponse extends IllustPageResponseBase {
  /**
   * 排行榜插图信息
   * */
  ranking_illusts: Illust[]
  /**
   * 隐私政策
   * */
  privacy_policy: PrivacyPolicy

}
