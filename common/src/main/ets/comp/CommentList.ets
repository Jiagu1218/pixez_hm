import { ApiClient, Comment, CommentsResponse } from "pixez_network"
import { CommentLabel } from "./CommentLabel"

@ComponentV2
export struct CommentList {
  @Local private comments: Comment[] = []
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
          .color('#2563EB')
        Text('加载中...')
          .fontSize(14)
          .fontColor('#64748B')
          .fontWeight(FontWeight.Medium)
          .margin({ left: 10 })
      }
      .width('100%')
      .height(56)
      .justifyContent(FlexAlign.Center)
      .alignItems(VerticalAlign.Center)
    }
  }

  build() {
    List({ space: 12 }) {
      Repeat(this.comments)
        .virtualScroll()
        .each(item => {
          ListItem() {
            CommentLabel({
              relateId: this.relateId,
              comment: item.item,
              getReply: () => this.getReply(item.item.id),
              postComment: (relateId: number, comment: string,
                parentCommentId?: number) => this.postComment(relateId, comment, parentCommentId)
            })
          }
        })
        .key(item => item.id+'')
      ListItem(){
        this.loadingFooter()
      }
    }
    .width('100%')
    .height('100%')
    .cachedCount(4)
    .constraintSize({
      maxHeight: '100%'
    })
    .nestedScroll({
      scrollForward: NestedScrollMode.PARENT_FIRST,
      scrollBackward: NestedScrollMode.SELF_FIRST
    })
    .divider({
      strokeWidth: 1,
      color: '#EEF2F7'
    })
    .onReachEnd(() => {
      this.loadMore()
    })
  }
}