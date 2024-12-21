import { Illust } from "../model/Illust"

/**
 * 用户插画响应接口
 * 定义了获取用户插画列表的API响应格式
 * */
export interface UserIllustResponse{
  /**
   * 用户信息
   * 包含用户的详细资料，如ID、用户名、账号等
   * */
  user: User
  /**
   * 插画列表
   * 包含用户发布的插画作品数组
   * */
  illusts: Illust[]
  /**
   * 下一页URL
   * 如果存在更多数据，则该字段提供获取下一页数据的URL
   * */
  next_url: string|null
}

/**
 * 用户信息接口
 * 定义了用户的基本信息结构
 * */
interface User {
  /**
   * 用户ID
   * 唯一标识用户的数字ID
   * */
  id: number
  /**
   * 用户名
   * 用户设定的名称，用于显示
   * */
  name: string
  /**
   * 用户账号
   * 用户的账号名，通常用于登录或标识用户
   * */
  account: string
  /**
   * 用户头像URLs
   * 包含用户头像的不同尺寸的URL
   * */
  profile_image_urls: ProfileImageUrls
  /**
   * 是否已关注
   * 表示当前用户是否关注了该用户
   * */
  is_followed: boolean
  /**
   * 是否是访问限制用户
   * 表示该用户是否设置了访问限制
   * */
  is_access_blocking_user: boolean
}

/**
 * 用户头像URLs接口
 * 定义了用户头像图片的URL结构
 * */
interface ProfileImageUrls {
  /**
   * 中等尺寸头像URL
   * 提供中等尺寸的用户头像图片URL
   * */
  medium: string
}
