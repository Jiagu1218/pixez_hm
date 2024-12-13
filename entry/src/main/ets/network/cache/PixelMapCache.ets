import { image } from "@kit.ImageKit"

/**
 * PixelCache 类用于缓存 PixelMap 对象，以字符串键值对的形式存储。
 * 这有助于快速访问和管理图像的像素数据，避免重复处理相同图像。
 */
export class PixelCache {
  // 使用 Map 数据结构存储缓存，键为字符串，值为 PixelMap 对象。
  private static readonly cache: Map<string, image.PixelMap> = new Map()

  /**
   * 根据键获取缓存中的 PixelMap 对象。
   * @param key 缓存项的唯一键
   * @returns 返回对应的 PixelMap 对象，如果键不存在则返回 undefined。
   */
  static getCache(key: string): image.PixelMap | undefined {
    return PixelCache.cache.get(key)
  }

  /**
   * 在缓存中添加或更新键对应的 PixelMap 对象。
   * @param key 缓存项的唯一键
   * @param pixelMap 要缓存的 PixelMap 对象
   */
  static setCache(key: string, pixelMap: image.PixelMap): void {
    PixelCache.cache.set(key, pixelMap)
  }

  /**
   * 从缓存中删除指定键的缓存项。
   * @param key 缓存项的唯一键
   */
  static delCache(key: string): void {
    // 检查缓存中是否存在该键，以避免不必要的删除操作。
    if (PixelCache.cache.has(key)) {
      PixelCache.cache.delete(key)
    }
  }

  /**
   * 清空整个缓存。
   * 这在需要释放资源或重新初始化缓存时非常有用。
   */
  static clear(): void {
    PixelCache.cache.clear()
  }
}
