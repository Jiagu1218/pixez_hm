import { url } from "@kit.ArkTS";
import { image } from "@kit.ImageKit";
import { PixelCache } from "../cache/PixelMapCache";
import { zlib } from "@kit.BasicServicesKit";
import { fileIo } from "@kit.CoreFileKit";
import { SessionPoolNew } from "../pool/SessionPoolNew";
import { SessionManager } from "../pool/SessionManager";

/**
 * 下载工具
 * session最多可创建16个
 */
export class DownloadUtil {

  /**
   * 下载图片
   * @param {string} url 图片下载链接
   * @returns {Promise<PixelMap>} 返回PixelMap对象
   */
  public static async downloadImage(url:string): Promise<PixelMap> {
    let cache = PixelCache.getCache(url);
    if (cache) {
      return cache
    }

    const session = await SessionManager.fileSessionPool.acquire()
    try {
      // 发起GET请求下载图片
      const response = await session.get(url);
      // 创建PixelMap并调用回调函数
      const imageSource = image.createImageSource(response.body)
      const pixelMap = imageSource.createPixelMapSync()
      PixelCache.setCache(url, pixelMap)
      return pixelMap
    } finally {
      SessionManager.fileSessionPool.release(session)

    }
  }

  /**
   * 下载ugoira文件
   *
   * 本函数旨在从给定的源URL下载ugoira（动画插图）文件，并将其保存到临时目录中，然后解压缩到缓存目录
   * 它首先解析URL以获取文件名和目录路径，然后检查并创建必要的目录结构如果文件尚未存在，
   * 它将下载文件并将其解压缩到指定的缓存目录中
   *
   * @param {string} src ugoira文件的URL如果为空或无效，则函数将直接返回
   * @returns {Promise<boolean>} 如果下载和解压缩成功，则返回true，否则返回false
   */
  public static async downloadUgoiraFile(src:string):Promise<boolean>{
    // 检查src参数是否为空或无效
    if (!src || src.length === 0) {
      // callback?.(false)
      return false
    }
    // 获取下载会话
    const session = await SessionManager.fileSessionPool.acquire()
    try {
      // 解析URL以获取源信息
      const source = url.URL.parseURL(src)
      // 提取文件名
      const fileName = src.split('/').pop()
      // 提取文件目录名
      const fileDir = fileName?.split('.').shift()
      // 定义缓存目录
      const cacheDir = `${getContext().cacheDir}/ugoira/${fileDir}`
      if (fileIo.accessSync(cacheDir, fileIo.AccessModeType.EXIST)){
        return true
      }
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
      // 下载文件到本地
      return session.downloadToFile(source,{
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
        return zlib.decompressFile(filePath,cacheDir).then(()=>{
          console.log('decompressFile success')
          return true
        }).finally(()=>{
          // 关闭文件并删除临时文件
          fileIo.close(file.fd).finally(() => fileIo.unlink(filePath))
        })
      })
    }finally {
      SessionManager.fileSessionPool.release(session)
    }
  }

}
