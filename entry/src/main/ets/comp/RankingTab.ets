import { IllustWaterFlowController } from "../controller/IllustWaterFlowController"
import { NovelListController } from "../controller/NovelListController"
import { ApiClient } from "../network/ApiClient"
import { IllustRankingModeEnum } from "../network/enums/IllustRankingModeEnum"
import { NovelRankingModeEnum } from "../network/enums/NovelRankingModeEnum"
import { IllustRankingResponse } from "../network/response/IllustRankingResponse"
import { NovelRankingResponse } from "../network/response/NovelRankingResponse"
import { IllustWaterFlow } from "./IllustWaterFlow"
import { NovelList } from "./NovelList"

@ComponentV2
export struct RankingTab{
  private illustRankingController:IllustWaterFlowController = new IllustWaterFlowController()
  private novelRankingController:NovelListController = new NovelListController()
  @Local private tabLoad:Array<boolean> = [true,false]
  getIllustRanking():Promise<IllustRankingResponse|null>{
    return ApiClient.getIllustRanking(IllustRankingModeEnum.DAY).then(res=>{
      const json = res?.toJSON()
      if (json) {
        return json as IllustRankingResponse
      }else {
        return null
      }
    })
  }

  getNovelRanking():Promise<NovelRankingResponse|null>{
    return ApiClient.getNovelRanking(NovelRankingModeEnum.DAY).then(res=>{
      const json = res?.toJSON()
      if (json) {
        return json as NovelRankingResponse
      }else {
        return null
      }
    })
  }
  build() {
    Tabs(){
      TabContent(){
        if (this.tabLoad[0]){
          IllustWaterFlow({controller:this.illustRankingController,marginTop:56,marginBottom:56,firstPage:()=>this.getIllustRanking()})
        }
      }.tabBar( '插画')
      TabContent(){
        if (this.tabLoad[1]){
          NovelList({controller:this.novelRankingController,marginTop:56,marginBottom:56,firstPage:()=>this.getNovelRanking()})
        }
      }.tabBar('小说')
    }.barBackgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
    .onChange((index)=>{
      this.tabLoad[index] = true
    }).barOverlap(true)
  }
}