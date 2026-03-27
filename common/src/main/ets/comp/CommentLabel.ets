import { Comment, CommentsResponse, DateTimeUtil } from "pixez_network"
import { CommentList } from "./CommentList"
import { HttpImage } from "./HttpImage"

@ReusableV2
@ComponentV2
export struct CommentLabel {
  @Local private showSheet: boolean = false
  @Local private showReply: boolean = false
  @Local private replyText: string = ''
  @Local private isHovered: boolean = false
  //插画或小说id
  @Require @Param relateId: number
  @Require @Param comment: Comment
  @Require @Param getReply: (commentId: number) => Promise<CommentsResponse | null>
  @Require @Param postComment: (relateId: number, comment: string,
    parentCommentId?: number) => Promise<boolean>

  private hasValidStamp(): boolean {
    const stamp = this.comment.stamp
    if (stamp === undefined || stamp === null) {
      return false
    }
    const url = stamp.stamp_url
    if (url === undefined || url === null || url.length === 0) {
      return false
    }
    return true
  }

  private stampUrlForRender(): string {
    const stamp = this.comment.stamp
    if (stamp === undefined || stamp === null) {
      return ''
    }
    return stamp.stamp_url
  }

  private stampIdForRender(): number {
    const stamp = this.comment.stamp
    if (stamp === undefined || stamp === null) {
      return 0
    }
    return stamp.stamp_id
  }

  build() {
    Row({ space: 16 }) {
      HttpImage({
        url: this.comment.user.profile_image_urls.medium,
        aRatio: 1,
        br: 20
      })
        .width(40)
        .height(40)

      Column({ space: 8 }) {
        Text(this.comment.user.name)
          .fontSize(15)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1F2937')

        Row({ space: 8 }) {
          Text(this.comment.comment)
            .fontSize(14)
            .lineHeight(22)
            .fontColor('#374151')
            .layoutWeight(1)
          if (this.hasValidStamp()) {
            HttpImage({
              url: this.stampUrlForRender(),
              aRatio: 1,
              cacheInfo: {
                dir: 'stamp',
                cacheType: 'cache',
                filename: this.stampIdForRender() + '.png'
              }
            })
              .width(40)
              .height(40)
          }
        }

        Row({ space: 32 }) {
          Text(DateTimeUtil.parseIsoTimeToLocalFormatTime(this.comment.date))
            .fontSize(12)
            .fontColor('#94A3B8')

          Text('回复')
            .fontSize(12)
            .fontColor('#2563EB')
            .fontWeight(FontWeight.Medium)
            .bindSheet(this.showSheet!!, this.reply(), {
              title: {
                title: '回复'
              },
              blurStyle: BlurStyle.Thin
            })
        }

        if (this.comment.has_replies) {
          if (this.showReply) {
            CommentList({
              relateId: this.relateId,
              firstPage: () => this.getReply(this.comment.id),
              getReply: (commentId: number) => this.getReply(commentId),
              postComment: (relateId: number, comment: string,
                parentCommentId?: number) => this.postComment(relateId, comment, parentCommentId)
            })
          } else {
            Button("查看回复")
              .backgroundColor('#EEF2FF')
              .fontColor('#374151')
              .fontSize(12)
              .fontWeight(FontWeight.Medium)
              .borderRadius(10)
              .padding({ left: 10, right: 10, top: 4, bottom: 4 })
              .onClick(() => this.showReply = true)
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .alignItems(VerticalAlign.Top)
    .padding({ left: 16, right: 16, top: 14, bottom: 14 })
    .backgroundColor(this.isHovered ? '#F8FAFF' : '#FFFFFF')
    .borderRadius(12)
    .border({
      width: 1,
      color: this.isHovered ? '#DBEAFE' : '#EEF2F6'
    })
    .shadow({
      radius: this.isHovered ? 12 : 8,
      color: this.isHovered ? '#2563EB18' : '#00000008',
      offsetX: 0,
      offsetY: this.isHovered ? 6 : 3
    })
    .transition({
      type: TransitionType.All
    })
    .onHover((isHovered: boolean) => {
      this.isHovered = isHovered
    })
  }

  @Builder reply() {
    Column({ space: 16 }) {
      TextArea({ placeholder: '请输入回复内容' })
        .width('100%')
        .height(100)
        .fontSize(14)
        .backgroundColor('#F8FAFC')
        .borderRadius(10)
        .padding(10)
        .onChange(e => {
          this.replyText = e
        })

      Row({ space: 16 }) {
        Button('😊')
          .type(ButtonType.Circle)
          .backgroundColor('#F1F5F9')
          .width(40)
          .height(40)

        Button("回复")
          .backgroundColor('#2563EB')
          .fontColor(Color.White)
          .fontSize(14)
          .fontWeight(FontWeight.Medium)
          .borderRadius(10)
          .padding({ left: 18, right: 18, top: 8, bottom: 8 })
          .onClick(() => {
            if (this.replyText.trim()) {
              this.postComment(this.relateId, this.replyText, this.comment.id)
                .then(() => {
                  this.showSheet = false
                  this.replyText = ''
                })
            }
          })
      }
      .justifyContent(FlexAlign.End)
    }
    .width('100%')
    .padding(16)
  }
}