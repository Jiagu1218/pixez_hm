import { LinkedList } from "@kit.ArkTS";
import { rcp } from "@kit.RemoteCommunicationKit";
import { AppConfig } from "../AppConfig";
import { TokenInterceptor } from "../interceptor/TokenInterceptor";

/**
 * SessionPoolNew类用于管理远程通信的会话池
 * 它使用链表来维护会话池和等待队列，并根据需要创建和分配会话
 */
export class SessionPoolNew{
  // 会话池，用于存储可用的会话
  private static sessionPool: LinkedList<rcp.Session> = new LinkedList();
  // 等待队列，用于存储等待会话的请求
  private static waitingQueue: LinkedList<(session: rcp.Session) => void> = new LinkedList();
  // 最大会话数，限制会话池的最大大小
  private static readonly  maxSessions: number= 10
  // 核心会话数，保证始终可用的最小会话数
  private static readonly coreSessions: number = 4
  // 当前活动的会话数
  private static activeSessions: number = 0
  // Token拦截器，用于在请求中自动添加Token
  private static tokenInterceptor:TokenInterceptor

  /**
   * 初始化会话池，创建核心会话数目的会话
   */
  public static init() {
    SessionPoolNew.tokenInterceptor = new TokenInterceptor()
    for (let i = 0; i < SessionPoolNew.coreSessions; i++) {
      const session = SessionPoolNew.createSession();
      SessionPoolNew.sessionPool.add(session);
    }
  }

  /**
   * 获取一个会话，如果会话池为空且活动会话未超过最大会话数，则创建一个新的会话
   * 如果会话池为空且活动会话已达到最大会话数，则加入等待队列
   * @param {number} timeout 获取会话的超时时间，默认为30000毫秒
   * @returns {Promise<rcp.Session>} 返回一个Promise，解析为一个会话
   */
  public static async acquire(timeout: number = 30000): Promise<rcp.Session> {
    return new Promise((resolve, reject) => {
      let timer: number = -1;
      if (timeout > 0) {
        timer = setTimeout(() => {
          SessionPoolNew.waitingQueue.remove(resolve);
          reject(new Error('获取请求超时'));
        }, timeout);
      }
      if (SessionPoolNew.sessionPool.length == 0 && SessionPoolNew.activeSessions < SessionPoolNew.maxSessions) {
        const session = SessionPoolNew.createSession()
        timer>-1 && clearTimeout(timer)
        SessionPoolNew.activeSessions++;
        resolve(session)
      }else if (SessionPoolNew.sessionPool.length == 0) {
        SessionPoolNew.waitingQueue.add(resolve)
      }else {
        timer>-1 && clearTimeout(timer)
        resolve(SessionPoolNew.sessionPool.removeFirst());
      }
    })
  }

  /**
   * 释放一个会话，如果等待队列为空且会话池未满，则将会话加入会话池
   * 如果等待队列为空且会话池已满，则关闭会话
   * 如果等待队列不为空，则从等待队列中取出一个请求并分配会话
   * @param {rcp.Session} session 要释放的会话
   */
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
