import { LazyDataSource } from "../entity/LazyDataSource"
import { ApiClient } from "../network/ApiClient"
import { Comment } from "../network/model/Comment"
import { CommentsResponse } from "../network/response/CommentsResponse"
import { DateTimeUtil } from "../network/util/DateTimeUtil"
import { HttpImage } from "./HttpImage"

@ComponentV2
export struct CommentList{
  private comments:LazyDataSource<Comment> = new LazyDataSource<Comment>()
  private nextUrl:string|null = null
  @Require @Param firstPage:()=> Promise<CommentsResponse |null>

  aboutToAppear(): void {
    this.firstPage().then(res=>{
      if (res) {
        this.comments.push(...res.comments)
        this.nextUrl = res.next_url
      }
    })
  }

  build() {
    List({space:16}){
      LazyForEach(this.comments,(item:Comment)=>{
        ListItem(){
          Row({space:16}){
            HttpImage({url: item.user.profile_image_urls.medium,aRatio:1,br:20}).width(40)
            Column({space:8}){
              Text(item.user.name).fontSize(14).fontWeight(FontWeight.Bold)
              Row(){
                Text(item.comment).fontSize(14)
                if (item.stamp) {
                  HttpImage({url: item.stamp.stamp_url,aRatio:1}).width(40)
                }
              }
              Row({space:32}){
                Text(DateTimeUtil.parseIsoTimeToLocalFormatTime(item.date)).fontSize(12)
                Text("回复").fontSize(12).fontColor(Color.Blue)
              }
            }.alignItems(HorizontalAlign.Start)
            .layoutWeight(1)
          }.alignItems(VerticalAlign.Top)
        }
      })
    }.height('100%')
    .divider({
      strokeWidth:1
    })
    .onReachEnd(()=>{
      if (this.nextUrl){
        ApiClient.getNext(this.nextUrl).then(res=>{
          const resp = res?.toJSON() as CommentsResponse
          this.comments.push(...resp.comments)
          this.nextUrl = resp.next_url
        })
      }
    })
  }
}