/**
 * 用户详情响应接口
 * 包含用户详细信息、个人资料、个人资料公开设置和工作空间信息
 */
export interface UserDetailResponse{
  /**
   * 用户信息
   * */
  user: User
  /**
   * 个人资料信息
   * */
  profile: Profile
  /**
   * 个人资料公开设置
   * */
  profile_publicity: ProfilePublicity
  /**
   * 工作空间信息
   * */
  workspace: Workspace
}

/**
 * 用户信息接口
 * 包含用户的基本信息，如ID、用户名、账户等
 */
interface User {
  /**
   * 用户ID
   * */
  id: number
  /**
   * 用户名
   * */
  name: string
  /**
   * 用户账户
   * */
  account: string
  /**
   * 用户个人资料图片URL
   * */
  profile_image_urls: ProfileImageUrls
  /**
   * 用户评论
   * */
  comment: string
  /**
   * 是否被当前用户关注
   * */
  is_followed: boolean
  /**
   * 是否是访问限制用户
   * */
  is_access_blocking_user: boolean
}

/**
 * 个人资料图片URL接口
 * 提供中等尺寸的个人资料图片URL
 */
interface ProfileImageUrls {
  /**
   * 中等尺寸个人资料图片URL
   * */
  medium: string
}

/**
 * 个人资料接口
 * 包含用户的详细个人资料信息，如网页、性别、出生日期等
 */
interface Profile {
  /**
   * 个人主页网址，可选
   * */
  webpage?: string
  /**
   * 性别
   * */
  gender: string
  /**
   * 出生日期
   * */
  birth: string
  /**
   * 出生日
   * */
  birth_day: string
  /**
   * 出生年份
   * */
  birth_year: number
  /**
   * 地区
   * */
  region: string
  /**
   * 地址ID
   * */
  address_id: number
  /**
   * 国家代码
   * */
  country_code: string
  /**
   * 职业
   * */
  job: string
  /**
   * 职业ID
   * */
  job_id: number
  /**
   * 关注用户总数
   * */
  total_follow_users: number
  /**
   * 我的Pixiv用户总数
   * */
  total_mypixiv_users: number
  /**
   * 插画总数
   * */
  total_illusts: number
  /**
   * 漫画总数
   * */
  total_manga: number
  /**
   * 小说总数
   * */
  total_novels: number
  /**
   * 公开的插画书签总数
   * */
  total_illust_bookmarks_public: number
  /**
   * 插画系列总数
   * */
  total_illust_series: number
  /**
   * 小说系列总数
   * */
  total_novel_series: number
  /**
   * 背景图片URL
   * */
  background_image_url: string
  /**
   * Twitter账户
   * */
  twitter_account: string
  /**
   * Twitter网址，可选
   * */
  twitter_url?: string
  /**
   * Pawoo网址，可选
   * */
  pawoo_url?: string
  /**
   * 是否是高级会员
   * */
  is_premium: boolean
  /**
   * 是否使用自定义个人资料图片
   * */
  is_using_custom_profile_image: boolean
}

/**
 * 个人资料公开设置接口
 * 定义了用户希望公开的个人资料信息程度，如性别、地区、生日等
 */
interface ProfilePublicity {
  /**
   * 性别公开设置
   * */
  gender: string
  /**
   * 地区公开设置
   * */
  region: string
  /**
   * 生日公开设置
   * */
  birth_day: string
  /**
   * 出生年份公开设置
   * */
  birth_year: string
  /**
   * 职业公开设置
   * */
  job: string
  /**
   * Pawoo信息公开设置
   * */
  pawoo: boolean
}

/**
 * 工作空间接口
 * 描述了用户的工作环境和设备，如电脑、显示器、工具等
 */
interface Workspace {
  /**
   * 电脑设备信息
   * */
  pc: string
  /**
   * 显示器信息
   * */
  monitor: string
  /**
   * 工作工具信息
   * */
  tool: string
  /**
   * 扫描仪信息
   * */
  scanner: string
  /**
   * 平板电脑信息
   * */
  tablet: string
  /**
   * 鼠标信息
   * */
  mouse: string
  /**
   * 打印机信息
   * */
  printer: string
  /**
   * 桌面环境信息
   * */
  desktop: string
  /**
   * 音乐信息
   * */
  music: string
  /**
   * 办公桌信息
   * */
  desk: string
  /**
   * 椅子信息
   * */
  chair: string
  /**
   * 工作空间评论
   * */
  comment: string
  /**
   * 工作空间图片URL，可选
   * */
  workspace_image_url?: string
}
