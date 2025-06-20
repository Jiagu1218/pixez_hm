import { Illust } from "./Illust"
import { Novel } from "./Novel"

/**
 * 用户预览
 * 用于表示用户的基本信息及其插画和小说作品的预览
 */
export interface UserPreview {
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
interface ProfileImageUrls {
  /**
   * 中等尺寸图片URL
   * */
  medium: string
}