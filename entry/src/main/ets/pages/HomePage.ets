import { IllustWaterFlow } from '../comp/IllustWaterFlow'
import { SearchTab } from '../comp/SearchTab'
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
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#EEF2FF', 0.0], ['#F8FAFC', 0.5], ['#F1F5F9', 1.0]]
        })
      Navigation(this.model.pathStack) {
      Tabs({controller:this.model.tabController}){
        TabContent(){
          IllustWaterFlow({controller:this.model.illustController,marginBottom:56,firstPage:()=>this.model.getIllustRecommend()})
        }.tabBar(this.model.illustBar)
        TabContent(){
          if (this.model.tabLoad[1]){
            IllustWaterFlow({controller:this.model.mangaController,marginBottom:56,firstPage:()=>this.model.getMangaRecommend()})
          }
        }.tabBar(this.model.mangaBar)
        TabContent(){
          if (this.model.tabLoad[2]){
            IllustWaterFlow({controller:this.model.illustRankingController,marginBottom:56,firstPage:()=>this.model.getIllustRanking()})
          }
        }.tabBar(this.model.rankingBar)
        TabContent(){
          if (this.model.tabLoad[3]){
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
    }
    .height('100%')
    .width('100%')
    .hideToolBar(true)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .backgroundColor(Color.Transparent)
    }
    .width('100%')
    .height('100%')
  }
}