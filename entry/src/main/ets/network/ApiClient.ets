import { ApiUtil } from "../util/ApiUtil";
import { rcp } from "@kit.RemoteCommunicationKit";
import { url } from "@kit.ArkTS";
import { AppConfig } from "./AppConfig";

/**
 * api
 * @see https://github.com/Notsfsssf/pixez-flutter/blob/master/lib/network/api_client.dart
 * TODO 完善force相关操作（缓存机制？）
 * */
export class ApiClient {
  /**
   * 获取用户收藏的小说
   *
   * @param userId 用户ID
   * @param restrict 查看限制类型
   * @returns 返回包含用户收藏小说信息的Promise对象
   */
  public static getUserBookmarkNovel(userId: string, restrict: string): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'user_id': userId,
      'restrict': restrict
    })
    return ApiUtil.get(`/v1/user/bookmarks/novel?${params}`)
  }

  /**
   * 添加收藏
   *
   * @param novelId 小说ID
   * @param restrict 收藏限制类型
   * @returns 返回表示收藏结果的Promise对象
   */
  public static postNovelBookmarkAdd(novelId: number, restrict: string): Promise<rcp.Response | null> {
    return ApiUtil.post('/v2/novel/bookmark/add', new rcp.Form({
      'novel_id': novelId,
      'restrict': restrict
    }))
  }

  /**
   * 移除收藏
   *
   * @param novelId 小说ID
   * @returns 返回表示移除收藏结果的Promise对象
   */
  public static postNovelBookmarkDelete(novelId: number): Promise<rcp.Response | null> {
    return ApiUtil.post('/v1/novel/bookmark/delete', new rcp.Form({
      'novel_id': novelId
    }))
  }

  /**
   * 获取排行榜
   *
   * @param mode 排行榜模式
   * @param date 日期
   * @returns 返回包含排行榜信息的Promise对象
   */
  public static getNovelRanking(mode: string, date: string): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'filter': 'for_android',
      'mode': mode,
      'date': date
    })
    return ApiUtil.get(`/v1/novel/ranking?${params}`)
  }

  /**
   * 获取小说文本
   *
   * @param novelId 小说ID
   * @returns 返回包含小说文本信息的Promise对象
   */
  public static getNovelText(novelId: number): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'novel_id': novelId.toString()
    })
    return ApiUtil.get(`/v1/novel/text?${params}`)
  }

  /**
   * 获取小说Web视图
   *
   * @param novelId 小说ID
   * @returns 返回包含小说Web视图信息的Promise对象
   */
  public static webviewNovel(novelId: number): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'novel_id': novelId.toString()
    })
    return ApiUtil.get(`/webview/v2/novel?${params}`)
  }

  /**
   * 获取小说详情
   *
   * @param novelId 小说ID
   * @returns 返回包含小说详情信息的Promise对象
   */
  public static getNovelDetail(novelId: number): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'novel_id': novelId.toString()
    })
    return ApiUtil.get(`/v2/novel/detail?${params}`)
  }

  /**
   * 获取小说关注信息
   *
   * @param restrict 关注限制类型
   * @returns 返回包含小说关注信息的Promise对象
   */
  public static getNovelFollow(restrict: string): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'restrict': restrict
    })
    return ApiUtil.get(`/v1/novel/follow?${params}`)
  }

  /**
   * 获取小说推荐
   *
   * 该方法用于获取针对Android用户的小说推荐，包括隐私策略和排名小说信息
   *
   * @returns {Promise<rcp.Response | null>} 返回一个Promise，包含响应对象或null
   */
  public static getNovelRecommended(): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'include_privacy_policy': 'true',
      'filter': 'for_android',
      'include_ranking_novels': 'true'
    })
    return ApiUtil.get(`/v1/novel/recommended?${params}`)
  }

  /**
   * 获取插图推荐
   *
   * 该方法用于获取针对iOS用户的插图推荐，包括排名标签信息
   *
   * @returns {Promise<rcp.Response | null>} 返回一个Promise，包含响应对象或null
   */
  public static getIllustRecommend(): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'filter': 'for_ios',
      'include_ranking_label': 'true'
    })
    return ApiUtil.get(`/v1/illust/recommended?${params}`)
  }

  /**
   * 获取漫画推荐
   *
   * @returns {Promise<rcp.Response | null>} 返回一个Promise，包含响应对象或null
   */
  public static getMangaRecommend():  Promise<rcp.Response | null>{
    // 创建URL参数，指定过滤条件和包含的标签信息
    const params = new url.URLParams({
      'filter': 'for_ios',
      'include_ranking_label': 'true'
    })
    return ApiUtil.get(`/v1/manga/recommended?${params}`)
  }

  /**
   * 获取用户推荐
   *
   * 该方法用于获取针对Android用户的个性化用户推荐
   *
   * @param force {boolean} 是否强制获取推荐，默认为false
   * @returns {Promise<rcp.Response | null>} 返回一个Promise，包含响应对象或null
   */
  public static getUserRecommended(force: boolean = false): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'filter': 'for_android'
    })
    if (force) {

    }
    return ApiUtil.get(`/v1/user/recommended?${params}`)
  }

  /**
   * 获取用户详情
   *
   * 该方法用于获取指定用户的详细信息
   *
   * @param userId {string} 用户ID
   * @returns {Promise<rcp.Response | null>} 返回一个Promise，包含响应对象或null
   */
  public static getUser(userId: string): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'filter': 'for_android',
      'user_id': userId
    })
    return ApiUtil.get(`/v1/user/detail?${params}`)
  }

  /**
   * 更新用户详情?
   *
   * 该方法用于更新用户详情，可选参数a和b用于定制化更新内容
   *
   * @param param {PostUserParam} 可选参数，默认为undefined
   * @returns {Promise<rcp.Response | null>} 返回一个Promise，包含响应对象或null
   *
   */
  public static postUser(param?: PostUserParam): Promise<rcp.Response | null> {

    const record = ApiUtil.noNullRecord(param)
    const form = new rcp.Form(record)
    return ApiUtil.post('/v1/user/detail', form)
  }

  /**
   * 喜欢插图
   *
   * 该方法用于将某插图添加到用户喜欢的列表中，可指定标签
   *
   * @param illustId {number} 插图ID
   * @param restrict {string} 访问限制
   * @param tags {Array<string>} 插图标签数组
   * @returns {Promise<rcp.Response | null>} 返回一个Promise，包含响应对象或null
   */
  public static postLikeIllust(illustId: number, restrict: string, tags: Array<string>): Promise<rcp.Response | null> {
    let form = new rcp.Form({
      'illust_id': illustId,
      'restrict': restrict
    })
    if (tags && tags.length > 0) {
      form.fields['tags[]'] = tags.join(' ')
    }
    return ApiUtil.post('/v2/illust/bookmark/add', form)
  }

  /**
   * 取消喜欢插图
   *
   * 该方法用于从用户喜欢的列表中移除某插图
   *
   * @param illust_id {number} 插图ID
   * @returns {Promise<rcp.Response | null>} 返回一个Promise，包含响应对象或null
   */
  public static postUnLikeIllust(illust_id: number): Promise<rcp.Response | null> {
    return ApiUtil.post('/v1/illust/bookmark/delete', new rcp.Form({ 'novel_id': illust_id }))
  }

  /**
   * 取消收藏插画
   * @param illustId 插画ID
   * @returns 返回取消收藏的响应结果，如果没有登录或插画不存在，则返回null
   */
  public static getUnlikeIllust(illustId: number): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'illust_id': illustId.toString()
    })
    return ApiUtil.get(`/v1/illust/bookmark/delete?${params}`)
  }

  /**
   * 获取下一页数据
   * @param url 下一页的URL
   * @returns 返回下一页数据的响应结果，如果没有更多数据则返回null
   */
  public static getNext(url: string): Promise<rcp.Response | null> {
    const finalUrl = url.replaceAll('app-api.pixiv.net', AppConfig.BASE_API_URL.replace('https://', ''))
    return ApiUtil.get(finalUrl)
  }

  /**
   * 获取插画排名
   * @param mode 排名模式
   * @param date 日期
   * @param force 是否强制刷新缓存
   * @returns 返回插画排名的响应结果，如果日期无效或模式不支持则返回null
   */
  public static getIllustRanking(mode: string, date: string, force: boolean = false): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'filter': 'for_android',
      'mode': mode,
      'date': date
    })
    return ApiUtil.get(`/v1/illust/ranking?${params}`)
  }

  /**
   * 获取用户插画列表
   * @param userId 用户ID
   * @param type 插画类型
   * @returns 返回用户插画列表的响应结果，如果用户不存在或类型不支持则返回null
   */
  public static getUserIllusts(userId: number, type: string): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'filter': 'for_android',
      'user_id': userId.toString(),
      'type': type
    })
    return ApiUtil.get(`/v1/user/illusts?${params}`)
  }

  /**
   * 根据偏移量获取用户插画列表
   * @param userId 用户ID
   * @param type 插画类型
   * @param offset 偏移量
   * @returns 返回根据偏移量获取的用户插画列表的响应结果，如果用户不存在或类型不支持则返回null
   */
  public static getUserIllustsOffset(userId: number, type: string, offset?: number): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'filter': 'for_android',
      'user_id': userId.toString(),
      'type': type
    })
    if (offset) {
      params.set('offset', offset.toString())
    }
    return ApiUtil.get(`/v1/user/illusts?${params}`)
  }

  /**
   * 根据偏移量获取用户收藏的插画列表
   * @param param {BookmarksIllustsOffsetParam}
   * @returns 返回根据偏移量获取的用户收藏的插画列表的响应结果，如果用户不存在或收藏设置不支持则返回null
   */
  public static getBookmarksIllustsOffset(param: BookmarksIllustsOffsetParam): Promise<rcp.Response | null> {
    const record = ApiUtil.noNullRecord(param)
    const params = new url.URLParams(record)
    return ApiUtil.get(`/v1/user/bookmarks/illust?${params}`)
  }

  /**
   * 获取用户小说列表
   * @param userId 用户ID
   * @returns 返回用户小说列表的Promise对象，可能为null
   */
  public static getUserNovels(userId: number): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'filter': 'for_android',
      'user_id': userId.toString()
    })
    return ApiUtil.get(`/v1/user/novels?${params}`)
  }

  /**
   * 获取用户收藏的插画
   * @param userId 用户ID
   * @param restrict 内容限制级别
   * @param tag 可选参数，指定标签
   * @returns 返回用户收藏插画列表的Promise对象，可能为null
   */
  public static getBookmarksIllust(userId: number, restrict: string, tag?: string): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'user_id': userId.toString(),
      'restrict': restrict
    })
    if (tag) {
      params.set('tag', tag)
    }
    return ApiUtil.get(`/v1/user/bookmarks/illust?${params}`)
  }

  /**
   * 取消关注用户
   * @param userId 要取消关注的用户ID
   * @returns 返回取消关注结果的Promise对象，可能为null
   */
  public static postUnFollowUser(userId: number): Promise<rcp.Response | null> {
    return ApiUtil.post('/v1/user/follow/delete', new rcp.Form({ 'user_id': userId }))
  }

  /**
   * 获取用户关注者列表
   * @param userId 用户ID
   * @param restrict 内容限制级别
   * @returns 返回用户关注者列表的Promise对象，可能为null
   */
  public static getFollowUser(userId: number, restrict: string): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'filter': 'for_android',
      'user_id': userId.toString(),
      'restrict': restrict
    })
    return ApiUtil.get(`/v1/user/follower?${params}`)
  }

  /**
   * 获取用户关注的插画列表
   * @param restrict 内容限制级别
   * @param force 是否强制刷新数据，默认为false
   * @returns 返回用户关注插画列表的Promise对象，可能为null
   */
  public static getFollowIllusts(restrict: string, force: boolean = false): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'restrict': restrict
    })
    return ApiUtil.get(`/v2/illust/follow?${params}`)
  }

  /**
   * 获取用户正在关注的用户列表
   * @param userId 用户ID
   * @param restrict 内容限制级别
   * @returns 返回用户正在关注的用户列表的Promise对象，可能为null
   */
  public static getUserFollowing(userId: number, restrict: string): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'filter': 'for_android',
      'user_id': userId.toString(),
      'restrict': restrict
    })
    return ApiUtil.get(`/v1/user/following?${params}`)
  }

  /**
   * 获取搜索自动完成关键词
   * @param word 输入的搜索关键词
   * @returns 返回搜索自动完成关键词列表的Promise对象，可能为null
   */
  public static getSearchAutoCompleteKeywords(word: string): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'merge_plain_keyword_results': 'true',
      'word': word
    })
    return ApiUtil.get(`/v2/search/autocomplete?${params}`)
  }

  /**
   * 获取插画趋势标签
   * @param force 是否强制刷新数据，默认为false
   * @returns 返回插画趋势标签列表的Promise对象，可能为null
   */
  public static getIllustTrendTags(force: boolean = false): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'filter': 'for_android'
    })
    return ApiUtil.get(`/v1/trending-tags/illust?${params}`)
  }

  /**
   * 获取小说趋势标签
   *
   * @param force 是否强制获取数据，默认为false
   * @returns 返回包含趋势标签的Promise对象，如果获取失败则返回null
   */
  public static getNovelTrendTags(force: boolean = false): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'filter': 'for_android'
    })
    return ApiUtil.get(`/v1/trending-tags/novel?${params}`)
  }

  /**
   * 搜索插图
   *
   * @param param {SearchIllustParam} 搜索参数对象
   * @returns 返回包含搜索结果的Promise对象，如果搜索失败则返回null
   */
  public static getSearchIllust(param: SearchIllustParam): Promise<rcp.Response | null> {
    const record = ApiUtil.noNullRecord(param)
    const params = new url.URLParams(record)
    params.set('filter', 'for_android')
    params.set('merge_plain_keyword_results', 'true')
    if (params.has('bookmark_num')){
      params.delete('bookmark_num')
    }
    // 处理书签数量范围
    if (param.bookmarkNum) {
      const bookmarkNumMin = param.bookmarkNum[0]
      const bookmarkNumMax = param.bookmarkNum[1]
      params.set('bookmark_num_min', bookmarkNumMin.toString())
      params.set('bookmark_num_max', bookmarkNumMax.toString())
    }
    return ApiUtil.get(`/v1/search/illust?${params}`)
  }

  /**
   * 搜索小说
   *
   * @param param {SearchNovelParam} 搜索参数对象
   * @returns 返回包含搜索结果的Promise对象，如果搜索失败则返回null
   */
  public static getSearchNovel(param: SearchNovelParam): Promise<rcp.Response | null> {
    const record = ApiUtil.noNullRecord(param)
    const params = new url.URLParams(record)
    params.set('filter', 'for_android')
    params.set('merge_plain_keyword_results', 'true')
    return ApiUtil.get(`/v1/search/novel?${params}`)
  }

  /**
   * 搜索用户
   *
   * @param word 搜索关键词
   * @returns 返回包含搜索结果的Promise对象，如果搜索失败则返回null
   */
  public static getSearchUser(word: string): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'filter': 'for_android',
      'word': word
    })
    return ApiUtil.get(`/v1/search/user?${params}`)
  }

  /**
   * 获取搜索自动补全结果
   * @param word 搜索关键词
   * @returns 返回搜索自动补全的响应结果，如果没有结果则返回null
   */
  public static getSearchAutocomplete(word: string): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'merge_plain_keyword_results': 'true',
      'word': word
    })
    return ApiUtil.get(`/v2/search/autocomplete?${params}`)
  }

  /**
   * 获取插画相关推荐
   * @param illustId 插画ID
   * @param force 是否强制刷新缓存，默认为false
   * @returns 返回相关插画的响应结果，如果没有结果则返回null
   */
  public static getIllustRelated(illustId: number, force: boolean = false): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'filter': 'for_android',
      'illust_id': illustId.toString()
    })
    return ApiUtil.get(`/v2/illust/related?${params}`)
  }

  /**
   * 获取插画收藏详情
   * @param illustId 插画ID
   * @returns 返回插画收藏详情的响应结果，如果没有结果则返回null
   */
  public static getIllustBookmarkDetail(illustId: number): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'illust_id': illustId.toString()
    })
    return ApiUtil.get(`/v2/illust/bookmark/detail?${params}`)
  }

  /**
   * 取消关注用户
   * @param userId 用户ID
   * @returns 返回取消关注用户的响应结果，如果没有结果则返回null
   */
  public static postUnfollowUser(userId: number): Promise<rcp.Response | null> {
    return ApiUtil.post('/v1/user/follow/delete', new rcp.Form({ 'user_id': userId }))
  }

  /**
   * 关注用户
   * @param userId 用户ID
   * @param restrict 关注类型
   * @returns 返回关注用户的响应结果，如果没有结果则返回null
   */
  public static postFollowUser(userId: number, restrict: string): Promise<rcp.Response | null> {
    return ApiUtil.post('/v1/user/follow/add', new rcp.Form({ 'user_id': userId, 'restrict': restrict }))
  }

  /**
   * 获取插画详情
   * @param illustId 插画ID
   * @returns 返回插画详情的响应结果，如果没有结果则返回null
   */
  public static getIllustDetail(illustId: number): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'filter': 'for_android',
      'illust_id': illustId.toString()
    })
    return ApiUtil.get(`/v1/illust/detail?${params}`)
  }

  /**
   * 获取焦点文章
   * @param category 文章分类
   * @param force 是否强制刷新缓存，默认为false
   * @returns 返回焦点文章的响应结果，如果没有结果则返回null
   */
  public static getSpotlightArticles(category: string, force: boolean = false): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'filter': 'for_android',
      'category': category
    })
    return ApiUtil.get(`/v1/spotlight/articles?${params}`)
  }

  /**
   * 获取插画评论
   * @param illustId 插画ID
   * @param force 是否强制刷新缓存，默认为false
   * @returns 返回插画评论的响应结果，如果没有结果则返回null
   */
  public static getIllustComments(illustId: number, force: boolean = false): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'illust_id': illustId.toString()
    })
    return ApiUtil.get(`/v3/illust/comments?${params}`)
  }

  /**
   * 获取小说评论
   * @param novelId 小说ID
   * @param force 是否强制刷新数据，默认为false
   * @returns 返回Promise，解析为rcp.Response对象或null
   */
  public static getNovelComments(novelId: number, force: boolean = false): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'novel_id': novelId.toString()
    })
    return ApiUtil.get(`/v3/novel/comments?${params}`)
  }

  /**
   * 获取插图评论回复
   * @param commentId 评论ID
   * @returns 返回Promise，解析为rcp.Response对象或null
   */
  public static getIllustCommentsReplies(commentId: number): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'comment_id': commentId.toString()
    })
    return ApiUtil.get(`/v2/illust/comment/replies?${params}`)
  }

  /**
   * 获取小说评论回复
   * @param commentId 评论ID
   * @returns 返回Promise，解析为rcp.Response对象或null
   */
  public static getNovelCommentsReplies(commentId: number): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'comment_id': commentId.toString()
    })
    return ApiUtil.get(`/v2/novel/comment/replies?${params}`)
  }

  /**
   * 发布插图评论
   * @param illustId 插图ID
   * @param comment 评论内容
   * @param parentCommentId 父评论ID，可选参数
   * @returns 返回Promise，解析为rcp.Response对象或null
   */
  public static postIllustComment(illustId: number, comment: string,
    parentCommentId?: number): Promise<rcp.Response | null> {
    const form = new rcp.Form({
      'illust_id': illustId,
      'comment': comment
    })
    if (parentCommentId) {
      form.fields['parent_comment_id'] = parentCommentId
    }
    return ApiUtil.post('/v1/illust/comment/add', form)
  }

  /**
   * 发布小说评论
   * @param novelId 小说ID
   * @param comment 评论内容
   * @param parentCommentId 父评论ID，可选参数
   * @returns 返回Promise，解析为rcp.Response对象或null
   */
  public static postNovelComment(novelId: number, comment: string,
    parentCommentId?: number): Promise<rcp.Response | null> {
    const form = new rcp.Form({
      'novel_id': novelId,
      'comment': comment
    })
    if (parentCommentId) {
      form.fields['parent_comment_id'] = parentCommentId
    }
    return ApiUtil.post('/v1/novel/comment/add', form)
  }

  /**
   * 获取动图元数据
   * @param illustId 插图ID
   * @returns 返回Promise，解析为rcp.Response对象或null
   */
  public static getUgoiraMetadata(illustId: number): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'illust_id': illustId.toString()
    })
    return ApiUtil.get(`/v1/ugoira/metadata?${params}`)
  }

  /**
   * 获取用户插图书签标签
   * @param userId 用户ID
   * @param restrict 限制类型，默认为'public'
   * @returns 返回Promise，解析为rcp.Response对象或null
   */
  public static getUserBookmarkTagsIllust(userId: number, restrict: string = 'public'): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'user_id': userId.toString(),
      'restrict': restrict
    })
    return ApiUtil.get(`/v1/user/bookmark-tags/illust?${params}`)
  }

  /**
   * 获取引导插图
   *
   * 该方法用于获取应用程序引导页面展示的插图资源
   * 它通过API请求来获取数据，并返回相应的响应结果
   *
   * @returns {Promise<rcp.Response | null>} 返回获取到的插图资源响应结果，如果没有数据则返回null
   */
  public static walkthroughIllusts(): Promise<rcp.Response | null> {
    return ApiUtil.get('/v1/walkthrough/illusts')
  }

  /**
   * 获取热门预览插图
   *
   * 该方法根据搜索关键词获取热门预览的插图资源
   * 它构造了带有多个过滤条件的URL参数，并通过API请求来获取数据
   *
   * @param {string} word 搜索关键词
   * @returns {Promise<rcp.Response | null>} 返回获取到的热门预览插图资源响应结果，如果没有数据则返回null
   */
  public static getPopularPreview(word: string): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'filter': 'for_android',
      'include_translated_tag_results': 'true',
      'merge_plain_keyword_results': 'true',
      'word': word
    })
    return ApiUtil.get(`/v1/search/popular-preview/illust?${params}`)
  }

  /**
   * 获取用户AI设置
   *
   * 该方法用于获取当前用户的AI展示设置
   * 它通过API请求来获取数据，并返回相应的响应结果
   *
   * @returns {Promise<rcp.Response | null>} 返回获取到的用户AI设置响应结果，如果没有数据则返回null
   */
  public static getUserAISettings(): Promise<rcp.Response | null> {
    return ApiUtil.get('/v1/user/ai-show-settings')
  }

  /**
   * 更新用户AI展示设置
   *
   * 该方法用于更新用户是否展示AI内容的设置
   * 它通过API请求发送新的设置信息，并返回相应的响应结果
   *
   * @param {boolean} showAi 是否展示AI内容的标志
   * @returns {Promise<rcp.Response | null>} 返回更新后的用户AI设置响应结果，如果没有数据则返回null
   */
  public static postUserAIShowSettings(showAi: boolean): Promise<rcp.Response | null> {
    return ApiUtil.post('/v1/user/ai-show-settings/edit', new rcp.Form({ 'show_ai': showAi }))
  }

  /**
   * 获取小说系列信息
   *
   * 该方法根据系列ID获取小说系列的详细信息
   * 它构造了带有系列ID的URL参数，并通过API请求来获取数据
   *
   * @param {string} seriesId 小说系列的唯一标识符
   * @returns {Promise<rcp.Response | null>} 返回获取到的小说系列信息响应结果，如果没有数据则返回null
   */
  public static novelSeries(seriesId: string): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'series_id': seriesId
    })
    return ApiUtil.get(`/v2/novel/series?${params}`)
  }

  /**
   * 获取下一个小说系列信息
   *
   * 该方法与`novelSeries`类似，用于获取下一个小说系列的详细信息
   * 它同样构造了带有系列ID的URL参数，并通过API请求来获取数据
   *
   * @param {string} seriesId 小说系列的唯一标识符
   * @returns {Promise<rcp.Response | null>} 返回获取到的下一个小说系列信息响应结果，如果没有数据则返回null
   */
  public static nextNovelSeries(seriesId: string): Promise<rcp.Response | null> {
    const params = new url.URLParams({
      'series_id': seriesId
    })
    return ApiUtil.get(`/v2/novel/series?${params}`)
  }

  /**
   * 将小说系列添加到观看列表
   *
   * 该方法用于将指定的小说系列添加到用户的观看列表中
   * 它通过API请求发送系列ID，并返回相应的响应结果
   *
   * @param {string} seriesId 小说系列的唯一标识符
   * @returns {Promise<rcp.Response | null>} 返回添加小说系列到观看列表后的响应结果，如果没有数据则返回null
   */
  public static watchListNovelAdd(seriesId: string) {
    return ApiUtil.post('/v1/watchlist/novel/add', new rcp.Form({ 'series_id': seriesId }))
  }

  /**
   * 从观看列表中删除小说系列
   *
   * 该方法用于从用户的观看列表中删除指定的小说系列
   * 它通过API请求发送系列ID，并返回相应的响应结果
   *
   * @param {string} seriesId 小说系列的唯一标识符
   * @returns {Promise<rcp.Response | null>} 返回从观看列表中删除小说系列后的响应结果，如果没有数据则返回null
   */
  public static watchListNovelDelete(seriesId: string): Promise<rcp.Response | null> {
    return ApiUtil.post('/v1/watchlist/novel/delete', new rcp.Form({ 'series_id': seriesId }))
  }

}

