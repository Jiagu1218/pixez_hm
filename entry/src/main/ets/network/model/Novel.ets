/**
 * 小说接口定义了小说的基本属性和结构
 * 它包括小说的元数据、用户信息、系列信息以及交互数据等
 * */
export interface Novel {
  /**
   * 小说的唯一标识符
   * */
  id: number
  /**
   * 小说的标题
   * */
  title: string
  /**
   * 小说的简介或摘要
   * */
  caption: string
  /**
   * 小说的限制级别，用于表示小说适合的年龄群体
   * */
  restrict: number
  /**
   * 扩展限制级别，可能用于更细致的分类
   * */
  x_restrict: number
  /**
   * 表示小说是否为原创作品
   * */
  is_original: boolean
  /**
   * 小说的图片URLs，包括不同尺寸的图片
   * */
  image_urls: ImageUrls
  /**
   * 小说的创建日期
   * */
  create_date: string
  /**
   * 小说关联的标签，可以有多个
   * */
  tags: Tag[]
  /**
   * 小说的页面数量
   * */
  page_count: number
  /**
   * 小说的文本长度
   * */
  text_length: number
  /**
   * 小说的作者信息
   * */
  user: User
  /**
   * 小说所属的系列信息，如果有的话
   * */
  series?: Series
  /**
   * 表示当前用户是否收藏了这篇小说
   * */
  is_bookmarked: boolean
  /**
   * 小说被收藏的总数
   * */
  total_bookmarks: number
  /**
   * 小说被查看的总次数
   * */
  total_view: number
  /**
   * 小说是否可见，可能用于表示小说的发布状态
   * */
  visible: boolean
  /**
   * 小说的评论总数
   * */
  total_comments: number
  /**
   * 表示小说是否被静音，可能用于减少通知或关注
   * */
  is_muted: boolean
  /**
   * 表示小说是否仅对mypixiv用户可见
   * */
  is_mypixiv_only: boolean
  /**
   * 表示小说是否具有扩展限制内容
   * */
  is_x_restricted: boolean
  /**
   * 小说的AI类型，可能用于分类或过滤
   * */
  novel_ai_type: number
}

/**
 * ImageUrls接口定义了图片的不同尺寸及其对应的URL
 * */
interface ImageUrls {
  /**
   * 中等尺寸的方形图片URL
   * */
  square_medium: string
  /**
   * 中等尺寸的图片URL
   * */
  medium: string
  /**
   * 大尺寸的图片URL
   * */
  large: string
}

/**
 * Tag接口定义了标签的基本属性，包括标签的名称和可选的翻译名称
 * */
export interface Tag {
  /**
   * 标签的名称
   * */
  name: string
  /**
   * 标签的翻译名称，可能不存在
   * */
  translated_name?: string
  /**
   * 表示标签是否由上传用户添加
   * */
  added_by_uploaded_user: boolean
}

/**
 * User接口定义了用户的基本属性，包括用户的标识符、姓名、账号和头像URL
 * */
interface User {
  /**
   * 用户的唯一标识符
   * */
  id: number
  /**
   * 用户的显示名称
   * */
  name: string
  /**
   * 用户的账号名称
   * */
  account: string
  /**
   * 用户的头像URLs，包括不同尺寸的头像
   * */
  profile_image_urls: ProfileImageUrls
  /**
   * 表示当前用户是否关注了这个用户
   * */
  is_followed: boolean
}

/**
 * ProfileImageUrls接口定义了用户头像的不同尺寸及其对应的URL
 * */
interface ProfileImageUrls {
  /**
   * 中等尺寸的头像URL
   * */
  medium: string
}

/**
 * Series接口定义了系列的基本属性，包括系列的标识符和标题
 * 这个接口允许系列信息在小说中是可选的
 * */
interface Series {
  /**
   * 系列的唯一标识符，可能不存在
   * */
  id: number
  /**
   * 系列的标题，可能不存在
   * */
  title: string
}
