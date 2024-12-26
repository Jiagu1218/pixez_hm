import { LinkedList } from "@kit.ArkTS";
import { rcp } from "@kit.RemoteCommunicationKit";
import { AppConfig } from "../AppConfig";
import { TokenInterceptor } from "../interceptor/TokenInterceptor";

export class SessionPoolNew{
  private static sessionPool: LinkedList<rcp.Session> = new LinkedList();
  private static waitingQueue: LinkedList<(session: rcp.Session) => void> = new LinkedList();
  private static readonly  maxSessions: number= 10;
  private static readonly coreSessions: number = 4
  private static activeSessions: number = 0;
  private static tokenInterceptor:TokenInterceptor;

  public static init() {
    SessionPoolNew.tokenInterceptor = new TokenInterceptor()
    for (let i = 0; i < SessionPoolNew.coreSessions; i++) {
      const session = SessionPoolNew.createSession();
      SessionPoolNew.sessionPool.add(session);
    }
  }

  public static async acquire(): Promise<rcp.Session> {
    return new Promise((resolve, reject) => {
      if (SessionPoolNew.sessionPool.length == 0 && SessionPoolNew.activeSessions < SessionPoolNew.maxSessions) {
        const session = SessionPoolNew.createSession()
        SessionPoolNew.activeSessions++;
        resolve(session)
      }else if (SessionPoolNew.sessionPool.length == 0) {
        SessionPoolNew.waitingQueue.add(resolve)
      }else {
        resolve(SessionPoolNew.sessionPool.removeFirst());
      }
    })
  }

  public static release(session: rcp.Session): void {
    if (SessionPoolNew.waitingQueue.length == 0) {
      if (SessionPoolNew.sessionPool.length < SessionPoolNew.coreSessions) {
        SessionPoolNew.sessionPool.add(session);
      } else {
        session.close();
        SessionPoolNew.activeSessions--;
      }
    } else {
      const nextRequest = SessionPoolNew.waitingQueue.removeFirst();
      nextRequest(session);
    }
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
      interceptors: [SessionPoolNew.tokenInterceptor],
      requestConfiguration: {
        processing: {
          validateResponse: (response): boolean => {
            if (response.statusCode == 200) {
              return true
            }
            return false
          }
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