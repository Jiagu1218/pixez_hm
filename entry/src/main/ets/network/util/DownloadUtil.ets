import { rcp } from "@kit.RemoteCommunicationKit";
import { AppConfig } from "../AppConfig";
import { TokenInterceptor } from "../interceptor/TokenInterceptor";
import { Queue, url } from "@kit.ArkTS";
import { image } from "@kit.ImageKit";
import { PixelCache } from "../cache/PixelMapCache";
import { BusinessError, zlib } from "@kit.BasicServicesKit";
import { fileIo } from "@kit.CoreFileKit";

/**
 * 定义下载任务接口
 */
export interface ImageTask {
  url: string; // 图片URL
  callback: (pic: image.PixelMap) => void; // 下载完成后的回调函数
}

/**
 * 下载工具
 * session最多可创建16个
 */
export class DownloadUtil {
  // 最大并发连接数
  private static readonly maxConnections: number = 10;
  // 会话池大小
  private static readonly poolSize: number = 2;
  // 当前使用的连接数
  private static inUseConnections: number = 0;
  // 会话池
  private static sessionPool: Array<rcp.Session> = [];
  // 等待队列
  private static waitQueue: Queue<ImageTask> = new Queue();

  /**
   * 初始化请求
   */
  public static init(): void {
    // 预先创建一定数量的session放入池中
    for (let i = 0; i < DownloadUtil.poolSize; i++) {
      DownloadUtil.sessionPool.push(DownloadUtil.createSession());
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

  /**
   * 获取一个Session实例
   * @returns {rcp.Session | null} Session实例或null
   */
  private static getSession(): rcp.Session | null {
    // 优先从会话池中获取Session
    if (DownloadUtil.sessionPool.length > 0) {
      return DownloadUtil.sessionPool.shift()!;
    // 如果当前使用的连接数未达到最大限制，则创建新的Session
    } else if (DownloadUtil.inUseConnections < DownloadUtil.maxConnections) {
      DownloadUtil.inUseConnections++;
      return DownloadUtil.createSession();
    } else {
      // 达到最大限制则返回null
      return null;
    }
  }

  /**
   * 销毁所有Session实例
   */
  public static destroy(): void {
    // 遍历会话池，取消并关闭所有Session
    DownloadUtil.sessionPool.forEach(session => {
      session.cancel();
      session.close();
    });
    PixelCache.clear();
    DownloadUtil.sessionPool = [];
    DownloadUtil.inUseConnections = 0;
  }

  /**
   * 下载图片
   * @param {ImageTask} task 图片下载任务
   */
  public static async downloadImage(task: ImageTask): Promise<void> {
    let cache = PixelCache.getCache(task.url);
    if (cache) {
      task.callback?.(cache)
      return
    }

    const session = DownloadUtil.getSession();
    if (session) {
      try {
        // 发起GET请求下载图片
        const response = await session.get(task.url);
        // 创建PixelMap并调用回调函数
        const imageSource = image.createImageSource(response.body)
        const pixelMap = imageSource.createPixelMapSync()
        PixelCache.setCache(task.url, pixelMap)
        task.callback?.(pixelMap);
      } catch (e) {
        console.error(`err: err code is ${e.code}, err message is ${JSON.stringify(e)}`);
      } finally {
        // 释放Session并处理下一个任务
        DownloadUtil.releaseSession(session);
        DownloadUtil.processNextTask();
      }
    } else {
      // 如果没有获取到Session，将任务加入等待队列
      DownloadUtil.waitQueue.add(task);
    }
  }

  /**
   * 下载ugoira文件
   *
   * 本函数旨在从给定的源URL下载ugoira（动画插图）文件，并将其保存到临时目录中，然后解压缩到缓存目录
   * 它首先解析URL以获取文件名和目录路径，然后检查并创建必要的目录结构如果文件尚未存在，
   * 它将下载文件并将其解压缩到指定的缓存目录中
   *
   * @param src ugoira文件的URL如果为空或无效，则函数将直接返回
   * @param callback 下载完成后的回调函数，默认为空
   */
  public static downloadUgoiraFile(src:string,callback?:()=>void){
    // 检查src参数是否为空或无效
    if (!src || src.length === 0) {
      return
    }
    try {
      // 解析URL以获取源信息
      const source = url.URL.parseURL(src)
      // 提取文件名
      const fileName = src.split('/').pop()
      // 提取文件目录名
      const fileDir = fileName?.split('.').shift()
      // 定义临时文件目录
      const tempDir = `${getContext().tempDir}/ugoira`
      // 检查并创建临时目录
      if (!fileIo.accessSync(tempDir, fileIo.AccessModeType.EXIST)) {
        fileIo.mkdirSync(tempDir,true)
      }
      // 定义文件路径
      const filePath = `${tempDir}/${fileName}`
      // 打开或创建文件
      const file = fileIo.openSync(filePath,fileIo.OpenMode.CREATE|fileIo.OpenMode.READ_WRITE)
      // 获取下载会话
      const session = DownloadUtil.getSession()
      // 定义缓存目录
      const cacheDir = `${getContext().cacheDir}/ugoira/${fileDir}`
      // 下载文件到本地
      session?.downloadToFile(source,{
        kind:'file',
        file:file.fd,
        keepLocal:true
      }).then(response=>{
        console.log('response',response)
        // 检查并创建缓存目录
        if (!fileIo.accessSync(cacheDir, fileIo.AccessModeType.EXIST)) {
          fileIo.mkdirSync(cacheDir,true)
        }
        // 解压缩文件到缓存目录
        zlib.decompressFile(filePath,cacheDir).then(()=>{
          callback?.()
          console.log('decompressFile success')
        }).catch((e:BusinessError)=>{
          console.log('err',e)
        }).finally(()=>{
          // 关闭文件并删除临时文件
          fileIo.close(file.fd).finally(() => fileIo.unlink(filePath))
        })
      }).catch((e:BusinessError)=>{
        console.log('err',e)
      })
    } catch (e) {
      console.log('err',e)
    }
  }

  /**
   * 释放Session
   * @param {rcp.Session} session 要释放的Session实例
   */
  private static releaseSession(session: rcp.Session): void {
    // 如果会话池未满，则将Session放回池中
    if (DownloadUtil.sessionPool.length < DownloadUtil.poolSize) {
      DownloadUtil.sessionPool.push(session);
    } else {
      // 否则关闭Session并减少当前使用的连接数
      session.close();
      DownloadUtil.inUseConnections--;
    }
  }

  /**
   * 处理下一个等待中的任务
   */
  private static processNextTask(): void {
    // 从等待队列中获取下一个任务并下载图片
    const nextTask = DownloadUtil.waitQueue.pop();
    if (nextTask) {
      DownloadUtil.downloadImage(nextTask);
    }
  }
}
