import { UserPreview } from "../model/UserPreview"
/**
 * 搜索用户响应接口
 * 用于获取搜索用户信息的API响应
 */
export interface SearchUserResponse{
  /**
   * 用户预览列表
   */
  user_previews: UserPreview[]
  /**
   * 下一页URL
   */
  next_url: string
}