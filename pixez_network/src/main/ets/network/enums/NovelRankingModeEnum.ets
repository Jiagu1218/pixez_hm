/**
 * 小说排名模式枚举类
 * 用于定义小说排名的各种模式，包括日榜、周榜、AI推荐等不同维度的排名
 */
export enum NovelRankingModeEnum{
  /**
   * 日榜
   */
  DAY = "day",
  /**
   * 男性向日榜
   */
  DAY_MALE = "day_male",
  /**
   * 女性向日榜
   */
  DAY_FEMALE = "day_female",
  /**
   * 周榜
   */
  WEEK = "week",
  /**
   * AI推荐周榜
   */
  WEEK_AI = "week_ai",
  /**
   * AI推荐R18周榜
   */
  WEEK_AI_R18 = "week_ai_r18",
  /**
   * R18日榜
   */
  DAY_R18 = "day_r18",
  /**
   * R18周榜
   */
  WEEK_R18 = "week_r18",
  /**
   * R18+周榜
   */
  WEEK_R18G = "week_r18g"
}
