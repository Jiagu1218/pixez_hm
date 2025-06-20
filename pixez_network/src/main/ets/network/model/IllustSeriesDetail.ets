/**
 * 插画系列详情接口
 * 该接口定义了插画系列的详细信息，包括插画的基本信息、用户信息以及系列作品的统计信息等
 */
export interface IllustSeriesDetail {
  /**
   * 插画ID
   */
  id: number
  /**
   * 插画标题
   * 描述插画内容的简短文字
   */
  title: string
  /**
   * 插画说明
   * 插画的详细描述，可能包含创作背景、故事等内容
   */
  caption: string
  /**
   * 封面图片URLs
   * 插画系列的封面图片，提供不同尺寸的URL
   */
  cover_image_urls: CoverImageUrls
  /**
   * 系列作品数量
   * 表示该系列包含的插画作品总数
   */
  series_work_count: number
  /**
   * 创建日期
   * 插画系列创建的日期时间，以字符串形式表示
   */
  create_date: string
  /**
   * 宽度
   * 插画的宽度，以像素为单位
   */
  width: number
  /**
   * 高度
   * 插画的高度，以像素为单位
   */
  height: number
  /**
   * 用户信息
   * 插画作者的详细信息，包括用户ID、用户名等
   */
  user: User
  /**
   * 是否添到追更列表
   */
  watchlist_added: boolean
}

/**
 * 封面图片URLs接口
 * 该接口定义了封面图片的不同尺寸URL
 */
interface CoverImageUrls {
  /**
   * 中等尺寸图片URL
   * 封面图片的中等尺寸版本，适用于大多数显示需求
   */
  medium: string
}

/**
 * 用户信息接口
 * 该接口定义了用户的基本信息，包括用户的ID、名称、账号以及头像等
 */
interface User {
  /**
   * 用户ID
   * 唯一标识用户的编号
   */
  id: number
  /**
   * 用户名
   * 用户设定的名称，用于展示
   */
  name: string
  /**
   * 用户账号
   * 用户的登录账号，通常不直接展示
   */
  account: string
  /**
   * 用户头像URLs
   * 用户的头像图片，提供不同尺寸的URL
   */
  profile_image_urls: ProfileImageUrls
  /**
   * 是否已关注
   * 表示当前用户是否关注了该用户
   */
  is_followed: boolean
}

/**
 * 用户头像URLs接口
 * 该接口定义了用户头像的不同尺寸URL
 */
interface ProfileImageUrls {
  /**
   * 中等尺寸头像URL
   * 用户头像的中等尺寸版本，适用于大多数显示需求
   */
  medium: string
}
