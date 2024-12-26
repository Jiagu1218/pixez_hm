import { rcp } from '@kit.RemoteCommunicationKit'
import { ApiUtil } from '../util/ApiUtil'
import { AppConfig } from '../AppConfig'
import { DateTimeUtil } from '../util/DateTimeUtil'
import { OauthClient } from '../OauthClient'
import { TokenResponse } from '../response/TokenResponse'
import { AccountManager } from '../../util/AccountManager'


/**
 * token拦截器
 * 用于拦截请求并处理token相关逻辑，如刷新token、添加token到请求头等
 */
export class TokenInterceptor implements rcp.Interceptor {
  private loginPageName: string = 'loginPage'
  /**
   * 拦截请求的执行方法
   * @param context 请求上下文，包含请求和响应信息
   * @param next 请求处理器，用于执行下一个拦截器或最终的请求
   * @returns 返回处理后的响应
   */
  async intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    // 执行请求并获得响应
    const response = await this.request(context, next)
    // 如果请求头中包含refreshed-token或请求路径包含/auth/token，则直接返回响应
    if (context.request.headers?.['refreshed-token'] || context.request.url.pathname.match('/auth/token')) {
      return response
    }
    // 检查响应状态码，如果是400或401，表示可能需要刷新token
    if (response.statusCode == 400 || response.statusCode == 401) {
      const error = response.toString()
      if (!error?.indexOf('OAuth')) {
        return response
      }
      //TODO 删除token
      // 尝试刷新token
      const res = await OauthClient.postRefreshAutoToken('zjvmJr5Ip4oVxuwFPOSQNDjV8wCp0O2lzeDrLHN9rX0', '')
      if (context.request.headers){
        context.request.headers['refreshed-token'] = 'true'
      }else {
        context.request.headers = {'refreshed-token' : 'true'}
      }
      if (res && res.statusCode == 200) {
        // 如果刷新成功，保存新的token信息，并重新执行请求
        let result = res.toJSON() as TokenResponse
        AccountManager.getInstance()
          .saveAccount(result.user.account, result.refresh_token, ApiUtil.noNullRecord(result.user))
        AppStorage.setOrCreate<string>('token', result.access_token)
        return this.request(context, next)
      }
    }
    // 如果不需要刷新token，直接返回响应
    return response
  }

  /**
   * 处理请求的详细方法
   * @param context 请求上下文，包含请求和响应信息
   * @param next 请求处理器，用于执行下一个拦截器或最终的请求
   * @returns 返回处理后的响应
   */
  request(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    // 设置请求头，包括Host、authorization、X-Client-Time和X-Client-Hash
    if (context.request.headers) {
      const host = context.request.url.host
      context.request.headers['Host'] = host
      let token = AppStorage.get<string>('token')
      if (token && !context.request.headers['authorization']) {
        context.request.headers['authorization'] = 'Bearer ' + token
      }
      const time = DateTimeUtil.getIsoTime()
      context.request.headers['X-Client-Time'] = time
      context.request.headers['X-Client-Hash'] = ApiUtil.getHash(time + AppConfig.HASH_SALT)
    }
    // 执行下一个拦截器或最终的请求
    return next.handle(context)
  }
}
