import { IllustWaterFlowController } from '../controller/IllustWaterFlowController'
import { NovelListController } from '../controller/NovelListController'

import { IllustWaterFlow } from './IllustWaterFlow'
import { NovelList } from './NovelList'
import { SymbolGlyphModifier } from '@kit.ArkUI'
import { ApiClient,
  IllustRankingModeEnum,
  IllustRankingResponse, NovelRankingModeEnum, NovelRankingResponse } from 'pixez_network'

@ComponentV2
export struct RankingTab{
  private illustRankingController:IllustWaterFlowController = new IllustWaterFlowController()
  private novelRankingController:NovelListController = new NovelListController()
  private illustBar: BottomTabBarStyle | SubTabBarStyle = BottomTabBarStyle.of({
    normal: new SymbolGlyphModifier($r('sys.symbol.picture')),
    selected: new SymbolGlyphModifier($r('sys.symbol.picture_fill')),
  }, '插画')
  private novelBar: BottomTabBarStyle | SubTabBarStyle = BottomTabBarStyle.of({
    normal: new SymbolGlyphModifier($r('sys.symbol.doc_text')),
    selected: new SymbolGlyphModifier($r('sys.symbol.doc_text_fill'))
  }, '小说')
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
      }.tabBar(this.illustBar)
      TabContent(){
        if (this.tabLoad[1]){
          NovelList({controller:this.novelRankingController,marginTop:56,marginBottom:56,firstPage:()=>this.getNovelRanking()})
        }
      }.tabBar(this.novelBar)
    }.barBackgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
    .onChange((index)=>{
      this.tabLoad[index] = true
    }).barOverlap(true)
  }
}