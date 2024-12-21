/**
 * 定义了用户收藏标签的响应接口
 * 该接口主要用于表示从服务器获取的用户收藏标签信息，包括标签列表和下一页的URL
 */
export interface UserBookmarkTagsIllustResponse{
  /**
   * 用户收藏的标签列表，每个标签都包含名称和计数信息
   */
  bookmark_tags: BookmarkTag[]
  /**
   * 用于获取下一页内容的URL
   */
  next_url: string|null
}

/**
 * 定义了收藏标签的接口
 * 该接口用于表示用户收藏的标签，包括标签名称和该标签下的插画数量
 */
export interface BookmarkTag {
  /**
   * 标签的名称
   */
  name: string
  /**
   * 该标签下的插画数量
   */
  count: number
}
