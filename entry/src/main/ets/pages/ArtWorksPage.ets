import { Illust, MetaPage, Tag } from '../network/model/Illust'
import { LengthUnit } from '@kit.ArkUI'
import { HttpImage } from '../comp/HttpImage';
import { SaveImage } from '../comp/SaveImage';
import { DateTimeUtil } from '../network/util/DateTimeUtil';
import { UgoiraImage } from '../comp/UgoiraImage';
import { HtmlText } from '../comp/HtmlText';
import { CommentList } from '../comp/CommentList';
import { IllustSeriesNav } from '../comp/IllustSeriesNav';
import { ArtWorksViewModel } from '../viewmodel/ArtWorksViewModel';

@Entry
@ComponentV2
struct ArtWorksPage {
  private model:ArtWorksViewModel = new ArtWorksViewModel()
  aboutToAppear(): void {
    this.model.init(this.queryNavigationInfo())
  }

  aboutToDisappear(): void {
    this.model.destroy()
  }

  @Builder showRowImage(){
    Row(){
      SaveImage({urls: this.model.illustsRawUrl,initIndex: this.model.initIndex})
    }
    .width('100%')
    .height('100%')
  }

  @Builder overlayNode(illust: Illust){
    Row(){
      if (illust.type !== 'illust'){
        Text(`${illust.type}`).borderWidth(1).borderRadius(4).backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
      } else if (illust.meta_pages.length>1){
        Text(){
          SymbolSpan($r('sys.symbol.picture_2'))
          Span(`${illust.meta_pages.length}`)
        }.borderWidth(1).borderRadius(4)
        .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
      }
    }
  }

  @Builder commentSheet(){
    CommentList({
      relateId:this.model.illustId,
      firstPage:()=>this.model.getComments(),
      getReply:(commentId)=>this.model.getCommentReply(commentId),
      postComment:(relateId,comment,parentCommentId)=>this.model.postComment(relateId,comment,parentCommentId)
    })
  }

