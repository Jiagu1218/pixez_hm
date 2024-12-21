/**
 * 焦点文章
 */
export interface SpotlightArticle {
  /**
   * 文章的唯一标识符
   */
  id: number
  /**
   * 文章标题
   */
  title: string
  /**
   * 纯净标题，可能用于特定的显示需求或SEO优化
   */
  pure_title: string
  /**
   * 缩略图的URL地址
   */
  thumbnail: string
  /**
   * 文章的URL地址
   */
  article_url: string
  /**
   * 文章的发布日期
   */
  publish_date: string
  /**
   * 文章所属的类别
   */
  category: string
  /**
   * 文章的子类别标签，用于更细致的分类
   */
  subcategory_label: string
}
