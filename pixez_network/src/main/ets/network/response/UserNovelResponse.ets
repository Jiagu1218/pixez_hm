import { Novel } from "../model/Novel"

/**
 * 用户小说响应接口
 * 用于定义用户相关小说信息的响应数据结构
 */
export interface UserNovelResponse{
  /**
   * 用户信息
   * 包含用户的详细资料
   */
  user: User
  /**
   * 用户的小说列表
   * 这是一个小说对象的数组，每个对象代表用户的一部小说
   */
  novels: Novel[]
  /**
   * 下一页的URL
   * 用于分页加载更多数据，当数据未结束时，该字段将提供下一页的请求地址
   */
  next_url: string
}

/**
 * 用户信息接口
 * 定义了用户的基本信息结构
 */
interface User {
  /**
   * 用户ID
   * 唯一标识用户的身份
   */
  id: number
  /**
   * 用户名
   * 用户在系统中的名称
   */
  name: string
  /**
   * 用户账号
   * 用户登录时使用的账号
   */
  account: string
  /**
   * 用户头像URL
   * 包含用户头像的中等尺寸图片URL
   */
  profile_image_urls: ProfileImageUrls
  /**
   * 是否被关注
   * 表示当前用户是否被登录用户关注
   */
  is_followed: boolean
  /**
   * 是否是访问限制用户
   * 表示当前用户是否设置了访问限制
   */
  is_access_blocking_user: boolean
}

/**
 * 用户头像URL接口
 * 定义了用户头像不同尺寸的URL结构
 */
interface ProfileImageUrls {
  /**
   * 中等尺寸的头像URL
   * 提供用户头像的中等尺寸图片链接
   */
  medium: string
}
