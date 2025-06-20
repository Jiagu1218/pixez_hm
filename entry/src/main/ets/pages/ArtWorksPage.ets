
import { LengthUnit } from '@kit.ArkUI'
import { HttpImage } from '../comp/HttpImage';
import { SaveImage } from '../comp/SaveImage';

import { UgoiraImage } from '../comp/UgoiraImage';
import { HtmlText } from '../comp/HtmlText';
import { CommentList } from '../comp/CommentList';
import { IllustSeriesNav } from '../comp/IllustSeriesNav';
import { ArtWorksViewModel } from '../viewmodel/ArtWorksViewModel';
import { DateTimeUtil, Illust, MetaPage, Tag } from 'pixez_network';

@Entry
@ComponentV2
struct ArtWorksPage {
  @Local private model: ArtWorksViewModel = new ArtWorksViewModel()
  @Local private isHovered: boolean = false

  aboutToAppear(): void {
    this.model.init(this.queryNavigationInfo())
  }

  aboutToDisappear(): void {
    this.model.destroy()
  }

  @Builder
  private showRowImage() {
    Row() {
      SaveImage({ urls: this.model.illustsRawUrl, initIndex: this.model.initIndex })
    }
    .width('100%')
    .height('100%')
  }

  @Builder
  private overlayNode(illust: Illust) {
    Row() {
      if (illust.type !== 'illust') {
        Text(`${illust.type}`)
          .fontSize(14)
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderWidth(1)
          .borderRadius(4)
          .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
      } else if (illust.meta_pages.length > 1) {
        Text() {
          SymbolSpan($r('sys.symbol.picture_2'))
          Span(`${illust.meta_pages.length}`)
        }
        .fontSize(14)
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .borderWidth(1)
        .borderRadius(4)
        .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
      }
    }
  }

  @Builder
  private commentSheet() {
    CommentList({
      relateId: this.model.illustId,
      firstPage: () => this.model.getComments(),
      getReply: (commentId) => this.model.getCommentReply(commentId),
      postComment: (relateId, comment, parentCommentId) => this.model.postComment(relateId, comment, parentCommentId)
    })
  }

  @Builder
  private ArtworkHeader() {
    Column() {
      if (this.model.illust) {
        if (this.model.illust.meta_pages?.length > 0) {
          ForEach(this.model.illust.meta_pages, (item: MetaPage) => {
            HttpImage({ url: item.image_urls.large })
              .width('100%')
              .borderRadius(12)
              .shadow({
                radius: 12,
                color: '#00000015',
                offsetX: 0,
                offsetY: 6
              })
              .onClick(() => {
                this.model.initIndex = this.model.illust!.meta_pages.indexOf(item)
                this.model.currentRawUrl = item.image_urls.original
                this.model.showRaw = true
              })
          },(item: MetaPage)=>item.image_urls.square_medium)
        } else {
          if (this.model.illust.type === 'ugoira') {
            UgoiraImage({ illust: this.model.illust })
          } else {
            HttpImage({ url: this.model.illust.image_urls.large })
              .width('100%')
              .borderRadius(12)
              .shadow({
                radius: 12,
                color: '#00000015',
                offsetX: 0,
                offsetY: 6
              })
              .onClick(() => {
                this.model.currentRawUrl = this.model.illust!.meta_single_page!.original_image_url!
                this.model.showRaw = true
              })
          }
        }
      }
    }
    .width('100%')
    .padding({left:16, right:16})
  }

