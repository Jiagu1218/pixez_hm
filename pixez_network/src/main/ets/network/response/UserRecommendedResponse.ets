import { UserPreview } from "../model/UserPreview"

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


