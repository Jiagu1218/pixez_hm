/**
 * 评论
 */
export interface Comment{
  /**
   * 评论的唯一标识符
   */
  id: number
  /**
   * 评论的内容文本
   */
  comment: string
  /**
   * 评论的创建日期
   */
  date: string
  /**
   * 发表评论的用户信息
   */
  user: User
  /**
   * 表示评论是否有回复
   */
  has_replies: boolean
  /**
   * 可选字段，表示评论的戳信息
   */
  stamp?: Stamp
}

/**
 * 用户
 */
interface User {
  /**
   * 用户的唯一标识符
   */
  id: number
  /**
   * 用户的名称
   */
  name: string
  /**
   * 用户的账号名称
   */
  account: string
  /**
   * 用户的头像URLs
   */
  profile_image_urls: ProfileImageUrls
}

/**
 * 用户头像
 */
interface ProfileImageUrls {
  /**
   * 用户头像的中等尺寸URL
   */
  medium: string
}

/**
 * 戳
 */
interface Stamp {
  /**
   * 戳的唯一标识符
   */
  stamp_id: number
  /**
   * 戳的图片URL
   */
  stamp_url: string
}
