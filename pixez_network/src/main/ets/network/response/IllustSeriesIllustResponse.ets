import { Illust } from "../model/Illust"
import { IllustSeriesDetail } from "../model/IllustSeriesDetail"

/**
 * 画作系列画作响应
 */
export interface IllustSeriesIllustResponse{
  /**
   * 画作系列详情
   */
  illust_series_detail: IllustSeriesDetail
  /**
   * 画作系列上下文
   */
  illust_series_context: IllustSeriesContext
}

interface IllustSeriesContext {
  /**
   * 序号
   */
  content_order: number
  /**
   * 上一页
   */
  prev: Illust|null
  /**
   * 下一页
   */
  next: Illust|null
}