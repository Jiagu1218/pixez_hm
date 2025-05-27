import { AppConfig } from "../AppConfig";
import { TokenInterceptor } from "../interceptor/TokenInterceptor";
import { SessionPool, SessionPoolConfig } from "./SessionPool";

/**
 * 会话管理器
 */
export class SessionManager {
  /**
   * 公共会话池
   */
  private static _commonSessionPool: SessionPool;
  /**
   * 公共会话池
   */
  public static get commonSessionPool(): SessionPool {
    return SessionManager._commonSessionPool;
  }
  /**
   * 文件会话池
   */
  private static _fileSessionPool: SessionPool;
  /**
   * 文件会话池
   */
  public static get fileSessionPool(): SessionPool {
    return SessionManager._fileSessionPool;
  }
  /**
   * token拦截器
   */
  private static tokenInterceptor: TokenInterceptor

  /**
   * 初始化
   */
  public static init(){
    SessionManager.tokenInterceptor = new TokenInterceptor()
    const commonSessionConfig:SessionPoolConfig ={
      maxSessions: 6,
      coreSessions: 4,
      lookPrefix: 'commonSession',
      sessionConfiguration:{
        baseAddress: AppConfig.BASE_API_URL,
        headers: {
          'User-Agent': AppConfig.USER_AGENT,
          "Accept-language": AppConfig.ACCEPT_LANGUAGE,
          'App-OS': AppConfig.APP_OS,
          'App-OS-Version': AppConfig.APP_OS_VERSION,
          'App-Version': AppConfig.APP_VERSION,
          "Content-type": 'application/x-www-form-urlencoded;charset=UTF-8',
          'Referer': AppConfig.BASE_API_URL,
        },
        interceptors: [SessionManager.tokenInterceptor],
        requestConfiguration: {
          processing: {
            validateResponse: (response): boolean => {
              if (response.statusCode == 200) {
                return true
              }
              console.error(`请求失败，状态码为：${response.statusCode}`, response.toJSON())
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
              return true;
            }
          }
        },
        connectionConfiguration:{
          maxConnectionsPerHost:256,
          maxTotalConnections:1024
        }
      }
    }

    const fileSessionConfig:SessionPoolConfig ={
      maxSessions: 10,
      coreSessions: 6,
      lookPrefix: 'fileSession',
      sessionConfiguration:{
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
        interceptors: [SessionManager.tokenInterceptor],
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
              return true;
            }
          }
        },
        connectionConfiguration:{
          maxConnectionsPerHost:256,
          maxTotalConnections:1024
        }
      }
    }
    SessionManager._commonSessionPool =  new SessionPool(commonSessionConfig)
    SessionManager._fileSessionPool = new SessionPool(fileSessionConfig)
  }
  /**
   * 销毁
   */
  public static destroy(){
    SessionManager._commonSessionPool.destroy()
    SessionManager._fileSessionPool.destroy()
  }
}