import { rcp } from '@kit.RemoteCommunicationKit'
import { ApiUtil } from '../util/ApiUtil'
import { AppConfig } from '../AppConfig'
import { DateTimeUtil } from '../util/DateTimeUtil'

/**
 * token拦截器
 * */
export class TokenInterceptor implements rcp.Interceptor{
  intercept(context: rcp.RequestContext, next: rcp.RequestHandler): Promise<rcp.Response> {
    if (context.request.headers) {
      const host = context.request.url.host
      context.request.headers['Host'] = host
      let token = AppStorage.get<string>('token')
      if (token && !context.request.headers['authorization']) {
        context.request.headers['authorization'] = 'Bearer '+ token
      }
      const time = DateTimeUtil.getIsoTime()
      context.request.headers['X-Client-Time'] = time
      context.request.headers['X-Client-Hash'] = ApiUtil.getHash(time + AppConfig.HASH_SALT)
    }
    return next.handle(context)
  }

}