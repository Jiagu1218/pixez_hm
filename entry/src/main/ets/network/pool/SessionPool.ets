
import { rcp } from "@kit.RemoteCommunicationKit";
import { AppConfig } from "../AppConfig";
import { TokenInterceptor } from "../interceptor/TokenInterceptor";

export class SessionPool{
  // 最大并发连接数
  private static readonly maxConnections: number = 16;
  // 核心连接数
  private static readonly coreSize: number = 4;
  // 当前使用的连接数
  private static inUseConnections: number = 0;
  // 会话池
  private static sessionPool: Array<rcp.Session> = [];

  public static init(): void {
    // 预先创建一定数量的session放入池中
    for (let i = 0; i < SessionPool.coreSize; i++) {
      SessionPool.sessionPool.push(SessionPool.createSession());
    }
  }

  public static getSession(): rcp.Session | null {
    if (SessionPool.sessionPool.length > 0) {
      return SessionPool.sessionPool.shift()!;
    } else if (SessionPool.inUseConnections < SessionPool.maxConnections) {
      SessionPool.inUseConnections++;
      return SessionPool.createSession();
    } else {
      // 达到最大限制则返回null
      return null;
    }
  }

  public static releaseSession(session: rcp.Session|null): void {
    if (!session) {
      return;
    }
    if (SessionPool.sessionPool.length < SessionPool.coreSize) {
      SessionPool.sessionPool.push(session);
    } else {
      session.close();
      SessionPool.inUseConnections--;
    }
  }

  public static destroy(): void {
    SessionPool.sessionPool.forEach(session => {
      session.cancel();
      session.close();
    });
    SessionPool.sessionPool = [];
    SessionPool.inUseConnections = 0;
  }

  /**
   * 创建一个新的Session
   * @returns {rcp.Session} 新的Session实例
   */
  private static createSession(): rcp.Session {
    // 创建Session并配置基础地址、请求头、拦截器等
    return rcp.createSession({
      baseAddress: AppConfig.BASE_API_URL,
      headers: {
        'User-Agent': AppConfig.USER_AGENT,
        "Accept-language": AppConfig.ACCEPT_LANGUAGE,
        'App-OS': AppConfig.APP_OS,
        'App-OS-Version': AppConfig.APP_OS_VERSION,
        'App-Version': AppConfig.APP_VERSION,
        'Host': AppConfig.HOST,
        "Content-type": 'application/x-www-form-urlencoded;charset=UTF-8',
        'Referer': AppConfig.BASE_API_URL,
      },
      interceptors: [new TokenInterceptor()],
      requestConfiguration: {
        processing: {
          validateResponse: (response): boolean => response.statusCode === 200
        },
        dns: {
          dnsOverHttps: {
            url: AppConfig.DOH
          }
        },
        security: {
          remoteValidation: (context) => {
            console.info('context', context);
            return true;
          }
        }
      }
    });
  }

}