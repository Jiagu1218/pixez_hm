import { ApiUtil } from './util/ApiUtil';
import { rcp } from '@kit.RemoteCommunicationKit';
import { buffer, util } from '@kit.ArkTS';
import { cryptoFramework } from '@kit.CryptoArchitectureKit';

/**
 * 认证api
 * */
export class OauthClient {
  private static readonly CLIENT_ID: string = 'MOBrBDS8blbauoSck0ZfDbtuzpyT';
  private static readonly CLIENT_SECRET: string = 'lsACyCD94FhDUtGTXi3QzcFE2uU1hqtDaKeqrdwj';
  private static readonly REFRESH_CLIENT_ID: string = 'KzEZED7aC0vird8jWyHM38mXjNTY';
  private static readonly REFRESH_CLIENT_SECRET: string = 'W9JZoJe00qPvJsiyCGT3CCtC6ZUtdpKpzMbNlUGP'
  private static readonly BASE_OAUTH_URL_HOST = "oauth.secure.pixiv.net"
  /**
   * codeVerifier
   * */
  private static codeVerifier: string

  /**
   * 账号登录
   * @deprecated 已无法使用
   * */
  public static postAuthToken(username: string, password: string,
    deviceToken: string = 'pixiv'): Promise<rcp.Response | null> {
    return ApiUtil.post(`https://${OauthClient.BASE_OAUTH_URL_HOST}/auth/token`, new rcp.Form({
      'client_id': OauthClient.CLIENT_ID,
      'client_secret': OauthClient.CLIENT_SECRET,
      'grant_type': 'password',
      'username': username,
      'password': password,
      'device_token': deviceToken,
      'get_secure_url': true,
      'include_policy': true
    }))

  }

  /**
   * generateWebviewUrl登录成功之后返回的code参数,通过此参数获取token
   * @param code 授权码
   * */
  public static code2Token(code: string): Promise<rcp.Response | null> {
    return ApiUtil.post(`https://${OauthClient.BASE_OAUTH_URL_HOST}/auth/token`, new rcp.Form({
      'code': code,
      'redirect_uri': 'https://app-api.pixiv.net/web/v1/users/auth/pixiv/callback',
      'grant_type': 'authorization_code',
      'include_policy': true,
      'client_id': OauthClient.CLIENT_ID,
      'code_verifier': OauthClient.codeVerifier || '',
      'client_secret': OauthClient.CLIENT_SECRET
    }))
  }

  /**
   * generateWebviewUrl登录成功之后返回的refresh_token参数,通过此参数获取新的token
   * @param refreshToken 刷新令牌
   * */
  public static postRefreshAutoToken(refreshToken: string, deviceToken?: string): Promise<rcp.Response | null> {
    return ApiUtil.post(`https://${OauthClient.BASE_OAUTH_URL_HOST}/auth/token`, new rcp.Form({
      "client_id": OauthClient.CLIENT_ID,
      "client_secret": OauthClient.CLIENT_SECRET,
      "grant_type": "refresh_token",
      "refresh_token": refreshToken,
      "include_policy": true
    }))
  }


  /**
   * 生成验证码字符串
   *
   * 本函数旨在创建一个安全的、随机的验证码字符串,用于用户验证等场景
   * 它通过利用加密框架生成的随机字节与预定义的字符集进行映射,以构建一个不可预测的字符串
   *
   * @returns {string} 生成的验证码字符串
   */
  public static generateCodeVerify(): string {
    // 定义随机字符集,包括大小写字母、数字及部分特殊字符,用于生成验证码
    const randomKeySet = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-._~';
    // 创建加密器实例,用于生成随机数
    let crypto = cryptoFramework.createRandom()
    // 生成128字节的随机数据,确保验证码的唯一性和安全性
    let random = crypto.generateRandomSync(128).data
    // 将随机生成的字节数据映射为验证码字符串,每个字节与字符集中的字符进行映射
    return Array.from(random).map(byte => randomKeySet.charAt(byte % randomKeySet.length)).join('');

  }

  /**
   * 根据codeVerifier生成codeChallenge
   * 该方法用于OAuth 2.0授权流程中的PKCE扩展,以增强授权代码的传输安全性
   *
   * @param codeVerifier 一个随机生成的字符串,用于生成codeChallenge
   * @returns 返回生成的codeChallenge字符串
   */
  public static getCodeChallenge(codeVerifier: string): string {
    // 创建Base64Helper实例,用于后续的编码操作
    const base64 = new util.Base64Helper()
    // 创建SHA256实例,用于计算哈希值
    const sha256 = cryptoFramework.createMd('SHA256')
    // 将codeVerifier转换为ASCII格式的Uint8Array,并进行哈希计算
    sha256.updateSync({ data: new Uint8Array(buffer.from(codeVerifier, 'ascii').buffer) })
    // 获取哈希计算结果
    let digest = sha256.digestSync()
    // 将哈希结果编码为Base64格式
    let codeChallengeUint8Array = base64.encodeSync(new Uint8Array(digest.data))
    // 创建TextDecoder实例,用于将Base64编码的二进制数据转换为字符串
    const textDecoder = util.TextDecoder.create('UTF-8')
    // 将Base64编码的二进制数据转换为字符串,并移除不安全的字符,以适应URL的传输要求
    return textDecoder.decodeToString(codeChallengeUint8Array, { stream: false })
      .replace(/=/g, '').replace(/\+/g, '-').replace(/\//g, '_')
  }

  /**
   * 生成Webview登录或创建账户的URL
   * ps:登录成功之后获取callback?信息，需保存相关的code
   * 本函数根据是否需要创建临时账户生成不同的URL,如果需要创建账户,
   * 则生成的URL指向账户创建页面；否则,生成的URL指向登录页面
   * 在生成URL之前,会先生成一个codeVerifier,并存储到AppStorage中
   * 然后,根据codeVerifier生成codeChallenge,并将其加入到URL中
   *
   * @param create 指示是否需要创建账户的布尔值默认为false
   * @returns 返回生成的URL字符串
   */
  public static generateWebviewUrl(create: boolean = false): string {
    // 生成codeVerifier
    let codeVerifier = OauthClient.generateCodeVerify()
    // 将存储codeVerifier,以便后续使用
    OauthClient.codeVerifier = codeVerifier
    // 根据codeVerifier生成codeChallenge
    let challenge = OauthClient.getCodeChallenge(codeVerifier)
    // 根据create参数决定返回的URL
    if (create) {
      // 返回账户创建页面的URL
      return `https://app-api.pixiv.net/web/v1/provisional-accounts/create?code_challenge=${challenge}&code_challenge_method=S256&client=pixiv-android`
    } else {
      // 返回登录页面的URL
      return `https://app-api.pixiv.net/web/v1/login?code_challenge=${challenge}&code_challenge_method=S256&client=pixiv-android`
    }
  }
}