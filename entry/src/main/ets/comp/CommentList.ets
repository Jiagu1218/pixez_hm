import { LazyDataSource } from "../entity/LazyDataSource"
import { ApiClient } from "../network/ApiClient"
import { Comment } from "../network/model/Comment"
import { CommentsResponse } from "../network/response/CommentsResponse"
import { CommentLabel } from "./CommentLabel"

@ComponentV2
export struct CommentList {
  private comments: LazyDataSource<Comment> = new LazyDataSource<Comment>()
  private nextUrl: string | null = null
  @Local private isLoading: boolean = false
  @Local private hasMore: boolean = true
  //插画或小说id
  @Require @Param relateId: number
  @Require @Param firstPage: () => Promise<CommentsResponse | null>
  @Require @Param getReply: (commentId: number) => Promise<CommentsResponse | null>
  @Require @Param postComment: (relateId: number, comment: string,
    parentCommentId?: number) => Promise<boolean>

  aboutToAppear(): void {
    this.loadFirstPage()
  }

  private loadFirstPage(): void {
    this.isLoading = true
    this.firstPage()
      .then(res => {
        if (res) {
          this.comments.push(...res.comments)
          this.nextUrl = res.next_url
          this.hasMore = !!res.next_url
        }
      })
      .finally(() => {
        this.isLoading = false
      })
  }

  private loadMore(): void {
    if (this.isLoading || !this.hasMore || !this.nextUrl) {
      return
    }

    this.isLoading = true
    ApiClient.getNext(this.nextUrl)
      .then(res => {
        const resp = res?.toJSON() as CommentsResponse
        if (resp) {
          this.comments.push(...resp.comments)
          this.nextUrl = resp.next_url
          this.hasMore = !!resp.next_url
        }
      })
      .finally(() => {
        this.isLoading = false
      })
  }

  @Builder loadingFooter() {
    if (this.isLoading) {
      Row() {
        LoadingProgress()
          .width(24)
          .height(24)
          .color('#2196F3')
        Text('加载中...')
          .fontSize(14)
          .fontColor('#666666')
          .margin({ left: 8 })
      }
      .width('100%')
      .height(48)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
  }

  build() {
    List({ space: 16 }) {
      LazyForEach(this.comments, (item: Comment) => {
        ListItem() {
          CommentLabel({
            relateId: this.relateId,
            comment: item,
            getReply: () => this.getReply(item.id),
            postComment: (relateId: number, comment: string,
              parentCommentId?: number) => this.postComment(relateId, comment, parentCommentId)
          })
        }
      })
      ListItem(){
        this.loadingFooter()
      }
    }
    .constraintSize({
      maxHeight: '100%'
    })
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
    .divider({
      strokeWidth: 1
    })
    .onReachEnd(() => {
      this.loadMore()
    })
  }
}