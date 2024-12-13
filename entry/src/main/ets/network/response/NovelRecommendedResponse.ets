import { Novel } from "../model/Novel"
import { PrivacyPolicy } from "../model/PrivacyPolicy"
/**
 * 推荐
 * */
export interface NovelRecommendedResponse{
  novels: Novel[]
  ranking_novels: Novel[]
  privacy_policy: PrivacyPolicy
  next_url: string
}