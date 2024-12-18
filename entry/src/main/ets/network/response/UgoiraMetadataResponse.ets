import { UgoiraMetadata } from "../model/UgoiraMetadata";

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



