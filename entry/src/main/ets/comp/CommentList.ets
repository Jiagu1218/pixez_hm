import { LazyDataSource } from "../entity/LazyDataSource"
import { ApiClient } from "../network/ApiClient"
import { Comment } from "../network/model/Comment"
import { CommentsResponse } from "../network/response/CommentsResponse"
import { DateTimeUtil } from "../network/util/DateTimeUtil"
import { Comments } from "./Comment"
import { HttpImage } from "./HttpImage"

@ComponentV2
export struct CommentList{
  private comments:LazyDataSource<Comment> = new LazyDataSource<Comment>()
  private nextUrl:string|null = null
  @Require @Param firstPage:()=> Promise<CommentsResponse |null>
  @Require @Param getReply:(commentId:number)=> Promise<CommentsResponse |null>

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
          Comments({comment:item,getReply:()=>this.getReply(item.id)})
        }
      })
    }.constraintSize({
      maxHeight:'100%'
    })
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