  build() {
    NavDestination(){
      Scroll(){
        Column({space:16}){
          // 插画
          Column(){
            if (this.model.illust) {
              if (this.model.illust.meta_pages?.length>0) {
                ForEach(this.model.illust.meta_pages,(item:MetaPage,index)=>{
                  HttpImage({url: item.image_urls.large})
                    .onClick(()=>{
                      this.model.initIndex = index
                      this.model.currentRawUrl = item.image_urls.original
                      this.model.showRaw = true
                    })
                },(item:MetaPage,index)=>index.toString())
              }else {
                if (this.model.illust.type === 'ugoira'){
                  UgoiraImage({illust:this.model.illust})
                }else {
                  HttpImage({url: this.model.illust.image_urls.large})
                    .onClick(()=>{
                      this.model.currentRawUrl = this.model.illust!.meta_single_page!.original_image_url!
                      this.model.showRaw = true
                    })
                }

              }
            }
          }.width('100%')
          // 详细信息
          Column({space:16}){
            if (this.model.illust?.series){
              // 系列作品
              IllustSeriesNav({illustId:this.model.illust.id,seriesId:this.model.illust.series.id})
            }
            Column({space:16}){
              Text(this.model.illust?.title ?? '').fontSize($r('sys.float.Title_S'))
              Row({space:16}){
                Text(){
                  SymbolSpan($r('sys.symbol.eye')).fontColor([Color.Gray])
                  Span(this.model.illust?.total_view?.toString() ?? '0')
                }.fontSize(14)
                Text(){
                  SymbolSpan($r('sys.symbol.heart_fill')).fontColor([Color.Gray])
                  Span(this.model.illust?.total_bookmarks?.toString() ?? '0')
                }.fontSize(14)
                Text(){
                  SymbolSpan($r('sys.symbol.calendar_badge_clock')).fontColor([Color.Gray])
                  Span(this.model.illust?DateTimeUtil.parseIsoTimeToLocalFormatTime(this.model.illust.create_date) : '-')
                }.fontSize(14)
              }
              Row({space:16}){
                Text(`插画ID: ${this.model.illust?.id ?? '-'}`).fontSize(14)
                Text(`分辨率: ${this.model.illust?.width ?? '-'}x${this.model.illust?.height ?? '-'}`).fontSize(14)
              }
              Row(){
                Row({space:16}){
                  if (this.model.illust?.user?.profile_image_urls?.medium){
                    HttpImage({url: this.model.illust.user.profile_image_urls.medium,br:24}).width(48)
                  }
                  Text(this.model.illust?.user?.name ?? '').fontSize($r('sys.float.Subtitle_S')).fontWeight(FontWeight.Bold)
                }.onClick(()=>{
                  this.model.userDetailAction()
                })
                Button(this.model.followed?'已关注':'关注').width(80)
                  .onClick(()=>{
                    this.model.followAction()
                  })
              }.justifyContent(FlexAlign.SpaceBetween)
              .width('100%')
            }.width('100%')
            .alignItems(HorizontalAlign.Start)
            if (this.model.illust?.tags){
              Row(){
                Flex({wrap:FlexWrap.Wrap,space:{main:{value: 16,unit:LengthUnit.VP},cross:{value: 8,unit:LengthUnit.VP}}}){
                  ForEach(this.model.illust.tags,(item:Tag)=>{
                    Text(){
                      Span(`#${item.name}`).fontColor(Color.Blue)
                      if (item.translated_name){
                        Span(`  (${item.translated_name})`)
                      }
                    }.fontSize(14)
                    .padding(8)
                    // .backgroundColor(Color.Gray)
                    .borderRadius($r('sys.float.ohos_id_corner_radius_panel'))
                    .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
                    .onClick(()=>{
                      this.model.tagAction(item)
                    })
                  },(item:Tag,index)=>index.toString())
                }
              }
            }
            if (this.model.illust?.caption){
              Row(){
                HtmlText({htmlText:this.model.illust.caption})
              }.margin(16)
              .padding(8)
              .width('90%')
              .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
              .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
            }
            Row(){
              Text(){
                SymbolSpan($r('sys.symbol.topic_message_fill')).fontColor([Color.Gray])
                Span("查看评论")
              }.fontColor(Color.Blue)
              .onClick(()=>{
                this.model.showComments = true
              })
            }.bindSheet(this.model.showComments,this.commentSheet(),{
              blurStyle:BlurStyle.Thin,
              title:{title:'相关评论'},
              shouldDismiss:()=>{
                this.model.showComments = false
              }
            })
            if (this.model.relatedIllusts){
              Column(){
                Grid(){
                  LazyForEach(this.model.relatedIllusts,(item:Illust)=>{
                    GridItem(){
                      Stack(){
                        HttpImage({url: item.image_urls.square_medium,aRatio:1})
                        this.overlayNode(item)
                      }.alignContent(Alignment.TopEnd)
                    }
                    .onClick(()=>{
                      this.model.relatedAction(item)
                    })
                  })
                }.columnsTemplate('repeat(auto-fit, 120)')
                .height('100%')
                .cachedCount(6)
                .onScrollIndex((first,last)=>{
                  this.model.illustPrefetcher.visibleAreaChanged(first,last)
                })
                //嵌套滚动控制
                .nestedScroll({
                  //滚动组件往末尾端滚动时的嵌套滚动选项
                  scrollForward:NestedScrollMode.PARENT_FIRST,
                  //滚动组件往起始端滚动时的嵌套滚动选项
                  scrollBackward:NestedScrollMode.SELF_FIRST
                })
                .onReachEnd(()=>{
                  this.model.relatedPageAction()
                })
              }
            }
          }.width('100%')
        }.justifyContent(FlexAlign.Start)
        .bindContentCover(this.model.showRaw,this.showRowImage(),{
          onWillDismiss:()=>{
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

@Builder export function ArtWorksPageBuilder(){
  ArtWorksPage()
}