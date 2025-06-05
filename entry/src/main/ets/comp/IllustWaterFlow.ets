import { Illust } from '../network/model/Illust';
import { IllustCard } from './IllustCard';
import { IllustPageResponseBase } from '../network/response/IllustPageResponseBase';
import { IllustWaterFlowViewModel } from '../viewmodel/comp/IllustWaterFlowViewModel';

@ComponentV2
export struct IllustWaterFlow {

  @Require @Param firstPage: () => Promise<IllustPageResponseBase | null>;

  private model:IllustWaterFlowViewModel|null = null

  aboutToAppear(): void {
    this.model = new IllustWaterFlowViewModel(this.firstPage, this.queryNavigationInfo())
    this.model.loadInitialData();
  }


  aboutToDisappear(): void {
    this.model?.destroy()
  }

  @Builder footer() {
    Row() {
    }.height(this.model!.marginBottom).width('100%');
  }

  @Builder backToTopButton() {
    if (this.model!.showBackToTop) {
      SymbolGlyph($r('sys.symbol.arrow_up_circle'))
        .fontSize(40)
        .width(40)
        .height(40)
        .borderRadius(20)
        .onClick(() => {
          this.model!.top();
        })
        .offset({
          x: -20,
          y: -80
        })
        .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
        .backgroundColor('#FFFFFF')
        .opacity(0.9)
        .transition({
          type: TransitionType.All
        });
    }
  }

  build() {
    Stack() {
      WaterFlow({
        scroller: this.model!.scroller,
        footer: this.footer
      }) {
        if (this.model!.marginTop > 0) {
          ForEach(this.model!.columnArr, (item: number) => {
            FlowItem().height(this.model!.marginTop)
              .width('100%');
          }, (item: number) => item.toString());
        }
        LazyForEach(this.model!.datasource, (item: Illust) => {
          if (item.visible) {
            FlowItem() {
              IllustCard({ illust: item })
                .transition({
                  type: TransitionType.All
                });
            }
            .onClick(() => {
              this.model?.arkItemAction(item.id)
            });
          }
        }, (item: Illust) => item.id.toString());
      }
      .onScrollIndex((first, last) => {
        this.model?.prefetcher.visibleAreaChanged(first, last);
      })
      .nestedScroll({
        scrollForward: NestedScrollMode.PARENT_FIRST,
        scrollBackward: NestedScrollMode.SELF_FIRST
      })
      .onDidScroll((xOffset: number, yOffset: number) => {
        this.model?.handleScroll(yOffset)
      })
      .onReachEnd(() => {
        this.model?.nextPage()
      })
      .cachedCount(4)
      .columnsTemplate('1fr '.repeat(this.model!.columnCount))
      .columnsGap(12)
      .rowsGap(12)
      .height('100%')
      .width('100%')

      this.backToTopButton();
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.BottomEnd);
  }
}