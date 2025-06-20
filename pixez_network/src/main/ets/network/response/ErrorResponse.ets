/**
 * 需要token认证的错误信息？
 * */
export interface ErrorResponse{
  error: Error
}
interface Error {
  user_message: string
  message: string
  reason: string
  user_message_details: UserMessageDetails
}

interface UserMessageDetails {}