  @Builder
  private ArtworkInfo() {
    Column({ space: 16 }) {
      if (this.model.illust?.series) {
        IllustSeriesNav({ illustId: this.model.illust.id, seriesId: this.model.illust.series.id })
      }
      Column({ space: 16 }) {
        Text(this.model.illust?.title ?? '')
          .fontSize(40)
          .fontWeight(FontWeight.Bold)
          .margin({ top: 20 })
        Row({ space: 16 }) {
          Text() {
            SymbolSpan($r('sys.symbol.eye'))
            Span(this.model.illust?.total_view?.toString() ?? '0')
          }
          .fontSize(14)
          .fontColor('#666666')
          Text() {
            SymbolSpan($r('sys.symbol.heart_fill'))
            Span(this.model.illust?.total_bookmarks?.toString() ?? '0')
          }
          .fontSize(14)
          .fontColor('#666666')
          Text() {
            SymbolSpan($r('sys.symbol.calendar_badge_clock'))
            Span(this.model.illust ? DateTimeUtil.parseIsoTimeToLocalFormatTime(this.model.illust.create_date) : '-')
          }
          .fontSize(14)
          .fontColor('#666666')
        }
        Row({ space: 16 }) {
          Text(`插画ID: ${this.model.illust?.id ?? '-'}`)
            .fontSize(14)
            .fontColor('#666666')
          Text(`分辨率: ${this.model.illust?.width ?? '-'}x${this.model.illust?.height ?? '-'}`)
            .fontSize(14)
            .fontColor('#666666')
        }
        Row() {
          Row({ space: 16 }) {
            if (this.model.illust?.user?.profile_image_urls?.medium) {
              HttpImage({ url: this.model.illust.user.profile_image_urls.medium, br: 24 })
                .width(48)
                .borderRadius(24)
            }
            Text(this.model.illust?.user?.name ?? '')
              .fontSize(16)
              .fontWeight(FontWeight.Bold)
          }
          .onClick(() => {
            this.model.userDetailAction()
          })
          Button(this.model.followed ? '已关注' : '关注')
            .width(80)
            .backgroundColor(this.model.followed ? '#E0E0E0' : '#2196F3')
            .fontColor(this.model.followed ? '#666666' : '#FFFFFF')
            .onClick(() => {
              this.model.followAction()
            })
        }
        .width('100%')
        .justifyContent(FlexAlign.SpaceBetween)
      }
      .width('100%')
      .alignItems(HorizontalAlign.Start)
      if (this.model.illust?.tags) {
        Row() {
          Flex({ wrap: FlexWrap.Wrap, space: { main: { value: 16, unit: LengthUnit.VP }, cross: { value: 8, unit: LengthUnit.VP } } }) {
            ForEach(this.model.illust.tags, (item: Tag) => {
              Text() {
                Span(`#${item.name}`)
                  .fontColor('#2196F3')
                if (item.translated_name) {
                  Span(`  (${item.translated_name})`)
                }
              }
              .fontSize(14)
              .padding({ left: 16, right: 16, top: 8, bottom: 8 })
              .borderRadius(20)
              .onClick(() => {
                this.model.tagAction(item)
              })
            },(item: Tag)=>item.name)
          }
        }
      }
      if (this.model.illust?.caption) {
        Row() {
          HtmlText({ htmlText: this.model.illust.caption })
        }
        .margin(16)
        .padding(20)
        .width('90%')
        .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
        .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
        .shadow({
          radius: 8,
          color: '#00000010',
          offsetX: 0,
          offsetY: 4
        })
      }
      Row() {
        Text() {
          SymbolSpan($r('sys.symbol.topic_message_fill'))
          Span("查看评论")
        }
        .fontSize(16)
        .fontColor('#2196F3')
        .onClick(() => {
          this.model.showComments = true
        })
      }
      .bindSheet(this.model.showComments, this.commentSheet(), {
        blurStyle: BlurStyle.Thin,
        title: { title: '相关评论' },
        shouldDismiss: () => {
          this.model.showComments = false
        }
      })
    }
    .width('100%')
    .padding({left:16, right:16})
  }

  @Builder
  private RelatedArtworks() {
    if (this.model.relatedIllusts) {
      Column() {
        Grid() {
          Repeat(this.model.relatedIllusts)
            .each(item => {
              GridItem() {
                Stack() {
                  HttpImage({ url: item.item.image_urls.square_medium, aRatio: 1 })
                    .borderRadius(12)
                    .shadow({
                      radius: 8,
                      color: '#00000010',
                      offsetX: 0,
                      offsetY: 4
                    })
                  this.overlayNode(item.item)
                }
                .alignContent(Alignment.TopEnd)
              }
              .onClick(() => {
                this.model.relatedAction(item.item)
              })
            })
            .key(item => item.id.toString())
        }
        .columnsTemplate('repeat(auto-fit, 100)')
        .height('100%')
        .cachedCount(6)
        // .onScrollIndex((first, last) => {
        //   this.model.illustPrefetcher.visibleAreaChanged(first, last)
        // })
        .nestedScroll({
          scrollForward: NestedScrollMode.PARENT_FIRST,
          scrollBackward: NestedScrollMode.SELF_FIRST
        })
        .onReachEnd(() => {
          this.model.relatedPageAction()
        })
      }
      .width('100%')
      .padding({left:16, right:16})
    }
  }

  build() {
    NavDestination() {
      Scroll() {
        Column({ space: 20 }) {
          this.ArtworkHeader()
          this.ArtworkInfo()
          this.RelatedArtworks()
        }
        .justifyContent(FlexAlign.Start)
        .bindContentCover(this.model.showRaw, this.showRowImage(), {
          onWillDismiss: () => {
            this.model.showRaw = false
          },
          modalTransition: ModalTransition.ALPHA
        })
      }
      .scrollBar(BarState.Off)
      .height('100%')
      .width('100%')
    }
    .hideTitleBar(true)
  }
}

@Builder
export function ArtWorksPageBuilder() {
  ArtWorksPage()
}