import { ArkTSUtils, LinkedList } from "@kit.ArkTS";
import { rcp } from "@kit.RemoteCommunicationKit";

/**
 * SessionPoolConfig类用于配置SessionPool的参数
 */
export interface SessionPoolConfig {
  /**
   * 最大会话数，最大为16
   */
  maxSessions: number;
  /**
   * 核心会话数
   */
  coreSessions: number;
  /**
   * 锁前缀
   */
  lookPrefix: string;
  /**
   * 会话配置
   */
  sessionConfiguration?: rcp.SessionConfiguration;
}

/**
 * SessionPool类用于管理远程通信的会话池
 * 它使用链表来维护会话池和等待队列，并根据需要创建和分配会话
 */
export class SessionPool {
  /**
   * 锁，用于控制并发访问
   */
  private lock: ArkTSUtils.locks.AsyncLock
  /**
   * 会话池，用于存储可用的会话
   */
  private sessionPool: LinkedList<rcp.Session>;
  /**
   * 等待队列，用于存储等待会话的请求
   */
  private waitingQueue: LinkedList<(session: rcp.Session) => void>;
  /**
   * 最大会话数，限制会话池的最大大小
   */
  private maxSessions: number;
  /**
   * 核心会话数，保证始终可用的最小会话数
   */
  private coreSessions: number;
  /**
   * 当前活动的会话数
   */
  private activeSessions: number;
  /**
   * 会话配置
   */
  private sessionConfiguration: rcp.SessionConfiguration;

  constructor(config?: SessionPoolConfig) {
    this.sessionPool = new LinkedList();
    this.waitingQueue = new LinkedList();
    this.maxSessions = 16;
    this.coreSessions = 4;
    this.activeSessions = 0;
    this.lock = ArkTSUtils.locks.AsyncLock.request(`${config?.lookPrefix}_activeSessions_lock`)
    this.sessionConfiguration = config?.sessionConfiguration ?? {};
    this.init(config);
  }

  /**
   * 初始化会话池，创建核心会话数目的会话
   */
  private init(config?: SessionPoolConfig): void {
    if (config?.sessionConfiguration) {
      this.sessionConfiguration = config.sessionConfiguration;
    }
    if (config?.maxSessions) {
      this.maxSessions = Math.min(16, config.maxSessions);
    }
    if (config?.coreSessions) {
      this.coreSessions = Math.min(this.maxSessions, config.coreSessions)
    }
    for (let i = 0; i < this.coreSessions; i++) {
      const session = this.createSession();
      this.sessionPool.add(session);
    }
  }

  /**
   * 获取一个会话，如果会话池为空且活动会话未超过最大会话数，则创建一个新的会话
   * 如果会话池为空且活动会话已达到最大会话数，则加入等待队列
   * @param {number} timeout 获取会话的超时时间，默认为30000毫秒
   * @returns {Promise<rcp.Session>} 返回一个Promise，解析为一个会话
   */
  public async acquire(timeout: number = 30000): Promise<rcp.Session> {
    return new Promise((resolve, reject) => {
      let timer: number = -1;
      if (timeout > 0) {
        timer = setTimeout(() => {
          this.waitingQueue.remove(resolve);
          reject(new Error('获取请求超时'));
        }, timeout);
      }
      if (this.sessionPool.length == 0 && this.activeSessions < this.maxSessions) {

        try {
          const session = this.createSession();
          this.lock.lockAsync(()=>{
            this.activeSessions++;
          })
          resolve(session);
          timer > -1 && clearTimeout(timer);
        }catch (e){
          //超出session个数限制16个
          if (1007900994 == e?.['code']) {
            this.waitingQueue.add(resolve)
          }else {
            timer > -1 && clearTimeout(timer)
            reject(e)
          }
        }

      } else if (this.sessionPool.length == 0) {
        this.waitingQueue.add(resolve);
      } else {
        timer > -1 && clearTimeout(timer);
        resolve(this.sessionPool.removeFirst());
      }
    });
  }

  /**
   * 释放一个会话，如果等待队列为空且会话池未满，则将会话加入会话池
   * 如果等待队列为空且会话池已满，则关闭会话
   * 如果等待队列不为空，则从等待队列中取出一个请求并分配会话
   * @param {rcp.Session} session 要释放的会话
   */
  public async release(session: rcp.Session):Promise<void> {
    if (this.waitingQueue.length == 0) {
      if (this.sessionPool.length < this.coreSessions) {
        this.sessionPool.add(session);
      } else {
        session.close();
        await this.lock.lockAsync(()=>{
          this.activeSessions--;
        })
      }
    } else {
      const nextRequest = this.waitingQueue.removeFirst();
      nextRequest(session);
    }
  }

  /**
   * 创建一个新的Session
   * @returns {rcp.Session} 新的Session实例
   */
  private createSession(): rcp.Session {
    // 创建Session并配置基础地址、请求头、拦截器等
    return rcp.createSession(this.sessionConfiguration);
  }

  /**
   * 销毁会话池，关闭所有会话并清空等待队列
   */
  public destroy(){
    this.sessionPool.forEach((session)=>{
      session.close()
    })
    this.sessionPool.clear()
    this.waitingQueue.clear()
    this.activeSessions = 0
  }
}
