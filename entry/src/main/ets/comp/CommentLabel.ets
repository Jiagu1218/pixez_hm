import { Comment } from "../network/model/Comment"
import { CommentsResponse } from "../network/response/CommentsResponse"
import { DateTimeUtil } from "../network/util/DateTimeUtil"
import { CommentList } from "./CommentList"
import { HttpImage } from "./HttpImage"

@ComponentV2
export struct CommentLabel{
  @Local private showReply:boolean = false
  @Require @Param comment:Comment
  @Require @Param getReply:(commentId:number)=> Promise<CommentsResponse |null>
  build() {
    Row({space:16}){
      HttpImage({url: this.comment.user.profile_image_urls.medium,aRatio:1,br:20}).width(40)
      Column({space:8}){
        Text(this.comment.user.name).fontSize(14).fontWeight(FontWeight.Bold)
        Row(){
          Text(this.comment.comment).fontSize(14)
          if (this.comment.stamp) {
            HttpImage({url: this.comment.stamp.stamp_url,aRatio:1}).width(40)
          }
        }
        Row({space:32}){
          Text(DateTimeUtil.parseIsoTimeToLocalFormatTime(this.comment.date)).fontSize(12)
          Text("回复").fontSize(12).fontColor(Color.Blue)
        }
        if (this.comment.has_replies) {
          if (this.showReply) {
            CommentList({
              firstPage:()=>this.getReply(this.comment.id),
              getReply:(commentId:number)=>this.getReply(commentId)
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
}