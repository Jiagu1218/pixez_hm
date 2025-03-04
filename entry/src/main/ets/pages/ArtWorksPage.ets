import { ApiClient } from '../network/ApiClient'
import { Illust, MetaPage, Tag } from '../network/model/Illust'
import { BasicPrefetcher, LengthUnit, router } from '@kit.ArkUI'
import { HttpImage } from '../comp/HttpImage';
import { IllustDetailResponse } from '../network/response/IllustDetailResponse';
import { IllustRelatedResponse } from '../network/response/IllustRelatedResponse';
import { SaveImage } from '../comp/SaveImage';
import { DateTimeUtil } from '../network/util/DateTimeUtil';
import { UgoiraImage } from '../comp/UgoiraImage';
import { IllustRouterParam } from '../param/IllustRouterParam';
import { UserRouterParam } from '../param/UserRouterParam';
import { SearchRouterParam } from '../param/SearchRouterParam';
import { IllustSearchTargetEnum } from '../network/enums/IllustSearchTargetEnum';
import { IllustDataSourcePrefetching } from '../entity/IllustDataSourcePrefetching';
import { HtmlText } from '../comp/HtmlText';
import { CommentsResponse } from '../network/response/CommentsResponse';
import { CommentList } from '../comp/CommentList';
import { IllustSeriesNav } from '../comp/IllustSeriesNav';


@Entry
@ComponentV2
struct ArtWorksPage {
  private relatedIllusts: IllustDataSourcePrefetching = new IllustDataSourcePrefetching()
  private illustPrefetcher = new BasicPrefetcher(this.relatedIllusts)
  @Local illustId: number = 0
  @Local illust: Illust|null = null
  @Local nextUrl:string|null = null
  @Local followed: boolean = false
  @Local illustsRawUrl:Array<string> = []
  @Local showRaw:boolean = false
  @Local showComments:boolean = false
  @Local initIndex:number = 0
  @Local currentRawUrl:string = ''
  private pathStack:NavPathStack|undefined = undefined
  aboutToAppear(): void {
    this.relatedIllusts.getSession()
    this.pathStack = this.queryNavigationInfo()?.pathStack
    const params = router.getParams() as IllustRouterParam
    if (params?.illustId){
      this.illustId = params.illustId
    }
    if (this.queryNavigationInfo()?.pathStack) {
      this.pathStack = this.queryNavigationInfo()?.pathStack
      const temp = this.queryNavigationInfo()!.pathStack.getParamByName('artWorksPage').pop() as IllustRouterParam
      this.illustId = temp.illustId
    }
    ApiClient.getIllustDetail(this.illustId).then(res=>{
      const resp = res?.toJSON() as IllustDetailResponse
      this.illustId = resp.illust.id
      this.illust = resp.illust
      this.followed = resp.illust.user.is_followed
      this.illustsRawUrl = resp.illust.meta_single_page.original_image_url?[resp.illust.meta_single_page.original_image_url]:resp.illust.meta_pages.map(item=>item.image_urls.original)
    })
    ApiClient.getIllustRelated(this.illustId).then(res=>{
      const resp = res?.toJSON() as IllustRelatedResponse
      this.relatedIllusts.push(...resp.illusts)
      this.nextUrl = resp.next_url
    })
  }

  getComments():Promise<CommentsResponse|null>{
    return ApiClient.getIllustComments(this.illustId).then(res=>{
      if (res) {
        return res.toJSON() as CommentsResponse
      }else {
        return null
      }
    })
  }

  getCommentReply(commentId:number): Promise<CommentsResponse | null>{
    return ApiClient.getIllustCommentsReplies(commentId).then(res=>{
      if (res) {
        return res.toJSON() as CommentsResponse
      }else {
        return null
      }
    })
  }

  postComment(relateId: number, comment: string, parentCommentId?: number):Promise<boolean>{
    return ApiClient.postIllustComment(relateId,comment,parentCommentId).then(res=>{
      if (res) {
        return true
      }
      return false
    })
  }

  aboutToDisappear(): void {
    this.relatedIllusts.destroy()
  }

