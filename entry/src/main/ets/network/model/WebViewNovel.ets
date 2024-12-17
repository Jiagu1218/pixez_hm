/**
 * WebViewNovel接口定义了网络小说的结构
 */
export interface WebViewNovel{
  /**
   * 小说的唯一标识符
   */
  id: string
  /**
   * 小说标题
   */
  title: string
  /**
   * 小说系列的标识符
   */
  seriesId: string
  /**
   * 小说系列的标题
   */
  seriesTitle: string
  /**
   * 表示小说系列是否已被观看
   */
  seriesIsWatched: boolean
  /**
   * 作者的标识符
   */
  userId: string
  /**
   * 小说的封面图片URL
   */
  coverUrl: string
  /**
   * 小说的标签数组
   */
  tags: string[]
  /**
   * 小说的简介或摘要
   */
  caption: string
  /**
   * 小说的创建日期
   */
  cdate: string
  /**
   * 小说的评级信息
   */
  rating: Rating
  /**
   * 小说的正文文本
   */
  text: string
  /**
   * 可选字段，用于标记或注释
   */
  marker?: object
  /**
   * 小说的插图数组
   */
  illusts: NovelIllust[]
  /**
   * 小说的图片数组
   */
  images: NovelImage[]
  /**
   * 小说系列的导航信息，包括上下篇小说的信息
   */
  seriesNavigation: SeriesNavigation
  /**
   * 小说的词汇表项数组
   */
  glossaryItems: object[]
  /**
   * 可替换项的标识符数组
   */
  replaceableItemIds: number[]
  /**
   * AI类型，表示小说的内容类型或风格
   */
  aiType: number
  /**
   * 表示小说是否为原创
   */
  isOriginal: boolean
}

/**
 * Rating接口定义了小说的评级结构，包括喜欢、收藏和查看的数量
 */
interface Rating {
  /**
   * 喜欢数量
   * */
  like: number
  /**
   * 收藏数量
   * */
  bookmark: number
  /**
   * 查看数量
   * */
  view: number
}


/**
 * SeriesNavigation接口定义了小说系列的导航结构，包括下篇和上篇小说的信息
 */
interface SeriesNavigation {
  /**
   * 上篇小说信息
   * */
  nextNovel?: NextNovel
  /**
   * 下篇小说信息
   * */
  prevNovel?: PreNovel
}


/**
 * NextNovel接口定义了下篇小说的详细信息
 */
interface NextNovel {
  /**
   * 小说的唯一标识符
   */
  id: number
  /**
   * 表示小说是否可阅读
   */
  viewable: boolean
  /**
   * 小说的内容顺序，用于排列小说的阅读顺序
   */
  contentOrder: string
  /**
   * 小说的标题
   */
  title: string
  /**
   * 小说的封面图片URL
   */
  coverUrl: string
  /**
   * 可选字段，当小说不可阅读时的提示信息
   */
  viewableMessage?: string
}

/**
 * PreNovel接口定义了上篇小说的详细信息
 */
interface PreNovel {
  /**
   * 小说的唯一标识符
   */
  id: number
  /**
   * 表示小说是否可阅读
   */
  viewable: boolean
  /**
   * 小说的内容顺序，用于排列小说的阅读顺序
   */
  contentOrder: string
  /**
   * 小说的标题
   */
  title: string
  /**
   * 小说的封面图片URL
   */
  coverUrl: string
  /**
   * 可选字段，当小说不可阅读时的提示信息
   */
  viewableMessage?: string
}


/**
 * NovelIllust接口定义了小说插图的结构
 */
interface NovelIllust{
  images:NovelIllustImages
}

/**
 * NovelIllustImages接口定义了小说插图的图片URLs，包括不同尺寸的图片
 */
interface NovelIllustImages{
  /**
   * 小尺寸图片URL
   * */
  small?:string
  /**
   * 中尺寸图片URL
   * */
  medium?:string
  /**
   * 原始尺寸图片URL
   * */
  original?:string
}

/**
 * NovelImage接口定义了小说图片的结构
 */
interface NovelImage{
  /**
   * 小说图片的唯一标识符
   * */
  novelImageId?:string
  /**
   * 尚未明确其含义的字段，可能是特定代码或标识
   * */
  sl:string
  /**
   * 包含小说图片各种尺寸的URLs
   * */
  urls:NovelUrls
}


/**
 * NovelUrls接口定义了小说图片的URLs，包括不同尺寸和质量的图片
 */
interface NovelUrls {
  /**
   * 小尺寸图片URL
   * */
  the240Mw?:string
  /**
   * 中等尺寸图片URL
   * */
  the480Mw?:string
  /**
   * 大尺寸图片URL
   * */
  the1200X1200?:string
  /**
   * 微缩图片URL
   * */
  the128X128?:string
  /**
   * 原始尺寸图片URL
   * */
  original?:string
}

