/**
 * CacheControlEnum 枚举定义了一系列用于 HTTP 缓存控制的指令
 * 这些指令用于指定响应内容的缓存方式和范围
 */
export enum CacheControlEnum {
  /**
   * 指定响应是可以被任何缓存存储的，包括代理服务器和用户浏览器
   * */
  public = 'public',
  
  /**
   * 指定响应是私有缓存，只允许在用户的浏览器中存储，不会在共享缓存（如代理服务器）中存储
   * */
  private = 'private',
  
  /**
   * 指示响应内容必须先经过用户代理验证后才能使用，避免直接从缓存中获取
   * */
  noCache = 'no-cache',
  
  /**
   * 禁止缓存，响应内容不会被存储，适用于敏感信息的处理
   * */
  noStore = 'no-store',
  
  /**
   * 指示缓存的响应必须在使用前与源服务器重新验证，以确保内容是最新的
   * */
  mustRevalidate = 'must-revalidate',
  
  /**
   * 允许代理服务器对响应进行重新验证，常用于跨域请求的缓存控制
   * */
  proxyRevalidate = 'proxy-revalidate',
  
  /**
   * 表明响应内容不会改变，可以在整个协议期间内缓存，无需再次验证
   * */
  immutable = 'immutable',
  
  /**
   * 禁止对响应内容进行任何形式的转换或修改，例如压缩或格式转换
   * */
  noTransform = 'no-transform',
  
  /**
   * 只在缓存中返回响应，如果请求的是非缓存数据，则请求失败
   * */
  onlyIfCached = 'only-if-cached',
  
  /**
   * 指定响应内容在缓存中的最大存活时间，超过这个时间后，缓存将被视为陈旧
   * */
  maxAge = 'max-age',
  
  /**
   * 与 max-age 类似，但仅适用于共享缓存（如代理服务器），对私有缓存无影响
   * */
  sMaxAge = 's-maxage',
  
  /**
   * 允许在重新验证过期内容的同时，返回缓存的过期响应，常用于提高性能
   * */
  staleWhileRevalidate = 'stale-while-revalidate',
}
