import { LengthUnit } from '@kit.ArkUI';

import { NovelContentPart } from '../entity/NovelContent';
import { getNovelContentParts } from '../util/NovelUtil';
import { NovelDetailViewModel } from '../viewmodel/NovelDetailViewModel';
import TextReader from '@hms.ai.textReader';
import { BusinessError } from '@kit.BasicServicesKit';
import { CommentList, DownloadUtil, HtmlText, HttpImage } from 'common';

@Entry
@ComponentV2
struct NovelDetailPage {
  @Local private model: NovelDetailViewModel = new NovelDetailViewModel()

  @Local readerState:boolean = false
  @Local readInfos:TextReader.ReadInfo[] = []

  initReader(){
		const param:TextReader.ReaderParam = {
      isVoiceBrandVisible:true,
      businessBrandInfo: {
        panelName: '小艺朗读',
        panelIcon: $r('app.media.app_icon')
      }
    }
    TextReader.init(getContext(this),param)
      .catch((e:BusinessError) => {
      console.error(e.message)
    })
	}

  async startReader(){
    // 提取文本组装为 readInfo
    const novel = this.model.webViewNovel
    let pic = await DownloadUtil.downloadImage(novel!.coverUrl)
    let readInfo:TextReader.ReadInfo = {
      id: this.model.novelId.toString(),
      title: {
        text:novel!.title,
        isClickable : true
      },
      date:{text:novel!.cdate,isClickable:false},
      image:pic,
      bodyInfo: ''
    }
    this.model.content.forEach(e=>{
      if (e.type == 'text') {
        readInfo.bodyInfo += e.content
      }
    })
    this.readInfos = [readInfo]
    TextReader.start(this.readInfos).then(()=>{
      this.readerState = true
    }).catch((e:BusinessError) => {
      console.error(e.message)
    })
  }

  stopReader(){
    TextReader.stop().then(()=>{
      this.readerState = false
    }).catch((e:BusinessError) => {
      console.error(e.message)
    })
  }

  aboutToAppear(): void {
    this.model.init(this.queryNavigationInfo())
    this.initReader()
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
        HttpImage({ url: this.model.webViewNovel.coverUrl, br: 14 })
          .width('100%')
          .height(200)
          .shadow({
            radius: 12,
            color: '#00000014',
            offsetX: 0,
            offsetY: 4
          })
        Row() {
          Text(this.model.webViewNovel.title)
            .fontSize(24)
            .fontWeight(FontWeight.Bold)
            .fontColor('#1E293B')
            .lineHeight(32)
            .margin({ top: 16 })
        }.width('100%')
        Row() {
          Text(this.model.webViewNovel.cdate)
            .fontSize(14)
            .fontColor('#64748B')
        }.width('100%')
        Flex({ wrap: FlexWrap.Wrap, space: { main: { value: 8, unit: LengthUnit.VP } } }) {
          ForEach(this.model.webViewNovel.tags, (item: string) => {
            Text(item)
              .fontSize(13)
              .fontColor('#475569')
              .padding({ left: 10, right: 10, top: 6, bottom: 6 })
              .backgroundColor('#F1F5F9')
              .borderRadius(10)
              .onClick(() => {
                this.model.tagAction(item)
              })
          }, (item: string,index)=>index + item)
        }
        Text('查看评论')
          .fontSize(16)
          .fontWeight(FontWeight.Medium)
          .fontColor('#2563EB')
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
      .border({
        width: 1,
        color: '#EEF2F6'
      })
      .shadow({
        radius: 12,
        color: '#00000012',
        offsetX: 0,
        offsetY: 4
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
        .fontColor('#2563EB')
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
        .fontColor('#2563EB')
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
      Stack({alignContent:Alignment.BottomEnd}){
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

        SymbolGlyph(this.readerState?$r('sys.symbol.pause_round_triangle_fill'):$r('sys.symbol.play_circle_fill'))
          .onClick(() => {
            if (this.readerState) {
              this.stopReader()
            } else {
              this.startReader()
            }
          })
          .fontSize(44)
          .fontColor(['#2563EB'])
          .width(52)
          .height(52)
          .offset({ x: -28, y: -28 })
          .backgroundColor('#FFFFFFEE')
          .borderRadius(26)
          .shadow({
            radius: 12,
            color: '#2563EB33',
            offsetX: 0,
            offsetY: 4
          })
      }
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
