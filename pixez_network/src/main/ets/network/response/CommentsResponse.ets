import { Comment } from "../model/Comment"

/**
 * 评论列表
 */
export interface CommentsResponse{
  comments: Comment[]
  next_url: string|null
  comment_access_control: number
}