  @Builder showRowImage(){
    Row(){
      SaveImage({urls: this.illustsRawUrl,initIndex: this.initIndex})
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
      relateId:this.illustId,
      firstPage:()=>this.getComments(),
      getReply:(commentId)=>this.getCommentReply(commentId),
      postComment:(relateId,comment,parentCommentId)=>this.postComment(relateId,comment,parentCommentId)
    })
  }

  build() {
    NavDestination(){
      Scroll(){
        Column({space:16}){
          // 插画
          Column(){
            if (this.illust) {
              if (this.illust.meta_pages?.length>0) {
                ForEach(this.illust.meta_pages,(item:MetaPage,index)=>{
                  HttpImage({url: item.image_urls.large})
                    .onClick(()=>{
                      this.initIndex = index
                      this.currentRawUrl = item.image_urls.original
                      this.showRaw = true
                    })
                },(item:MetaPage,index)=>index.toString())
              }else {
                if (this.illust.type === 'ugoira'){
                  UgoiraImage({illust:this.illust})
                }else {
                  HttpImage({url: this.illust.image_urls.large})
                    .onClick(()=>{
                      this.currentRawUrl = this.illust!.meta_single_page!.original_image_url!
                      this.showRaw = true
                    })
                }

              }
            }
          }.width('100%')
          // 详细信息
          Column({space:16}){
            if (this.illust?.series){
              // 系列作品
              IllustSeriesNav({illustId:this.illust.id,seriesId:this.illust.series.id})
            }
            Column({space:16}){
              Text(this.illust?.title ?? '').fontSize($r('sys.float.Title_S'))
              Row({space:16}){
                Text(){
                  SymbolSpan($r('sys.symbol.eye')).fontColor([Color.Gray])
                  Span(this.illust?.total_view?.toString() ?? '0')
                }.fontSize(14)
                Text(){
                  SymbolSpan($r('sys.symbol.heart_fill')).fontColor([Color.Gray])
                  Span(this.illust?.total_bookmarks?.toString() ?? '0')
                }.fontSize(14)
                Text(){
                  SymbolSpan($r('sys.symbol.calendar_badge_clock')).fontColor([Color.Gray])
                  Span(this.illust?DateTimeUtil.parseIsoTimeToLocalFormatTime(this.illust.create_date) : '-')
                }.fontSize(14)
              }
              Row({space:16}){
                Text(`插画ID: ${this.illust?.id ?? '-'}`).fontSize(14)
                Text(`分辨率: ${this.illust?.width ?? '-'}x${this.illust?.height ?? '-'}`).fontSize(14)
              }
              Row(){
                Row({space:16}){
                  if (this.illust?.user?.profile_image_urls?.medium){
                    HttpImage({url: this.illust.user.profile_image_urls.medium,br:24}).width(48)
                  }
                  Text(this.illust?.user?.name ?? '').fontSize($r('sys.float.Subtitle_S')).fontWeight(FontWeight.Bold)
                }.onClick(()=>{
                  if(this.illust?.user.id){
                    this.pathStack?.pushPath({
                      name: 'userDetailPage',
                      param:{
                        userId: this.illust.user.id
                      } as UserRouterParam
                    })
                  }
                })
                Button(this.followed?'已关注':'关注').width(80)
                  .onClick(()=>{
                    if (!this.illust){
                      return
                    }
                    if (this.followed) {
                      ApiClient.postUnFollowUser(this.illust.user.id).then(()=>{
                        this.followed = false
                      })
                    }else {
                      ApiClient.postFollowUser(this.illust.user.id,'public').then(()=>{
                        this.followed = true
                      })
                    }
                  })
              }.justifyContent(FlexAlign.SpaceBetween)
              .width('100%')
            }.width('100%')
            .alignItems(HorizontalAlign.Start)
            if (this.illust?.tags){
              Row(){
                Flex({wrap:FlexWrap.Wrap,space:{main:{value: 16,unit:LengthUnit.VP},cross:{value: 8,unit:LengthUnit.VP}}}){
                  ForEach(this.illust.tags,(item:Tag)=>{
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
                      this.pathStack?.pushPath({
                        name: 'searchPage',
                        param: {
                          word: item.name,
                          type: 'illust',
                          target: IllustSearchTargetEnum.EXACT_MATCH_FOR_TAGS
                        } as SearchRouterParam
                      })
                    })
                  },(item:Tag,index)=>index.toString())
                }
              }
            }
            if (this.illust?.caption){
              Row(){
                HtmlText({htmlText:this.illust.caption})
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
                this.showComments = true
              })
            }.bindSheet(this.showComments,this.commentSheet(),{
              blurStyle:BlurStyle.Thin,
              title:{title:'相关评论'},
              shouldDismiss:()=>{
                this.showComments = false
              }
            })
            if (this.relatedIllusts){
              Column(){
                Grid(){
                  LazyForEach(this.relatedIllusts,(item:Illust)=>{
                    GridItem(){
                      Stack(){
                        HttpImage({url: item.image_urls.square_medium,aRatio:1})
                        this.overlayNode(item)
                      }.alignContent(Alignment.TopEnd)
                    }
                    .onClick(()=>{
                      this.pathStack?.pushPath({
                        name: 'artWorksPage',
                        param: {illustId:item.id} as IllustRouterParam
                      })
                    })
                  })
                }.columnsTemplate('repeat(auto-fit, 120)')
                .height('100%')
                .cachedCount(6)
                .onScrollIndex((first,last)=>{
                  this.illustPrefetcher.visibleAreaChanged(first,last)
                })
                //嵌套滚动控制
                .nestedScroll({
                  //滚动组件往末尾端滚动时的嵌套滚动选项
                  scrollForward:NestedScrollMode.PARENT_FIRST,
                  //滚动组件往起始端滚动时的嵌套滚动选项
                  scrollBackward:NestedScrollMode.SELF_FIRST
                })
                .onReachEnd(()=>{
                  if (this.nextUrl){
                    ApiClient.getNext(this.nextUrl).then(res=>{
                      const resp = res?.toJSON() as IllustRelatedResponse
                      this.relatedIllusts.push(...resp.illusts)
                      this.nextUrl = resp.next_url
                    })
                  }
                })
              }
            }
          }.width('100%')
        }.justifyContent(FlexAlign.Start)
        .bindContentCover(this.showRaw,this.showRowImage(),{
          onWillDismiss:()=>{
            this.showRaw = false
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