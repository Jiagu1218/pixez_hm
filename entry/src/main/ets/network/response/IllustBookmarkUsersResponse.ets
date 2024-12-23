/**
 * 用于描述插图收藏用户列表响应数据的结构
 */
export interface IllustBookmarkUsersResponse{
  /**
   * 获取到的用户列表
   */
  users: IllustBookmarkUser[]
  /**
   * 下一页的URL，如果为空则表示没有更多数据
   */
  next_url: string|null
}

/**
 * 定义了一个接口，用于描述用户的详细信息
 */
export interface IllustBookmarkUser {
  /**
   * 用户ID
   */
  id: number
  /**
   * 用户名称
   */
  name: string
  /**
   * 用户账号
   */
  account: string
  /**
   * 用户头像URL
   */
  profile_image_urls: ProfileImageUrls
  /**
   * 表示当前用户是否已关注该用户
   */
  is_followed: boolean
  /**
   * 表示当前用户是否屏蔽了该用户
   */
  is_access_blocking_user: boolean
}

/**
 * 定义了一个接口，用于描述用户头像URL的详细信息
 */
interface ProfileImageUrls {
  /**
   * 用户头像的中等尺寸图片URL
   */
  medium: string
}
