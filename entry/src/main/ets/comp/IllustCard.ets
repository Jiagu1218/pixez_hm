import { ApiClient } from "../network/ApiClient"
import { Illust } from "../network/model/Illust"
import { HttpImage } from "./HttpImage"
import { uiEffect } from "@kit.ArkGraphics2D"
import { BookmarkDetail, IllustBookmarkDetailResponse, Tag } from "../network/response/IllustBookmarkDetailResponse"

@ComponentV2
export struct IllustCard{
  @Require @Param illust:Illust
  @Param limitLevel:number = 6
  @Local private aRatio:number = 16/9
  @Local private like:boolean = false
  @Local private filter:Filter = uiEffect.createFilter()
  @Local private showSheet:boolean = false
  @Local private bookmarkDetail:BookmarkDetail|null = null
  private pathStack:NavPathStack|undefined = undefined
  aboutToAppear(): void {
    this.pathStack = this.queryNavigationInfo()?.pathStack
    this.aRatio = this.illust.width/this.illust.height
    this.like = this.illust.is_bookmarked
    this.setLimitBlur()
  }
  @Monitor('limitLevel')
  watchLimitLevel(){
    this.setLimitBlur()
  }

  getBookmarkDetail(){
    ApiClient.getIllustBookmarkDetail(this.illust.id).then(res=>{
      if (res) {
        console.info('收藏详情', res)
        const resp = res.toJSON() as IllustBookmarkDetailResponse
        this.bookmarkDetail = resp.bookmark_detail
        this.like = resp.bookmark_detail.is_bookmarked
      }
    })
  }

  @Builder sheet(){
    Row(){
      List({space:6}){
        if (this.bookmarkDetail){
          ForEach(this.bookmarkDetail.tags, (tag:Tag)=>{
            ListItem(){
              Row(){
                Text(tag.name).fontSize(14)
                Checkbox().select(tag.is_registered)
              }.justifyContent(FlexAlign.SpaceBetween)
              .width('100%')
            }
          })
        }
      }.nestedScroll({
        // 可滚动组件往末尾端滚动时的嵌套滚动选项，手势向上
        scrollForward: NestedScrollMode.PARENT_FIRST,
        // 可滚动组件往起始端滚动时的嵌套滚动选项，手势向下
        scrollBackward: NestedScrollMode.SELF_FIRST,
      })
    }
  }

  setLimitBlur(){
    if (this.illust.sanity_level>=this.limitLevel) {
      this.filter.blur(20)
    }
  }

  @Builder overlayNode(){
    Row(){
      if (this.illust.type !== 'illust'){
        Text(`${this.illust.type}`).borderWidth(1).borderRadius(4).backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
      } else if (this.illust.meta_pages.length>1){
        Text(){
          SymbolSpan($r('sys.symbol.picture_2'))
          Span(`${this.illust.meta_pages.length}`)
        }.borderWidth(1).borderRadius(4)
        .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
      }
    }
  }

  build() {
    Column(){
      Stack(){
        Column(){
          HttpImage({
            url: this.illust.image_urls.large,aRatio:this.aRatio,
            br:{
              topLeft:$r('sys.float.ohos_id_card_border_radius'),
              topRight:$r('sys.float.ohos_id_card_border_radius')
            }
          })
        }.compositingFilter(this.filter)
        .borderRadius({
          topLeft:$r('sys.float.ohos_id_card_border_radius'),
          topRight:$r('sys.float.ohos_id_card_border_radius')
        })
        this.overlayNode()
      }.alignContent(Alignment.TopEnd)
      .borderRadius({topLeft:$r('sys.float.ohos_id_card_border_radius'),topRight:$r('sys.float.ohos_id_card_border_radius')})
      Row(){
        Column({space:6}){
          Text(this.illust.title).maxLines(1).fontSize(16).fontWeight(500)
          Text(this.illust.user.name).maxLines(1).fontSize(14).fontWeight(400)
        }.justifyContent(FlexAlign.SpaceAround)
        .padding({left:6})
        .alignItems(HorizontalAlign.Start)
        .layoutWeight(1)
        SymbolGlyph(this.like?$r('sys.symbol.heart_fill'):$r('sys.symbol.heart'))
          .fontColor(this.like?[Color.Red]:[Color.Gray])
          .bindSheet(this.showSheet,this.sheet(),{
            height:SheetSize.MEDIUM,
            blurStyle:BlurStyle.Thin,
            title:{title:'收藏详情'},
            shouldDismiss:()=>{
              this.showSheet = false
            }
          })
          .gesture(
            LongPressGesture({repeat:false,duration:1000}).onAction((event)=>{
              this.getBookmarkDetail()
              this.showSheet = true
            })
          )
          .onClick(()=>{
            if (this.like) {
              ApiClient.postUnLikeIllust(this.illust.id).then(res=>{
                this.like = false
                console.info('取消收藏成功', res)
              })
            }else {
              ApiClient.postLikeIllust( this.illust.id, 'public').then(res=>{
                this.like = true
                console.info('收藏成功', res)
              })
            }
          }).width(48)
      }.borderRadius({bottomLeft:$r('sys.float.ohos_id_card_border_radius'),bottomRight:$r('sys.float.ohos_id_card_border_radius')})
    }.borderRadius($r('sys.float.ohos_id_card_border_radius'))
    .backgroundColor(Color.Orange)
  }
}