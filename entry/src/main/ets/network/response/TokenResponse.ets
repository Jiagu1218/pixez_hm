import { User } from "../../entity/User";

/**
 * token认证信息
 * */
export interface TokenResponse{
  /**
   * 访问令牌，用于访问受保护资源
   * */
  access_token:string;
  /**
   * 访问令牌的过期时间（秒）
   * */
  expires_in:number;
  /**
   * 令牌类型
   * */
  token_type:string;
  /**
   * 令牌的权限范围
   * */
  scope:string;
  /**
   * 刷新令牌，用于获取新的访问令牌
   * */
  refresh_token:string;
  /**
   * 刷新令牌的过期时间（秒）
   * */
  refresh_token_expires_in:number;
  /**
   * 用户信息
   * */
  user: User
  /**
   * 响应信息
   * */
  response: Response
}

/**
 * 响应信息的接口
 * */
interface Response {
  /**
   * 访问令牌
   * */
  access_token: string
  /**
   * 访问令牌的过期时间（秒）
   * */
  expires_in: number
  /**
   * 令牌类型
   * */
  token_type: string
  /**
   * 令牌的权限范围
   * */
  scope: string
  /**
   * 刷新令牌
   * */
  refresh_token: string
  /**
   * 用户信息
   * */
  user: User
}
