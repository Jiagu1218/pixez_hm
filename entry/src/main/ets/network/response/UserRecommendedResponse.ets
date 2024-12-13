import { Illust } from "../../entity/Illust"
import { Novel } from "../../entity/Novel"

/**
 * 用户推荐响应接口
 * 用于获取用户推荐信息的API响应
 */
export interface UserRecommendedResponse{
  /**
   * 用户信息预览
   * 包含一组用户的预览信息，每个用户附带其部分插画和小说作品
   * */
  user_previews: UserPreview[]
  /**
   * 下一页URL
   * 如果存在更多数据，则该字段提供获取下一页数据的URL
   */
  next_url?: string
}

/**
 * 用户预览接口
 * 用于表示用户的基本信息及其插画和小说作品的预览
 */
interface UserPreview {
  /**
   * 用户信息
   * */
  user: User
  /**
   * 插画作品预览
   * 包含一组插画作品预览信息，每个作品附带其缩略图URL
   */
  illusts: Illust[]
  /**
   * 小说作品预览
   * 包含一组小说作品预览信息，每个作品附带其缩略图URL
   */
  novels: Novel[]
  /**
   * 是否被屏蔽
   * 表示当前用户是否被登录用户屏蔽
   */
  is_muted: boolean
}

/**
 * 用户接口
 * 用于表示用户的基本信息
 */
interface User {
  /**
   * 用户ID
   * 唯一标识用户的数字ID
   */
  id: number
  /**
   * 用户名
   * 用户的昵称
   */
  name: string
  /**
   * 用户账户名
   * 用户的Pixiv账户名
   */
  account: string
  /**
   * 用户头像URLs
   * 包含用户头像的不同尺寸的URL
   */
  profile_image_urls: ProfileImageUrls
  /**
   * 是否被关注
   * 表示当前用户是否被登录用户关注
   */
  is_followed: boolean
}

/**
 * 用户头像URLs接口
 * 用于表示用户头像的中等尺寸图片URL
 */
export interface ProfileImageUrls {
  /**
   * 中等尺寸图片URL
   * */
  medium: string
}
