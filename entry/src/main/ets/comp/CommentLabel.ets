import { Comment } from "../network/model/Comment"
import { CommentsResponse } from "../network/response/CommentsResponse"
import { DateTimeUtil } from "../network/util/DateTimeUtil"
import { CommentList } from "./CommentList"
import { HttpImage } from "./HttpImage"

@ComponentV2
export struct CommentLabel{
  @Local private showSheet:boolean = false
  @Local private showReply:boolean = false
  @Local private replyText:string = ''
  //插画或小说id
  @Require @Param relateId:number
  @Require @Param comment:Comment
  @Require @Param getReply:(commentId:number)=> Promise<CommentsResponse |null>
  @Require @Param postComment:(relateId: number, comment: string,
    parentCommentId?: number)=> Promise<boolean>
  build() {
    Row({space:16}){
      HttpImage({url: this.comment.user.profile_image_urls.medium,aRatio:1,br:20}).width(40)
      Column({space:8}){
        Text(this.comment.user.name).fontSize(14).fontWeight(FontWeight.Bold)
        Row(){
          Text(this.comment.comment).fontSize(14)
          if (this.comment.stamp) {
            HttpImage({
              url: this.comment.stamp.stamp_url,aRatio:1,
              cacheInfo:{dir:'stamp',cacheType:'cache',filename:this.comment.stamp.stamp_id+'.png'}
            }).width(40)
          }
        }
        Row({space:32}){
          Text(DateTimeUtil.parseIsoTimeToLocalFormatTime(this.comment.date)).fontSize(12)
          Text('回复').fontSize(12).fontColor(Color.Blue)
            .bindSheet(this.showSheet!!, this.reply(),{
              title:{
                title:'回复'
              },
            })
        }
        if (this.comment.has_replies) {
          if (this.showReply) {
            CommentList({
              relateId:this.relateId,
              firstPage:()=>this.getReply(this.comment.id),
              getReply:(commentId:number)=>this.getReply(commentId),
              postComment:(relateId: number, comment: string,
                parentCommentId?: number)=>this.postComment(relateId,comment,parentCommentId)
            })
          }else {
            Button("查看回复").backgroundColor(Color.Gray)
              .onClick(()=> this.showReply = true)
          }
        }
      }.alignItems(HorizontalAlign.Start)
      .layoutWeight(1)
    }.alignItems(VerticalAlign.Top)
  }

  @Builder reply(){
    Column(){
      TextArea({placeholder:'请输入回复内容'}).width('100%')
        .onChange(e=>{
          this.replyText = e
        })
      Row(){
        Button('😊').type(ButtonType.Circle)
        Button("回复").backgroundColor(Color.Gray)
          .onClick(()=>{
            this.postComment(this.relateId,this.replyText,this.comment.id)
          })
      }
    }
  }
}