import { taskpool, url } from "@kit.ArkTS";
import { image } from "@kit.ImageKit";
import { PixelCache } from "../cache/PixelMapCache";
import { zlib } from "@kit.BasicServicesKit";
import { fileIo } from "@kit.CoreFileKit";
import { SessionPoolNew } from "../pool/SessionPoolNew";
import { SessionManager } from "../pool/SessionManager";
import { rcp } from "@kit.RemoteCommunicationKit";

/**
 * 下载工具
 * session最多可创建16个
 */
export class DownloadUtil {

  /**
   * 下载图片
   * @param {string} src 图片下载链接
   * @returns {Promise<PixelMap>} 返回PixelMap对象
   */
  public static async downloadImage(src:string,localCache?:LocalCacheInfo): Promise<PixelMap> {
    let cache = PixelCache.getCache(src);
    if (cache) {
      return cache
    }
    if(localCache){
      // 提取文件名
      const fileName = localCache.filename || src.split('/').pop()
      // 提取文件目录名
      const fileDir = localCache.dir
      // 定义缓存目录
      let cacheBaseDir:string;
      switch (localCache.cacheType){
        case 'temp':
          cacheBaseDir = getContext().tempDir
          break
        case 'cache':
          cacheBaseDir = getContext().cacheDir
          break
        case 'file':
          cacheBaseDir = getContext().filesDir
          break
        default:
          cacheBaseDir = getContext().cacheDir
      }
      //判断文件是否存在
      // 创建文件
      const filePath = cacheBaseDir + '/' + fileDir + '/' + fileName
      if (fileIo.accessSync(filePath, fileIo.AccessModeType.EXIST)) {
        // 创建PixelMap并调用回调函数
        const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE)
        const buffer = new ArrayBuffer(4096)
        fileIo.readSync(file.fd,buffer)
        fileIo.close(file.fd)
        const imageSource = image.createImageSource(buffer)
        const pixelMap = imageSource.createPixelMapSync()
        PixelCache.setCache(src, pixelMap)
        return pixelMap
      }
    }

    const session = await SessionManager.fileSessionPool.acquire()
    try {
      // 发起GET请求下载图片
      const response = await session.get(src);
      if (localCache) {
        //异步保存文件
        const fileName = localCache.filename || src.split('/').pop();
        taskpool.execute(saveLocal, localCache, fileName, response.body)
      }
      // 创建PixelMap并调用回调函数
      const imageSource = image.createImageSource(response.body)
      const pixelMap = imageSource.createPixelMapSync()
      PixelCache.setCache(src, pixelMap)
      return pixelMap
    } finally {
      SessionManager.fileSessionPool.release(session)
    }
  }


  /**
   * 发送请求
   * 提前获文件设置缓存
   * @param {rcp.Request} request 请求对象
   * @returns {Promise<void>}
   * */
  public static async fetch(request: rcp.Request): Promise<void> {
    if(PixelCache.hasKey(request.url.toString())){
      return
    }
    const session: rcp.Session = await SessionManager.fileSessionPool.acquire()
    try {
      const response = await session.fetch(request)
      if (response.statusCode == 200) {
        // 创建PixelMap并调用回调函数
        const imageSource = image.createImageSource(response.body)
        const pixelMap = imageSource.createPixelMapSync()
        PixelCache.setCache(request.url.toString(), pixelMap)
      }
    } finally {
      SessionManager.commonSessionPool.release(session)
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
        // 检查并创建缓存目录
        if (!fileIo.accessSync(cacheDir, fileIo.AccessModeType.EXIST)) {
          fileIo.mkdirSync(cacheDir,true)
        }
        // 解压缩文件到缓存目录
        return zlib.decompressFile(filePath,cacheDir).then(()=>{
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

/**
 * 保存文件到本地
 * @param {LocalCacheInfo} localCache 本地缓存信息
 * @param {string} fileName 文件名
 * @param {rcp.Response} response 文件响应
 * @returns {void}
 */
@Concurrent
function saveLocal(localCache: LocalCacheInfo, fileName: string, body: ArrayBuffer) {
  // 提取文件目录名
  const fileDir = localCache.dir;
  // 定义缓存目录
  let cacheBaseDir: string;
  switch (localCache.cacheType) {
    case 'temp':
      cacheBaseDir = getContext().tempDir;
      break;
    case 'cache':
      cacheBaseDir = getContext().cacheDir;
      break;
    case 'file':
      cacheBaseDir = getContext().filesDir;
      break;
    default:
      cacheBaseDir = getContext().cacheDir;
  }
  // 创建缓存目录
  if (!fileIo.accessSync(cacheBaseDir + '/' + fileDir, fileIo.AccessModeType.EXIST)) {
    fileIo.mkdirSync(cacheBaseDir + '/' + fileDir, true);
  }
  // 创建文件
  const filePath = cacheBaseDir + '/' + fileDir + '/' + fileName;
  const file = fileIo.openSync(filePath, fileIo.OpenMode.CREATE | fileIo.OpenMode.READ_WRITE);
  if (file) {
    // 将数据写入文件
    fileIo.write(file.fd, body);
    // 关闭文件
    fileIo.close(file.fd);
  }
}

/**
 * 缓存类型
 * @type {string}
 * @description temp:临时文件 cache:缓存文件 file:本地文件
 */
type CacheType = 'temp'|'cache'|'file'
/**
 * 本地缓存信息
 * @interface
 * @description 用于描述本地缓存的信息
 */
export interface LocalCacheInfo{
  /**
   * 文件名
   */
  filename?:string
  /**
   * 文件目录
   */
  dir:string
  /**
   * 缓存类型
   */
  cacheType:CacheType
}
