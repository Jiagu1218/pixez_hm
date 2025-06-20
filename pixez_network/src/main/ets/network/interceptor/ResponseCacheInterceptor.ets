import rcp from '@hms.collaboration.rcp';
import { ResponseCache } from '../cache/ResponseCache';
import { CacheControlEnum } from '../enums/CacheControlEnum';

/**
 * 请求缓存拦截器
 * 该类的主要作用是根据请求的缓存控制指令(cache-control)来决定是否使用缓存的响应，
 * 或者根据请求更新缓存。它通过拦截请求处理流程，实现对响应缓存的管理。
 */
export class ResponseCacheInterceptor implements rcp.Interceptor{
  /**
   * 缓存管理器，用于操作缓存数据
   * */
  private readonly cache:ResponseCache

  /**
   * 构造函数
   * @param cache - ResponseCache实例，用于缓存管理
   */
  constructor(cache:ResponseCache){
    this.cache = cache
  }

  /**
   * 拦截请求的处理方法
   * 该方法首先检查请求的缓存控制指令，决定是否从缓存中获取数据或更新缓存。
   * 如果缓存可用且未被禁用，则直接返回缓存的响应。否则，继续执行请求，并根据响应更新缓存。
   *
   * @param context - 请求上下文，包含请求的所有信息
   * @param next - 请求处理器，用于执行下一个请求处理步骤
   * @returns 返回一个Promise，解析为响应对象
   */
  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    // 检查请求是否为GET方法，如果不是，则直接执行下一个请求处理步骤
    if(context.request.method !== 'GET'){
      return next.handle(context)
    }
    // 获取请求的URL，用于缓存的索引
    const url = context.request.url.href
    // 获取缓存控制指令，用于决定缓存的使用和更新策略
    const cacheControl = context.request.headers?.['cache-control']
    // 尝试从缓存中获取响应
    const responseFromCache = this.cache.getCache(url)

    // 如果缓存未被禁用且存在缓存的响应，则直接返回缓存的响应
    if (!cacheControl?.includes(CacheControlEnum.noCache) && responseFromCache) {
      return Promise.resolve(responseFromCache)
    }

    // 如果缓存控制指令禁止使用缓存，则删除已有的缓存
    if (cacheControl?.includes(CacheControlEnum.noCache)) {
      this.cache.delCache(url)
    }

    // 继续执行请求
    const promise = next.handle(context)
    // 请求成功后，根据缓存控制指令更新缓存
    promise.then((resp) => {
      if (resp.statusCode == 200) {
        // 如果缓存控制指令允许存储缓存，则更新缓存
        if (cacheControl?.includes(CacheControlEnum.private)) {
          this.cache.setCache(url, resp)
        }
      }
    });

    // 返回请求的Promise
    return promise;
  }
}
