/**
 * 定义插画收藏详情的响应接口
 * 该接口用于获取插画收藏的详细信息，包括是否收藏、标签和限制级别
 */
export interface IllustBookmarkDetailResponse{
  /**
   * 收藏详情
   */
  bookmark_detail: BookmarkDetail
}

/**
 * 描述收藏详情的信息结构
 * 包含了用户是否已收藏该插画、插画的标签列表以及插画的访问限制情况
 */
export interface BookmarkDetail {
  /**
   * 表示用户是否已收藏该插画
   * true表示已收藏，false表示未收藏
   */
  is_bookmarked: boolean
  /**
   * 插画的标签列表
   * 标签用于描述插画的内容或风格
   */
  tags: Tag[]
  /**
   * 插画的访问限制级别
   * 描述了插画的公开程度，如“公开”或“私密”
   */
  restrict: string
}

/**
 * 定义标签的结构
 * 标签是用来标注插画特征的关键字
 */
export interface Tag {
  /**
   * 标签的名称
   * 是用来描述插画的一个关键字
   */
  name: string
  /**
   * 表示标签是否已注册
   * true表示该标签是官方认可的，false表示是用户自定义的
   */
  is_registered: boolean
}
