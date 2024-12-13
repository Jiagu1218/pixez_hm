import { Illust } from "../../entity/Illust"

/**
 * 引导插图response
 * */
export interface WalkthroughIllustsResponse{
  /**
   * 插图
   * */
  illusts: Illust[]
  /**
   * 下一步的url
   * */
  next_url?: string
}