import { rcp } from "@kit.RemoteCommunicationKit";

/**
 * ResponseCache类用于缓存和管理HTTP响应
 * 它允许在请求相同URL时重用之前的响应，从而减少网络请求次数，提高性能
 */
export class ResponseCache {
  /**
   * cache属性用于存储URL到Response的映射
   * */
  private readonly cache: Map<string, rcp.Response> = new Map();

  /**
   * 根据URL获取缓存的响应
   * @param url 请求的URL
   * @returns 返回缓存的Response对象，如果没有找到则返回undefined
   */
  getCache(url: string): rcp.Response|undefined {
    return this.cache.get(url)
  }

  /**
   * 在缓存中设置或更新指定URL的响应
   * @param url 请求的URL
   * @param response 响应对象
   */
  setCache(url: string, response: rcp.Response): void {
    // 仅当url和response都有效时，才将response缓存起来
    if (url&&response) {
      this.cache.set(url, response)
    }
  }

  /**
   * 从缓存中删除指定URL的响应
   * @param url 请求的URL
   */
  delCache(url: string): void {
    // 从缓存中移除指定的URL对应的响应
    if (this.cache.has(url)) {
      this.cache.delete(url)
    }
  }

  /**
   * 清空缓存中的所有响应
   */
  clear(): void {
    // 重置cache属性为一个新的空对象，以清空所有缓存的响应
    this.cache.clear()
  }
}
