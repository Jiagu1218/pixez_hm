import { LengthUnit, router } from '@kit.ArkUI';
import { CommentList } from '../comp/CommentList';
import { HtmlText } from '../comp/HtmlText';
import { HttpImage } from '../comp/HttpImage';
import { ApiClient } from '../network/ApiClient';
import { NovelSearchTargetEnum } from '../network/enums/NovelSearchTargetEnum';
import { WebViewNovel } from '../network/model/WebViewNovel';
import { CommentsResponse } from '../network/response/CommentsResponse';
import { HtmlUtil } from '../network/util/HtmlUtil';
import { NovelRouterParam } from '../param/NovelRouterParam';
import { SearchRouterParam } from '../param/SearchRouterParam';

@Entry
@ComponentV2
struct NovelDetailPage {
  @Local private showComments: boolean = false;
  @Local private novelId: number = 0
  @Local private webViewNovel: WebViewNovel | null = null
  @Local private content:Array<string> = []
  private pathStack:NavPathStack|undefined = undefined
  private scroller: Scroller = new Scroller()

  aboutToAppear(): void {
    const params = router.getParams() as NovelRouterParam
    //uploadedimage 案例id：23617228 pixivimage 案例id：22354955
    if (params?.novelId) {
      this.novelId = params.novelId
    }
    if (this.queryNavigationInfo()?.pathStack) {
      this.pathStack = this.queryNavigationInfo()?.pathStack
      const temp = this.queryNavigationInfo()!.pathStack.getParamByName('novelDetailPage').pop() as NovelRouterParam
      this.novelId = temp.novelId
    }
    this.getWebViewNovel()
  }
  @Monitor('webViewNovel')
  dealWithText(){
    if (!this.webViewNovel) {
      this.content = [];
      return;
    }
    // TODO 处理富文本信息 [chapter:本章标题] [pixlvimage:作品1] [jump:链接目标的页面編号] [[jumpuri:标题 ＞ 链接目标的URL]]  [[rb:汉宇＞假名]]
    const illusts:Array<string> = []
    if (Array.isArray(this.webViewNovel.illusts) && Array.isArray(this.webViewNovel.images)) {
      illusts.push(this.webViewNovel.text);
    } else {
      const textParts = this.webViewNovel.text.split(/\[(uploadedimage:\d+(?:-\d+)?)\]|\[(pixivimage:\d+(?:-\d+)?)\]/g);
      illusts.push(...textParts.filter(Boolean));
    }
    this.content = illusts
  }

  getComments(): Promise<CommentsResponse | null> {
    return ApiClient.getNovelComments(this.novelId).then(res=>{
      if (res) {
        return res.toJSON() as CommentsResponse
      }else {
        return null
      }
    })
  }
  getCommentReply(commentId:number): Promise<CommentsResponse | null>{
    return ApiClient.getNovelCommentsReplies(commentId).then(res=>{
      if (res) {
        return res.toJSON() as CommentsResponse
      }else {
        return null
      }
    })
  }

  postComment(relateId: number, comment: string, parentCommentId?: number):Promise<boolean>{
    return ApiClient.postNovelComment(relateId,comment,parentCommentId).then(res=>{
      if (res) {
        return true
      }
      return false
    })
  }

  getWebViewNovel() {
    ApiClient.webviewNovel(this.novelId).then(res => {
      if (res) {
        if (res?.headers['content-type']?.match('text/html')) {
          const body = res.toString()
          const jsonStr = HtmlUtil.getNovelJson(body!)
          if (jsonStr) {
            const json = JSON.parse(jsonStr) as WebViewNovel
            this.webViewNovel = json
            this.scroller.scrollTo({ yOffset:0,xOffset:0,animation:true})
          }
        }
      }
    })
  }

  @Monitor('novelId')
  watchNovelId() {
    this.getWebViewNovel()
  }

