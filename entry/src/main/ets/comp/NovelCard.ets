import { Novel, Tag } from "../network/model/Novel"
import { HttpImage } from "./HttpImage"
import { LengthUnit, router } from "@kit.ArkUI"

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
    Row({space:16}){
      Column(){
        HttpImage({url: this.novel.image_urls.medium})
      }.width('30%')
      Column({space:8}){
        Text(this.novel.title).maxLines(3).fontSize(16).fontWeight(500)
        Row({space:16}){
          Text(this.novel.user.name).maxLines(1).fontSize(14).fontWeight(400).fontColor(Color.Blue)
          Text(){
            SymbolSpan($r('sys.symbol.message_on_message'))
            Span(`  ${this.novel.total_comments}`)
          }.fontSize(14)
        }.width('100%')
        Flex({wrap:FlexWrap.Wrap,space:{main:{value: 8,unit:LengthUnit.VP}}}){
          ForEach(this.novel.tags,(item:Tag)=>{
            Text(item.translated_name?`#${item.name} (${item.translated_name})`:`#${item.name}`).fontSize(12).maxLines(1)
              .borderWidth(1)
              .borderColor(Color.Gray)
              .borderRadius(4)
          },(item:Tag,index)=>index.toString())
        }.width('100%')
        .alignSelf(ItemAlign.Start)
      }.layoutWeight(1)
      .alignItems(HorizontalAlign.Start)
      .justifyContent(FlexAlign.Start)
      Column(){
        SymbolGlyph(this.like?$r('sys.symbol.bookmark_fill'):$r('sys.symbol.bookmark')).fontSize(24)
        Text(this.novel.total_bookmarks.toString()).fontSize(14)
      }.width('10%')
    }.borderRadius($r('sys.float.ohos_id_card_border_radius'))
    .width('100%')
    .aspectRatio(16/9)
    .backgroundColor(Color.Orange)
    .onClick(()=>{
      router.pushUrl({
        url: 'pages/NovelDetailPage',
        params: {
          novelId: this.novel.id
        }
      })
    })
  }
}