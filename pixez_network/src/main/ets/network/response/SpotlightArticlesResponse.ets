import { SpotlightArticle } from "../model/SpotlightArticle"

/**
 * SpotlightArticlesResponse接口定义了spotlight文章响应的结构
 * 该接口包含两部分重要信息：一组spotlight文章和一个指向下一篇章的URL
 */
export interface SpotlightArticlesResponse{
  /**
   * spotlight_articles属性是一个SpotlightArticle对象数组，每个对象代表一篇文章
   * */
  spotlight_articles: SpotlightArticle[]
  /**
   * next_url属性是一个字符串或null，表示下一篇文章的URL，如果没有更多文章，则为null
   * */
  next_url: string|null
}


