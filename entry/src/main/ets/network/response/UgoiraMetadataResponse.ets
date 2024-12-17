/**
 * UgoiraMetadataResponse接口定义了获取动画图片（Ugoira）元数据的响应格式
 * 它包含了一个UgoiraMetadata对象，该对象具体描述了动画图片的元数据信息
 */
export interface UgoiraMetadataResponse{
  /**
   * Ugoira元数据对象
   * */
  ugoira_metadata: UgoiraMetadata
}

/**
 * UgoiraMetadata接口详细定义了动画图片的元数据结构
 * 包括了动画图片的下载URL和每一帧的信息
 */
interface UgoiraMetadata {
  /**
   * 包含动画图片压缩包的下载URL
   * */
  zip_urls: ZipUrls
  /**
   * 动画图片的帧信息数组
   * */
  frames: Frame[]
}

/**
 * ZipUrls接口定义了动画图片压缩包的下载URL
 * 包含了一个medium字段，表示中等尺寸的压缩包下载地址
 */
interface ZipUrls {
  /**
   * 中等尺寸动画图片压缩包的下载地址
   * */
  medium: string
}

/**
 * Frame接口描述了动画图片中每一帧的详细信息
 * 包括了帧的文件名和该帧的显示延迟时间
 */
interface Frame {
  /**
   * 帧的文件名
   * */
  file: string
  /**
   * 帧的显示延迟时间，单位为秒
   * */
  delay: number
}

