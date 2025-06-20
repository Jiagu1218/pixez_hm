/**
 * 登录请求错误信息
 * */
export interface OauthErrorResponse{
  has_error: boolean
  errors: Errors
  error: string
}

interface Errors {
  system: System
}

interface System {
  message: string
  code: number
}