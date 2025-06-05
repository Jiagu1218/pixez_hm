import { LengthUnit } from '@kit.ArkUI';
import { CommentList } from '../comp/CommentList';
import { HtmlText } from '../comp/HtmlText';
import { HttpImage } from '../comp/HttpImage';
import { NovelContentPart } from '../entity/NovelContent';
import { getNovelContentParts } from '../util/NovelUtil';
import { NovelDetailViewModel } from '../viewmodel/NovelDetailViewModel';

@Entry
@ComponentV2
struct NovelDetailPage {
  @Local private model: NovelDetailViewModel = new NovelDetailViewModel()
  @Local private isHovered: boolean = false

  aboutToAppear(): void {
    this.model.init(this.queryNavigationInfo())
  }

  @Monitor('model.webViewNovel')
  dealWithText() {
    if (!this.model.webViewNovel) {
      this.model.content = [];
      return;
    }
    this.model.content = getNovelContentParts(this.model.webViewNovel)
  }

  @Monitor('model.novelId')
  watchNovelId() {
    this.model.getWebViewNovel()
  }

  @Builder
  private NovelHeader() {
    if (this.model.webViewNovel){
      Column() {
        HttpImage({ url: this.model.webViewNovel.coverUrl })
          .width('100%')
          .height(200)
          .borderRadius(8)
          .shadow({
            radius: 8,
            color: '#00000010',
            offsetX: 0,
            offsetY: 4
          })
        Row() {
          Text(this.model.webViewNovel.title)
            .fontSize(36)
            .fontWeight(FontWeight.Bold)
            .margin({ top: 16 })
        }.width('100%')
        Row() {
          Text(this.model.webViewNovel.cdate)
            .fontSize(14)
            .fontColor('#666666')
        }.width('100%')
        Flex({ wrap: FlexWrap.Wrap, space: { main: { value: 8, unit: LengthUnit.VP } } }) {
          ForEach(this.model.webViewNovel.tags, (item: string) => {
            Text(item)
              .fontSize(14)
              .padding({ left: 12, right: 12, top: 6, bottom: 6 })
              .borderColor('#E0E0E0')
              .borderWidth(1)
              .borderRadius(16)
              .onClick(() => {
                this.model.tagAction(item)
              })
          }, (item: string,index)=>index + item)
        }
        Text('查看评论')
          .fontSize(16)
          .fontColor('#2196F3')
          .margin({ top: 16 })
          .onClick(() => this.model.showComments = true)
      }
      .width('100%')
      .padding(16)
    }

  }

  @Builder
  private NovelCaption() {
    if (this.model.webViewNovel && this.model.webViewNovel.caption) {
      Row() {
        HtmlText({ htmlText: this.model.webViewNovel.caption })
      }
      .margin(16)
      .padding(16)
      .width('90%')
      .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
      .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
      .shadow({
        radius: 4,
        color: '#00000005',
        offsetX: 0,
        offsetY: 2
      })
    }
  }

  @Builder
  private NovelContent() {
    Column() {
      ForEach(this.model.content, (item: NovelContentPart) => {
        if (item.type == 'illust' || item.type == 'image') {
          HttpImage({
            url: item.content
          })
            .width('100%')
            .borderRadius(8)
            .margin({ top: 16, bottom: 16 })
        } else {
          Text(item.content)
            .fontSize(16)
            .lineHeight(24)
            .margin({ top: 8, bottom: 8 })
        }
      },(item: NovelContentPart)=>JSON.stringify(item))
    }
    .width('100%')
    .padding(16)
  }

  @Builder
  private NovelNavigation() {
    if (this.model.webViewNovel && this.model.webViewNovel.seriesNavigation) {
      Divider()
      Row() {
        Text() {
          SymbolSpan($r('sys.symbol.arrow_left'))
          Span(' ')
          Span(this.model.webViewNovel.seriesNavigation.prevNovel?.title ?? '')
        }
        .maxLines(2)
        .width('40%')
        .fontSize(14)
        .fontColor('#2196F3')
        .visibility(this.model.webViewNovel.seriesNavigation.prevNovel ? Visibility.Visible : Visibility.Hidden)
        .onClick(() => {
          this.model.prevNovelAction()
        })

        Text() {
          Span(this.model.webViewNovel.seriesNavigation.nextNovel?.title ?? '')
          Span(' ')
          SymbolSpan($r('sys.symbol.arrow_right'))
        }
        .maxLines(2)
        .width('40%')
        .fontSize(14)
        .fontColor('#2196F3')
        .visibility(this.model.webViewNovel.seriesNavigation.nextNovel ? Visibility.Visible : Visibility.Hidden)
        .onClick(() => {
          this.model.nextNovelAction()
        })
      }
      .width('100%')
      .padding(16)
      .justifyContent(FlexAlign.SpaceBetween)
    }
  }

  build() {
    NavDestination() {
      Scroll(this.model.scroller) {
        Column({ space: 16 }) {
          if (this.model.webViewNovel) {
            this.NovelHeader()
            Divider()
            this.NovelCaption()
            this.NovelContent()
            this.NovelNavigation()
          }
        }
        .width('100%')
      }
      .height('100%')
      .width('100%')
      .bindSheet(this.model.showComments!!, this.commentSheet(), {
        blurStyle: BlurStyle.Thin,
        title: { title: '相关评论' },
        shouldDismiss: () => {
          this.model.showComments = false
        }
      })
    }
    .hideTitleBar(true)
  }

  @Builder
  commentSheet(): CustomBuilder {
    CommentList({
      relateId: this.model.novelId,
      firstPage: () => this.model.getComments(),
      getReply: (commentId: number) => this.model.getCommentReply(commentId),
      postComment: (relateId: number, comment: string, parentCommentId?: number) =>
      this.model.postComment(relateId, comment, parentCommentId)
    })
  }
}

@Builder
export function NovelDetailPageBuilder() {
  NovelDetailPage()
}
