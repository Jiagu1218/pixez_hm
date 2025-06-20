import { webview } from '@kit.ArkWeb';

import { url } from '@kit.ArkTS';

import { AccountManager, AppConfig, OauthClient, TokenResponse } from 'pixez_network';

/**
 * 登录视图模型
 */
@ObservedV2
export class LoginViewModel{
  /**
   * 显示webview
   */
  @Trace showWeb: boolean = false
  /**
   * 标题
   */
  @Trace sheetTitle: string = '登录'
  /**
   * webview url
   */
  @Trace webUrl: string = ''
  /**
   * 账号管理
   */
  private _accountManager: AccountManager = AccountManager.getInstance();
  /**
   * 账号管理
   */
  public get accountManager(): AccountManager {
    return this._accountManager;
  }
  /**
   * webview控制器
   */
  private _controller: webview.WebviewController = new webview.WebviewController();
  /**
   * webview控制器
   */
  public get controller(): webview.WebviewController {
    return this._controller;
  }
  /**
   * webview schemeHandler
   */
  private _schemeHandler: webview.WebSchemeHandler = new webview.WebSchemeHandler();
  /**
   * webview schemeHandler
   */
  public get schemeHandler(): webview.WebSchemeHandler {
    return this._schemeHandler;
  }
  /**
   * 初始化
   */
  init(context:UIContext){
    this.hasLogin(context)
    this.loginCallbackHandler(context)
  }
  /**
   * 默认的webview
   */
  defaultSheet(){
    //默认为登录
    this.showWeb = true
    this.webUrl = OauthClient.generateWebviewUrl()
  }

  /**
   * 判断是否登录
   */
  hasLogin(context:UIContext){
    this._accountManager.getAccounts().then(res=>{
      if (res.length>0) {
        context.getRouter().replaceUrl({
          url: 'pages/HomePage'
        })
      }
    })
  }
  /**
   * 登录
   */
  loginAction(){
    this.sheetTitle = '登录'
    this.webUrl = OauthClient.generateWebviewUrl()
    this.showWeb = true
  }
  /**
   * 注册
   */
  registerAction(){
    this.sheetTitle = '注册'
    this.webUrl = OauthClient.generateWebviewUrl(true)
    this.showWeb = true
  }
  /**
   * 控制器绑定
   */
  controllerAttach(){
    this.controller.enableSafeBrowsing(false)
    this.controller.setCustomUserAgent('Mozilla/5.0 (Phone Android; OpenHarmony 5.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36 ArkWeb/4.1.6.1 Mobile')
    this.controller.setWebSchemeHandler('pixiv', this.schemeHandler)
    this.controller.loadUrl(this.webUrl,
      [
        {headerKey:'User-Agent',headerValue:AppConfig.USER_AGENT},
        {headerKey:'Accept-language',headerValue:AppConfig.ACCEPT_LANGUAGE},
        {headerKey:'App-OS',headerValue:AppConfig.APP_OS},
        {headerKey:'App-OS-Version',headerValue:AppConfig.APP_OS_VERSION},
        {headerKey:'App-Version',headerValue:AppConfig.APP_VERSION},
        {headerKey:'Content-type',headerValue:'application/x-www-form-urlencoded;charset=UTF-8'},
        {headerKey:'Referer',headerValue:AppConfig.BASE_API_URL}
      ]
    )
  }

  /**
   * 处理登录回调
   */
  loginCallbackHandler(context:UIContext){
    // schemeHandler 处理登录回调
    this._schemeHandler.onRequestStart(callbacck=>{
      const parsedUrl = url.URL.parseURL(callbacck.getRequestUrl())
      const params = new url.URLParams(parsedUrl.search)
      if (params.has('code')){
        const code = params.get('code')!
        OauthClient.code2Token(code).then(res=>{
          if (res?.statusCode == 200) {
            const resp = res.toJSON() as TokenResponse
            this._accountManager.saveAccount(resp.user.account, resp.refresh_token)
            AppStorage.setOrCreate('token', resp.access_token)
            this.showWeb = false
            context.getRouter().replaceUrl({
              url: 'pages/HomePage'
            })
          }
        })
        // 拦截请求
        return true
      }
      // 不进行拦截
      return false
    })
  }

}