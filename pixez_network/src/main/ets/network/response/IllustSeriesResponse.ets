import { Illust } from "../model/Illust"
import { IllustSeriesDetail } from "../model/IllustSeriesDetail"
/**
 * 画集系列响应
 */
export interface IllustSeriesResponse{
  /**
   * 画集系列详情
   */
  illust_series_detail: IllustSeriesDetail
  /**
   * 画集系列第一张画作
   */
  illust_series_first_illust: Illust
  /**
   * 画集系列画作列表
   */
  illusts: Illust[]
  /**
   * 画集系列下一页的url
   */
  next_url: string|null
}