

import { LengthUnit } from "@kit.ArkUI"

import { NovelRouterParam } from "../param/NovelRouterParam"
import { BusinessError } from "@kit.BasicServicesKit"
import { ApiClient, HttpImage, Novel,Tag } from "common"


@ReusableV2
@ComponentV2
export struct NovelCard {
  @Require @Param novel:Novel
  @Param limitLevel:number = 6
  @Local private aRatio:number = 9/16
  @Local private like:boolean = false
  aboutToAppear(): void {
    this.like = this.novel.is_bookmarked
  }
  build() {
    Row({ space: 14 }) {
      Column() {
        HttpImage({
          url: this.novel.image_urls.medium,
          aRatio: this.aRatio,
          br: 10
        })
      }
      .width('30%')

      Column({ space: 8 }) {
        Text(this.novel.title)
          .maxLines(3)
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#1E293B')
        Row({ space: 12 }) {
          Text(this.novel.user.name)
            .maxLines(1)
            .fontSize(14)
            .fontWeight(400)
            .fontColor('#2563EB')
          Text() {
            SymbolSpan($r('sys.symbol.message_on_message'))
            Span(`  ${this.novel.total_comments}`)
          }
          .fontSize(14)
          .fontColor('#64748B')
        }
        .width('100%')
        Flex({ wrap: FlexWrap.Wrap, space: { main: { value: 8, unit: LengthUnit.VP } } }) {
          ForEach(this.novel.tags, (item: Tag) => {
            Text(item.translated_name ? `#${item.name} (${item.translated_name})` : `#${item.name}`)
              .fontSize(11)
              .maxLines(1)
              .fontColor('#475569')
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .backgroundColor('#F1F5F9')
              .borderRadius(8)
          }, (item: Tag) => item.name)
        }
        .width('100%')
        .alignSelf(ItemAlign.Start)
      }
      .layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)

      Column({ space: 4 }) {
        SymbolGlyph(this.like ? $r('sys.symbol.bookmark_fill') : $r('sys.symbol.bookmark'))
          .fontColor(this.like ? ['#F59E0B'] : ['#94A3B8'])
          .fontSize(24)
        Text(this.novel.total_bookmarks.toString())
          .fontSize(12)
          .fontColor('#64748B')
      }
      .width('10%')
      .alignItems(HorizontalAlign.Center)
      .onClick(()=>{
        if (this.like) {
          ApiClient.postNovelBookmarkDelete(this.novel.id).then(res=>{
            this.like = false
            this.novel.is_bookmarked = false
          }).catch((e:BusinessError)=>{
            console.error('取消收藏失败',e)
          })
        }else {
          ApiClient.postNovelBookmarkAdd(this.novel.id,'public').then(res=>{
            this.like = true
            this.novel.is_bookmarked = true
          }).catch((e:BusinessError)=>{
            console.error('收藏失败',e)
          })
        }
      })
    }
    .borderRadius($r('sys.float.ohos_id_card_border_radius'))
    .width('100%')
    .padding({ left: 12, right: 12, top: 10, bottom: 10 })
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
    .border({
      width: 1,
      color: '#EEF2F6'
    })
    .shadow({
      radius: 10,
      color: '#0000000C',
      offsetX: 0,
      offsetY: 3
    })
  }
}