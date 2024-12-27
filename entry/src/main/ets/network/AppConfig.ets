
export class AppConfig{

  /**
   * 应用版本号
   * */
  public static readonly APP_VERSION:string = '5.0.156'

  /**
   * 应用操作系统
   * */
  public static readonly APP_OS:string = 'Android'

  /**
   * 应用操作系统版本
   * */
  public static readonly APP_OS_VERSION:string = '9.0'

  /**
   * OAuth主机地址
   * */
  public static readonly HOST:string = 'oauth.secure.pixiv.net'

  /**
   * API基础URL
   * */
  public static readonly BASE_API_URL:string = 'https://app-api.pixiv.net'

  /**
   * 语言设置
   * */
  public static readonly ACCEPT_LANGUAGE:string = 'zh-CN'

  /**
   * 代理信息
   * */
  public static readonly USER_AGENT:string = `PixivAndroidApp/${AppConfig.APP_VERSION} (${AppConfig.APP_OS} ${AppConfig.APP_OS_VERSION}; Pixel 3)`

  /**
   * HASH盐值，用于加密或验证
   * */
  public static readonly HASH_SALT:string =
    '28c1fdd170a5204386cb1313c7077b34f83e4aaf4aa829ce78c231e05b0bae2c'

  /**
   * DOH
   * @link https://coding.gs/2024/06/09/available-doh/#%E5%9B%BD%E5%86%85
   * */
  public static readonly DOH:string = 'https://doh.dns.sb/dns-query'
}
