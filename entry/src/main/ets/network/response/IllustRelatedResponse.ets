import { Illust } from "../model/Illust"
/**
 * 相关插画response
 * */
export interface IllustRelatedResponse{
  /**
   * 插图
   * */
  illusts: Illust[]
  /**
   * 下一步的url
   * */
  next_url?: string
}