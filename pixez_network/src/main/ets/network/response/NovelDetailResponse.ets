import { Novel } from "../model/Novel";
/**
 * 小说详情返回数据
 */
export interface NovelDetailResponse{
  /**
   * 小说信息
   */
  novel: Novel
}