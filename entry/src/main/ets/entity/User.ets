/**
 * 用户信息
 * */
export interface User {
  /**
   * 用户唯一标识符
   * */
  id: string
  /**
   * 用户头像信息
   * 包含不同尺寸的头像URL
   * */
  profile_image_urls: ProfileImageUrls
  /**
   * 用户名称
   * */
  name: string
  /**
   * 用户账号
   * 通常用于登录或标识用户
   * */
  account: string
  /**
   * 邮箱地址
   * 用于用户注册或找回密码
   * */
  mail_address: string
  /**
   * 是否是高级用户
   * 高级用户可能享有一些特权或服务
   * */
  is_premium: boolean
  /**
   * 内容限制级别
   * 数值表示用户可以访问的内容限制级别
   * */
  x_restrict: number
  /**
   * 邮箱是否已验证
   * 表示用户的邮箱地址是否已经过验证
   * */
  is_mail_authorized: boolean
  /**
   * 是否需要同意政策
   * 表示用户是否需要同意最新的政策条款
   * */
  require_policy_agreement: boolean
}

/**
 * 用户头像信息
 * 包含不同尺寸的头像URL
 * */
interface ProfileImageUrls {
  /**
   * 16x16像素的头像URL
   * */
  px_16x16: string
  /**
   * 50x50像素的头像URL
   * */
  px_50x50: string
  /**
   * 170x170像素的头像URL
   * */
  px_170x170: string
}
