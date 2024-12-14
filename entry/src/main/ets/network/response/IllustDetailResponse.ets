import { Illust } from "../model/Illust";

/**
 * 定义插画详情响应接口
 * 该接口包含一个名为illust的属性，其类型为Illust，用于表示插画的详细信息
 */
export interface IllustDetailResponse{
  illust:Illust
}
