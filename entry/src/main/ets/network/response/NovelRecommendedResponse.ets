import { Novel } from "../model/Novel"
import { PrivacyPolicy } from "../model/PrivacyPolicy"
import { NovelPageResponseBase } from "./NovelPageResponseBase"

/**
 * 推荐
 * */
export interface NovelRecommendedResponse extends NovelPageResponseBase{
  ranking_novels: Novel[]
  privacy_policy: PrivacyPolicy
}