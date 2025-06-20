
import { HttpImage } from "./HttpImage"
import { uiEffect } from "@kit.ArkGraphics2D"
import { ApiClient, BookmarkDetail, IllustBookmarkDetailResponse, IllustBookmarkTag, Tag } from "pixez_network"
import { Illust } from "pixez_network"

@ReusableV2
@ComponentV2
export struct IllustCard {
  @Require @Param illust: Illust
  @Param limitLevel: number = 6
  @Local private aRatio: number = 16/9
  @Local private like: boolean = false
  @Local private filter: Filter = uiEffect.createFilter()
  @Local private showSheet: boolean = false
  @Local private bookmarkDetail: BookmarkDetail | null = null
  @Local private isHovered: boolean = false

  aboutToAppear(): void {
    this.aRatio = this.illust.width/this.illust.height
    this.like = this.illust.is_bookmarked
    this.setLimitBlur()
  }

  @Monitor('limitLevel')
  watchLimitLevel() {
    this.setLimitBlur()
  }

  getBookmarkDetail() {
    ApiClient.getIllustBookmarkDetail(this.illust.id).then(res => {
      if (res) {
        const resp = res.toJSON() as IllustBookmarkDetailResponse
        this.bookmarkDetail = resp.bookmark_detail
        this.like = resp.bookmark_detail.is_bookmarked
      }
    })
  }

  @Builder sheet() {
    Column({ space: 12 }) {
      if (this.bookmarkDetail) {
        List({ space: 8 }) {
          ForEach(this.bookmarkDetail.tags, (tag: IllustBookmarkTag) => {
            ListItem() {
              Row() {
                Text(tag.name)
                  .fontSize(14)
                  .fontColor('#333333')
                Checkbox()
                  .select(tag.is_registered)
                  .selectedColor('#FF4081')
              }
              .justifyContent(FlexAlign.SpaceBetween)
              .width('100%')
              .padding({ left: 16, right: 16 })
            }
            .backgroundColor('#FFFFFF')
            .borderRadius(8)
          },(tag: Tag)=>tag.name)
        }
        .nestedScroll({
          scrollForward: NestedScrollMode.PARENT_FIRST,
          scrollBackward: NestedScrollMode.SELF_FIRST,
        })
        .divider({ strokeWidth: 1, color: '#F0F0F0' })
      }
    }
    .width('100%')
    .padding({ top: 16, bottom: 16 })
  }

  setLimitBlur() {
    if (this.illust.sanity_level >= this.limitLevel) {
      this.filter.blur(20)
    }
  }

  @Builder overlayNode() {
    Row({ space: 8 }) {
      if (this.illust.type !== 'illust') {
        Text(`${this.illust.type}`)
          .fontSize(12)
          .fontColor('#FFFFFF')
          .padding({ left: 8, right: 8, top: 4, bottom: 4 })
          .borderWidth(1)
          .borderColor('#FFFFFF')
          .borderRadius(4)
          .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
      } else if (this.illust.meta_pages.length > 1) {
        Text() {
          SymbolSpan($r('sys.symbol.picture_2'))
            .fontSize(12)
          Span(`${this.illust.meta_pages.length}`)
            .fontSize(12)
        }
        .fontColor('#FFFFFF')
        .padding({ left: 8, right: 8, top: 4, bottom: 4 })
        .borderWidth(1)
        .borderColor('#FFFFFF')
        .borderRadius(4)
        .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
      }
    }
    .padding(8)
  }

  build() {
    Column() {
      Stack() {
        Column() {
          HttpImage({
            url: this.illust.image_urls.large,
            aRatio: this.aRatio,
            br: {
              topLeft: $r('sys.float.ohos_id_card_border_radius'),
              topRight: $r('sys.float.ohos_id_card_border_radius')
            }
          })
        }
        .compositingFilter(this.filter)
        .borderRadius({
          topLeft: $r('sys.float.ohos_id_card_border_radius'),
          topRight: $r('sys.float.ohos_id_card_border_radius')
        })
        this.overlayNode()
      }
      .alignContent(Alignment.TopEnd)
      .borderRadius({
        topLeft: $r('sys.float.ohos_id_card_border_radius'),
        topRight: $r('sys.float.ohos_id_card_border_radius')
      })
      .onHover((isHovered: boolean) => {
        this.isHovered = isHovered
      })
      .scale({ x: this.isHovered ? 1.02 : 1, y: this.isHovered ? 1.02 : 1 })
      .transition({
        type: TransitionType.All
      })

      Row() {
        Column({ space: 4 }) {
          Text(this.illust.title)
            .maxLines(1)
            .fontSize(16)
            .fontWeight(500)
            .fontColor('#333333')
          Text(this.illust.user.name)
            .maxLines(1)
            .fontSize(14)
            .fontWeight(400)
            .fontColor('#666666')
        }
        .justifyContent(FlexAlign.SpaceAround)
        .padding({ left: 12 })
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)

        SymbolGlyph(this.like ? $r('sys.symbol.heart_fill') : $r('sys.symbol.heart'))
          .fontSize(24)
          .fontColor(this.like ? ['#FF4081'] : ['#999999'])
          .bindSheet(this.showSheet, this.sheet(), {
            height: SheetSize.MEDIUM,
            blurStyle: BlurStyle.Thin,
            title: { title: '收藏详情' },
            shouldDismiss: () => {
              this.showSheet = false
            }
          })
          .gesture(
            LongPressGesture({ repeat: false, duration: 1000 })
              .onAction((event) => {
                this.getBookmarkDetail()
                this.showSheet = true
              })
          )
          .onClick(() => {
            if (this.like) {
              ApiClient.postUnLikeIllust(this.illust.id).then(res => {
                this.like = false
                console.info('取消收藏成功', res)
              })
            } else {
              ApiClient.postLikeIllust(this.illust.id, 'public').then(res => {
                this.like = true
                console.info('收藏成功', res)
              })
            }
          })
          .width(48)
          .height(48)
      }
      .borderRadius({
        bottomLeft: $r('sys.float.ohos_id_card_border_radius'),
        bottomRight: $r('sys.float.ohos_id_card_border_radius')
      })
      .padding({ top: 8, bottom: 8 })
    }
    .borderRadius($r('sys.float.ohos_id_card_border_radius'))
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
    .shadow({
      radius: 8,
      color: '#000000',
      offsetX: 0,
      offsetY: 2
    })
    .transition({
      type: TransitionType.All
    })
  }
}