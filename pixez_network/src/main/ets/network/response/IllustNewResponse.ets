import { Illust } from "../model/Illust"
/**
 * 获取新作插画
 * */
export interface IllustNewResponse{
  /**
   * 插画列表
   */
  illusts:Illust[]
  /**
   * 下一页
   */
  next_url:string|null
}