import { LinkedList } from "@kit.ArkTS";
import { rcp } from "@kit.RemoteCommunicationKit";

export interface SessionPoolConfig {
  maxSessions: number;
  coreSessions: number;
  sessionConfiguration?: rcp.SessionConfiguration
}
/**
 * SessionPool类用于管理远程通信的会话池
 * 它使用链表来维护会话池和等待队列，并根据需要创建和分配会话
 */
export class SessionPool{
  // 会话池，用于存储可用的会话
  private static sessionPool: LinkedList<rcp.Session> = new LinkedList();
  // 等待队列，用于存储等待会话的请求
  private static waitingQueue: LinkedList<(session: rcp.Session) => void> = new LinkedList();
  // 最大会话数，限制会话池的最大大小
  private static maxSessions: number = 16
  // 核心会话数，保证始终可用的最小会话数
  private static coreSessions: number = 4
  // 当前活动的会话数
  private static activeSessions: number = 0
  private static sessionConfiguration:rcp.SessionConfiguration

  /**
   * 初始化会话池，创建核心会话数目的会话
   */
  public static init(config?:SessionPoolConfig) {
    if (config?.sessionConfiguration) {
      SessionPool.sessionConfiguration = config.sessionConfiguration
    }
    if (config?.maxSessions) {
      SessionPool.maxSessions = config.maxSessions > 16 ? SessionPool.maxSessions:config.maxSessions
    }
    if (config?.coreSessions) {
      SessionPool.coreSessions = config.coreSessions
    }
    for (let i = 0; i < SessionPool.coreSessions; i++) {
      const session = SessionPool.createSession();
      SessionPool.sessionPool.add(session);
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
          SessionPool.waitingQueue.remove(resolve);
          reject(new Error('获取请求超时'));
        }, timeout);
      }
      if (SessionPool.sessionPool.length == 0 && SessionPool.activeSessions < SessionPool.maxSessions) {
        const session = SessionPool.createSession()
        timer>-1 && clearTimeout(timer)
        SessionPool.activeSessions++;
        resolve(session)
      }else if (SessionPool.sessionPool.length == 0) {
        SessionPool.waitingQueue.add(resolve)
      }else {
        timer>-1 && clearTimeout(timer)
        resolve(SessionPool.sessionPool.removeFirst());
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
    if (SessionPool.waitingQueue.length == 0) {
      if (SessionPool.sessionPool.length < SessionPool.coreSessions) {
        SessionPool.sessionPool.add(session);
      } else {
        session.close();
        SessionPool.activeSessions--;
      }
    } else {
      const nextRequest = SessionPool.waitingQueue.removeFirst();
      nextRequest(session);
    }
  }

  /**
   * 创建一个新的Session
   * @returns {rcp.Session} 新的Session实例
   */
  private static createSession(): rcp.Session {
    // 创建Session并配置基础地址、请求头、拦截器等
    return rcp.createSession(SessionPool.sessionConfiguration);
  }
}