  build() {
    NavDestination(){
      Scroll(this.scroller) {
        Column({space:16}) {
          if (this.webViewNovel) {
            Column() {
              HttpImage({ url: this.webViewNovel.coverUrl })
              Row(){
                Text(this.webViewNovel.title)
                  .fontSize(36)
                  .fontWeight(FontWeight.Bold)
                  .margin({ top: 10 })
              }.width('100%')
              Row(){
                Text(this.webViewNovel.cdate).fontSize(14)
              }.width('100%')
              Flex({ wrap: FlexWrap.Wrap, space: { main: { value: 8, unit: LengthUnit.VP } } }) {
                ForEach(this.webViewNovel.tags, (item: string, index) => {
                  Text(item).fontSize(14).borderColor(Color.Gray).borderWidth(1).borderRadius(4)
                    .onClick(()=>{
                      this.pathStack?.pushPath({
                        name: 'searchPage',
                        param: {
                          word: item,
                          type: 'novel',
                          target: NovelSearchTargetEnum.EXACT_MATCH_FOR_TAGS
                        } as SearchRouterParam
                      })
                    })
                })
              }
              Text('查看评论').fontColor(Color.Blue)
                .onClick(() => this.showComments = true)
            }
            Divider()
            if (this.webViewNovel.caption){
              Row(){
                HtmlText({htmlText:this.webViewNovel.caption})
              }.margin(16)
              .padding(8)
              .width('90%')
              .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
              .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
            }
            Column(){
              ForEach(this.content, (item: string, index) => {
                if (/pixivimage:(\d+(?:-\d+)?)/.test(item)) {
                  if (this.webViewNovel?.illusts[item.replace(/pixivimage:(\d+(?:-\d+)?)/,
                    '$1').toString()]?.illust?.images?.medium) {
                    HttpImage({
                      url: this.webViewNovel.illusts[item.replace(/pixivimage:(\d+(?:-\d+)?)/,
                        '$1').toString()].illust.images.medium
                    })
                  }
                } else if(/uploadedimage:(\d+(?:-\d+)?)/.test(item)) {
                  if (this.webViewNovel?.images[item.replace(/uploadedimage:(\d+(?:-\d+)?)/,
                    '$1').toString()]?.urls?.original) {
                    HttpImage({
                      url: this.webViewNovel.images[item.replace(/uploadedimage:(\d+(?:-\d+)?)/,
                        '$1').toString()].urls.original
                    })
                  }
                }else {
                  Text(item)
                }
              })
            }
            if (this.webViewNovel.seriesNavigation){
              Divider()
              Row() {
                Text() {
                  SymbolSpan($r('sys.symbol.arrow_left'))
                  Span(' ')
                  Span(this.webViewNovel.seriesNavigation.prevNovel?.title ?? '')
                }.maxLines(2)
                .width('40%')
                .visibility(this.webViewNovel.seriesNavigation.prevNovel ? Visibility.Visible : Visibility.Hidden)
                .onClick(() => {
                  if (this.webViewNovel!.seriesNavigation?.prevNovel) {
                    this.novelId = this.webViewNovel!.seriesNavigation.prevNovel.id
                  }
                })

                Text() {
                  Span(this.webViewNovel.seriesNavigation.nextNovel?.title ?? '')
                  Span(' ')
                  SymbolSpan($r('sys.symbol.arrow_right'))
                }.maxLines(2)
                .width('40%')
                .visibility(this.webViewNovel.seriesNavigation.nextNovel ? Visibility.Visible : Visibility.Hidden)
                .onClick(() => {
                  if (this.webViewNovel!.seriesNavigation?.nextNovel) {
                    this.novelId = this.webViewNovel!.seriesNavigation.nextNovel.id
                  }
                })
              }.width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
            }
          }
        }.width('100%')
      }
      .height('100%')
      .width('100%')
      .bindSheet(this.showComments,this.commentSheet(),{
        blurStyle:BlurStyle.Thin,
        title:{title:'相关评论'},
        shouldDismiss:()=>{
          this.showComments = false
        }
      })
    }
    .hideTitleBar(true)
  }

  @Builder commentSheet(): CustomBuilder {
    CommentList({
      relateId: this.novelId,
      firstPage: () => this.getComments(),
      getReply: (commentId: number) => this.getCommentReply(commentId),
      postComment: (relateId: number, comment: string, parentCommentId?: number) =>
        this.postComment(relateId, comment, parentCommentId)
    })
  }

}

@Builder export function NovelDetailPageBuilder(){
  NovelDetailPage()
}
