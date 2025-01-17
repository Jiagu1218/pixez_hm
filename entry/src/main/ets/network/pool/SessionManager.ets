import { AppConfig } from "../AppConfig";
import { TokenInterceptor } from "../interceptor/TokenInterceptor";
import { SessionPool, SessionPoolConfig } from "./SessionPool";

export class SessionManager {
  private static _commonSessionPool: SessionPool;

  public static get commonSessionPool(): SessionPool {
    return SessionManager._commonSessionPool;
  }

  private static _fileSessionPool: SessionPool;

  public static get fileSessionPool(): SessionPool {
    return SessionManager._fileSessionPool;
  }
  private static tokenInterceptor: TokenInterceptor



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
        }
      }
    }
    SessionManager._commonSessionPool =  new SessionPool(commonSessionConfig)
    SessionManager._fileSessionPool = new SessionPool(fileSessionConfig)
  }

  public static destroy(){
    SessionManager._commonSessionPool.destroy()
    SessionManager._fileSessionPool.destroy()
  }
}