export interface PostUserParam {
  /**
   * 可选参数a
   * */
  a?: number;
  /**
   * 可选参数b
   * */
  b?: string;
}

export interface BookmarksIllustsOffsetParam {
  /**
   * 用户ID
   * */
  userId: number;
  /**
   * 收藏公开范围
   * */
  restrict: string;
  /**
   * 标签（可选）
   * */
  tag?: string;
  /**
   * 偏移量（可选）
   * */
  offset?: number;
}

/**
 * 小说搜索参数
 * */
export interface SearchNovelParam {
  /**
   * 搜索关键词
   * */
  word: string;
  /**
   * 排序方式，可选
   * */
  sort?: string;
  /**
   * 搜索目标，可选
   * */
  searchTarget?: string;
  /**
   * 开始日期，可选
   * */
  startDate?: string;
  /**
   * 结束日期，可选
   * */
  endDate?: string;
  /**
   * 书签数量，可选
   * */
  bookmarkNum?: number;
}

/**
 * 插图搜索参数
 * */
export interface SearchIllustParam {
  /**
   * 搜索关键词
   * */
  word: string;
  /**
   * 排序方式，可选
   * */
  sort?: string;
  /**
   * 搜索目标，可选
   * */
  searchTarget?: string;
  /**
   * 开始日期，可选
   * */
  startDate?: string;
  /**
   * 结束日期，可选
   * */
  endDate?: string;
  /**
   * 书签数量范围，可选
   * */
  bookmarkNum?: Array<number>;
  /**
   * AI搜索类型，可选
   * */
  searchAiType?: number;
}