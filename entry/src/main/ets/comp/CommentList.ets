import { LazyDataSource } from "../entity/LazyDataSource"
import { ApiClient } from "../network/ApiClient"
import { Comment } from "../network/model/Comment"
import { CommentsResponse } from "../network/response/CommentsResponse"
import { CommentLabel } from "./CommentLabel"

@ComponentV2
export struct CommentList{
  private comments:LazyDataSource<Comment> = new LazyDataSource<Comment>()
  private nextUrl:string|null = null
  //插画或小说id
  @Require @Param relateId:number
  @Require @Param firstPage:()=> Promise<CommentsResponse |null>
  @Require @Param getReply:(commentId:number)=> Promise<CommentsResponse |null>
  @Require @Param postComment:(relateId: number, comment: string,
    parentCommentId?: number)=> Promise<boolean>

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
          CommentLabel({relateId:this.relateId,comment:item,getReply:()=>this.getReply(item.id),
            postComment:(relateId: number, comment: string, parentCommentId?: number)=>this.postComment(relateId,comment,parentCommentId)})
        }
      })
    }.constraintSize({
      maxHeight:'100%'
    })
    //嵌套滚动控制
    .nestedScroll({
      //滚动组件往末尾端滚动时的嵌套滚动选项
      scrollForward:NestedScrollMode.PARENT_FIRST,
      //滚动组件往起始端滚动时的嵌套滚动选项
      scrollBackward:NestedScrollMode.SELF_FIRST
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