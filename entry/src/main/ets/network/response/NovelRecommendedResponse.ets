import { Novel } from "../../entity/Novel"
import { PrivacyPolicy } from "../../entity/PrivacyPolicy"
/**
 * 推荐
 * */
export interface NovelRecommendedResponse{
  novels: Novel[]
  ranking_novels: Novel[]
  privacy_policy: PrivacyPolicy
  next_url: string
}