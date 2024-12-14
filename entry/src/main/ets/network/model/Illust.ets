/**
 * 插画接口定义了插画作品的相关信息
 * 它包括了从插画的唯一标识符到用户和标签等详细信息
 * 该接口还定义了与插画相关的一些统计信息，如浏览总数和收藏总数
 */
export interface Illust{
  /**
   * 插画的唯一标识符
   */
  id: number
  /**
   * 插画的标题
   */
  title: string
  /**
   * 插画的类型
   */
  type: string
  /**
   * 插画的图片URLs，包含不同尺寸的图片
   */
  image_urls: ImageUrls
  /**
   * 插画的描述
   */
  caption: string
  /**
   * 插画的访问限制级别
   */
  restrict: number
  /**
   * 插画的作者信息
   */
  user: User
  /**
   * 插画的标签列表
   */
  tags: Tag[]
  /**
   * 用于创作插画的工具列表
   */
  tools: string[]
  /**
   * 插画的创建日期
   */
  create_date: string
  /**
   * 插画的页面数量
   */
  page_count: number
  /**
   * 插画的宽度
   */
  width: number
  /**
   * 插画的高度
   */
  height: number
  /**
   * 插画的内容健康度评级
   */
  sanity_level: number
  /**
   * 插画的另一个访问限制级别
   */
  x_restrict: number
  /**
   * 插画所属的系列信息，如果有的话
   */
  series?: Series
  /**
   * 单页插画的元数据
   */
  meta_single_page: MetaSinglePage
  /**
   * 多页插画的元数据列表
   */
  meta_pages: MetaPage[]
  /**
   * 插画的总浏览量
   */
  total_view: number
  /**
   * 插画的总收藏数
   */
  total_bookmarks: number
  /**
   * 当前用户是否收藏了这幅插画
   */
  is_bookmarked: boolean
  /**
   * 插画是否可见
   */
  visible: boolean
  /**
   * 当前用户是否静音了这幅插画
   */
  is_muted: boolean
  /**
   * 插画的AI类型
   */
  illust_ai_type: number
  /**
   * 插画的书籍风格类型
   */
  illust_book_style: number
}

/**
 * 图片URLs接口定义了插画不同尺寸图片的URL
 */
interface ImageUrls {
  square_medium: string
  medium: string
  large: string
}

/**
 * 用户接口定义了插画作者的相关信息
 */
interface User {
  id: number
  name: string
  account: string
  profile_image_urls: ProfileImageUrls
  is_followed: boolean
}

/**
 * 用户头像URLs接口定义了用户头像不同尺寸的URL
 */
interface ProfileImageUrls {
  medium: string
}

/**
 * 标签接口定义了插画标签的信息，包括标签名和可选的翻译名
 */
export interface Tag {
  name: string
  translated_name?: string
}

/**
 * 单页元数据接口定义了单页插画的元数据，主要是原始图片的URL
 */
interface MetaSinglePage {
  original_image_url?: string
}

/**
 * 元数据页面接口定义了多页插画中每页的图片URLs
 */
export interface MetaPage {
  image_urls: ImageUrls2
}

/**
 * 图片URLs2接口扩展了ImageUrls，增加了原始尺寸图片的URL
 */
interface ImageUrls2 {
  square_medium: string
  medium: string
  large: string
  original: string
}

/**
 * 系列接口定义了插画所属系列的信息，包括系列的唯一标识符和标题
 */
interface Series {
  id: number
  title: string
}
