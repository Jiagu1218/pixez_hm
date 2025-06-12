import { Comment } from "../network/model/Comment"
import { CommentsResponse } from "../network/response/CommentsResponse"
import { DateTimeUtil } from "../network/util/DateTimeUtil"
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
          .fontSize(14)
          .fontWeight(FontWeight.Bold)
          .fontColor('#333333')

        Row() {
          Text(this.comment.comment)
            .fontSize(14)
            .fontColor('#666666')
          if (this.comment.stamp) {
            HttpImage({
              url: this.comment.stamp.stamp_url,
              aRatio: 1,
              cacheInfo: {
                dir: 'stamp',
                cacheType: 'cache',
                filename: this.comment.stamp.stamp_id + '.png'
              }
            })
              .width(40)
              .height(40)
          }
        }

        Row({ space: 32 }) {
          Text(DateTimeUtil.parseIsoTimeToLocalFormatTime(this.comment.date))
            .fontSize(12)
            .fontColor('#999999')

          Text('回复')
            .fontSize(12)
            .fontColor('#2196F3')
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
              .backgroundColor('#F5F5F5')
              .fontColor('#666666')
              .fontSize(12)
              .borderRadius(4)
              .padding({ left: 8, right: 8, top: 4, bottom: 4 })
              .onClick(() => this.showReply = true)
          }
        }
      }
      .alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }
    .alignItems(VerticalAlign.Top)
    .padding({ left: 16, right: 16, top: 12, bottom: 12 })
    .backgroundColor('#FFFFFF')
    .borderRadius(8)
    .shadow({
      radius: 4,
      color: '#00000005',
      offsetX: 0,
      offsetY: 2
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
        .backgroundColor('#F5F5F5')
        .borderRadius(8)
        .padding(8)
        .onChange(e => {
          this.replyText = e
        })

      Row({ space: 16 }) {
        Button('😊')
          .type(ButtonType.Circle)
          .backgroundColor('#F5F5F5')
          .width(40)
          .height(40)

        Button("回复")
          .backgroundColor('#2196F3')
          .fontColor('#FFFFFF')
          .fontSize(14)
          .borderRadius(4)
          .padding({ left: 16, right: 16, top: 8, bottom: 8 })
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