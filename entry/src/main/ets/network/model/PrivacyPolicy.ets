/**
 * 隐私政策
 * */
export interface PrivacyPolicy {
  /**
   * 版本号，用于标识隐私政策的版本
   * */
  version: string
  /**
   * 隐私政策的消息内容，用于展示给用户
   * */
  message: string
  /**
   * 隐私政策的URL，提供详细的隐私政策内容链接
   * */
  url: string
}