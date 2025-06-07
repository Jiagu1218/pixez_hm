import { IllustWaterFlow } from '../comp/IllustWaterFlow'
import { NovelList } from '../comp/NovelList'
import { SearchTab } from '../comp/SearchTab'
import { RankingTab } from '../comp/RankingTab'
import { HomeViewModel } from '../viewmodel/HomeViewModel'

@Entry
@ComponentV2
struct HomePage {
  @Local private model: HomeViewModel = new HomeViewModel()
  onPageShow(){
    this.model.appRequire()
  }
  aboutToAppear(): void {
    this.model.setBarPadding(10)
  }


  build() {
    Navigation(this.model.pathStack){
      Tabs({controller:this.model.tabController}){
        TabContent(){
          IllustWaterFlow({controller:this.model.illustController,marginBottom:56,firstPage:()=>this.model.getIllustRecommend()})
        }.tabBar(this.model.illustBar)
        TabContent(){
          if (this.model.tabLoad[1]){
            NovelList({controller:this.model.novelController,marginBottom:56,firstPage:()=>this.model.getNovelRecommended()})
          }
        }.tabBar(this.model.novelBar)
        TabContent(){
          if (this.model.tabLoad[2]){
            IllustWaterFlow({controller:this.model.mangaController,marginBottom:56,firstPage:()=>this.model.getMangaRecommend()})
          }
        }.tabBar(this.model.mangaBar)
        TabContent(){
          if (this.model.tabLoad[3]){
            RankingTab()
          }
        }.tabBar(this.model.rankingBar)
        TabContent(){
          if (this.model.tabLoad[4]){
            SearchTab({marginTop:56,marginBottom:56})
          }
        }.tabBar(this.model.searchBar)
      }.width('100%')
      .height('100%')
      .barOverlap(true)
      .barPosition(BarPosition.End)
      .barBackgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
      .onChange((index)=>{
        this.model.tabLoad[index] = true
      })
      .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    }.height('100%')
    .width('100%')
    .hideToolBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
  }
}