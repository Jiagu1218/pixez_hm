import { Illust } from "../model/Illust"
import { PrivacyPolicy } from "../model/PrivacyPolicy"
import { IllustPageResponseBase } from "./IllustPageResponseBase"

/**
 * 定义插画推荐响应接口
 * 该接口用于描述插画推荐服务返回的数据结构，包括一系列插画、排名插画、比赛状态、隐私政策及下一页URL
 */
export interface IllustRecommendedResponse extends IllustPageResponseBase {
  /**
   * 排名插画列表
   * */
  ranking_illusts: Illust[]
  /**
   * 是否存在比赛
   * */
  contest_exists: boolean
  /**
   * 隐私政策
   * */
  privacy_policy: PrivacyPolicy

}
