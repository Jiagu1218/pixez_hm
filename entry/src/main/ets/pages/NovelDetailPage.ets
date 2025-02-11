import { LengthUnit } from '@kit.ArkUI';
import { CommentList } from '../comp/CommentList';
import { HtmlText } from '../comp/HtmlText';
import { HttpImage } from '../comp/HttpImage';
import { NovelDetailViewModel } from '../viewmodel/NovelDetailViewModel';

@Entry
@ComponentV2
struct NovelDetailPage {
  @Local private model: NovelDetailViewModel = new NovelDetailViewModel()

  aboutToAppear(): void {
    this.model.init(this.queryNavigationInfo())
  }
  @Monitor('model.webViewNovel')
  dealWithText(){
    if (!this.model.webViewNovel) {
      this.model.content = [];
      return;
    }
    // TODO 处理富文本信息 [chapter:本章标题] [pixlvimage:作品1] [jump:链接目标的页面編号] [[jumpuri:标题 ＞ 链接目标的URL]]  [[rb:汉宇＞假名]]
    const illusts:Array<string> = []
    if (Array.isArray(this.model.webViewNovel.illusts) && Array.isArray(this.model.webViewNovel.images)) {
      illusts.push(this.model.webViewNovel.text);
    } else {
      const textParts = this.model.webViewNovel.text.split(/\[(uploadedimage:\d+(?:-\d+)?)\]|\[(pixivimage:\d+(?:-\d+)?)\]/g);
      illusts.push(...textParts.filter(Boolean));
    }
    this.model.content = illusts
  }

  @Monitor('model.novelId')
  watchNovelId() {
    this.model.getWebViewNovel()
  }

  build() {
    NavDestination(){
      Scroll(this.model.scroller) {
        Column({space:16}) {
          if (this.model.webViewNovel) {
            Column() {
              HttpImage({ url: this.model.webViewNovel.coverUrl })
              Row(){
                Text(this.model.webViewNovel.title)
                  .fontSize(36)
                  .fontWeight(FontWeight.Bold)
                  .margin({ top: 10 })
              }.width('100%')
              Row(){
                Text(this.model.webViewNovel.cdate).fontSize(14)
              }.width('100%')
              Flex({ wrap: FlexWrap.Wrap, space: { main: { value: 8, unit: LengthUnit.VP } } }) {
                ForEach(this.model.webViewNovel.tags, (item: string, index) => {
                  Text(item).fontSize(14).borderColor(Color.Gray).borderWidth(1).borderRadius(4)
                    .onClick(()=>{
                      this.model.tagAction(item)
                    })
                })
              }
              Text('查看评论').fontColor(Color.Blue)
                .onClick(() => this.model.showComments = true)
            }
            Divider()
            if (this.model.webViewNovel.caption){
              Row(){
                HtmlText({htmlText:this.model.webViewNovel.caption})
              }.margin(16)
              .padding(8)
              .width('90%')
              .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
              .borderRadius($r('sys.float.ohos_id_corner_radius_card'))
            }
            Column(){
              ForEach(this.model.content, (item: string, index) => {
                if (/pixivimage:(\d+(?:-\d+)?)/.test(item)) {
                  if (this.model.webViewNovel?.illusts[item.replace(/pixivimage:(\d+(?:-\d+)?)/,
                    '$1').toString()]?.illust?.images?.medium) {
                    HttpImage({
                      url: this.model.webViewNovel.illusts[item.replace(/pixivimage:(\d+(?:-\d+)?)/,
                        '$1').toString()].illust.images.medium
                    })
                  }
                } else if(/uploadedimage:(\d+(?:-\d+)?)/.test(item)) {
                  if (this.model.webViewNovel?.images[item.replace(/uploadedimage:(\d+(?:-\d+)?)/,
                    '$1').toString()]?.urls?.original) {
                    HttpImage({
                      url: this.model.webViewNovel.images[item.replace(/uploadedimage:(\d+(?:-\d+)?)/,
                        '$1').toString()].urls.original
                    })
                  }
                }else {
                  Text(item)
                }
              })
            }
            if (this.model.webViewNovel.seriesNavigation){
              Divider()
              Row() {
                Text() {
                  SymbolSpan($r('sys.symbol.arrow_left'))
                  Span(' ')
                  Span(this.model.webViewNovel.seriesNavigation.prevNovel?.title ?? '')
                }.maxLines(2)
                .width('40%')
                .visibility(this.model.webViewNovel.seriesNavigation.prevNovel ? Visibility.Visible : Visibility.Hidden)
                .onClick(() => {
                  this.model.prevNovelAction()
                })

                Text() {
                  Span(this.model.webViewNovel.seriesNavigation.nextNovel?.title ?? '')
                  Span(' ')
                  SymbolSpan($r('sys.symbol.arrow_right'))
                }.maxLines(2)
                .width('40%')
                .visibility(this.model.webViewNovel.seriesNavigation.nextNovel ? Visibility.Visible : Visibility.Hidden)
                .onClick(() => {
                  this.model.nextNovelAction()
                })
              }.width('100%')
              .justifyContent(FlexAlign.SpaceBetween)
            }
          }
        }.width('100%')
      }
      .height('100%')
      .width('100%')
      .bindSheet(this.model.showComments!!,this.commentSheet(),{
        blurStyle:BlurStyle.Thin,
        title:{title:'相关评论'},
        shouldDismiss:()=>{
          this.model.showComments = false
        }
      })
    }
    .hideTitleBar(true)
  }

  @Builder commentSheet(): CustomBuilder {
    CommentList({
      relateId: this.model.novelId,
      firstPage: () => this.model.getComments(),
      getReply: (commentId: number) => this.model.getCommentReply(commentId),
      postComment: (relateId: number, comment: string, parentCommentId?: number) =>
      this.model.postComment(relateId, comment, parentCommentId)
    })
  }

}

@Builder export function NovelDetailPageBuilder(){
  NovelDetailPage()
}
