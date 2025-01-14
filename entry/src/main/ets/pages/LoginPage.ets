import { webview } from "@kit.ArkWeb";
import { url } from "@kit.ArkTS";
import { OauthClient } from "../network/OauthClient";
import { TokenResponse } from "../network/response/TokenResponse";
import { AccountManager } from "../network/util/AccountManager";
import { router } from "@kit.ArkUI";
import { AppConfig } from "../network/AppConfig";

@Entry
@ComponentV2
struct LoginPage {
  @Local private showWeb: boolean = false
  @Local private sheetTitle: string = '登录'
  @Local private webUrl: string = ''
  private accountManager: AccountManager = AccountManager.getInstance();
  private controller: webview.WebviewController = new webview.WebviewController();
  private schemeHandler: webview.WebSchemeHandler = new webview.WebSchemeHandler();

  aboutToAppear(): void {
    this.hasLogin()
    this.loginCallbackHandler()
  }

  hasLogin(){
    this.accountManager.getAccounts().then(res=>{
      if (res.length>0) {
        router.replaceUrl({
          url: 'pages/HomePage'
        })
      }
    })

  }

  login(){
    this.sheetTitle = '登录'
    this.webUrl = OauthClient.generateWebviewUrl()
    this.showWeb = true
  }

  register(){
    this.sheetTitle = '注册'
    this.webUrl = OauthClient.generateWebviewUrl(true)
    this.showWeb = true
  }

  @Builder webSheet(){
    Web({controller:this.controller,src:this.webUrl})
      .onControllerAttached(()=>{
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
      })
      .onErrorReceive(e => {
        let errorInfo = e.error.getErrorInfo()
        console.error('加载webview失败', errorInfo, e.error.getErrorCode())
      })
      .onHttpErrorReceive(e => {
        console.error('加载webview失败', e)
      })
      .onSslErrorEvent(e => {
        e.handler.handleConfirm()
        console.error('加载webview失败', e)
      })
      .onSslErrorEventReceive(e => {
        e.handler.handleConfirm()
        console.error('加载webview失败', e)
      })
      .javaScriptAccess(true)
      .domStorageAccess(true)
      .fileAccess(true)
      .onlineImageAccess(true)
      .imageAccess(true)
      .mixedMode(MixedMode.All)
      .zoomAccess(true)
      .databaseAccess(true)
  }
  loginCallbackHandler(){
    // schemeHandler 处理登录回调
    this.schemeHandler.onRequestStart(callbacck=>{
      const parsedUrl = url.URL.parseURL(callbacck.getRequestUrl())
      const params = new url.URLParams(parsedUrl.search)
      if (params.has('code')){
        const code = params.get('code')!
        OauthClient.code2Token(code).then(res=>{
          if (res?.statusCode == 200) {
            const resp = res.toJSON() as TokenResponse
            this.accountManager.saveAccount(resp.user.account, resp.refresh_token)
            AppStorage.setOrCreate('token', resp.access_token)
            this.showWeb = false
            router.replaceUrl({
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
  build() {
    Column({space:16}) {
      Image($r('app.media.app_icon')).width('40%')
      Row({space:32}){
        Button('登录').onClick(() => {
          this.login()
        })
        Button('注册').onClick(() => {
          this.register()
        })
      }
    }
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .width('100%')
    .onAppear(() => {
      //默认为登录
      this.showWeb = true
      this.webUrl = OauthClient.generateWebviewUrl()
    })
    .bindSheet(this.showWeb,this.webSheet(),{
      title:{title:this.sheetTitle},
      shouldDismiss:()=>{
        this.showWeb = false
      }
    })
  }
}

@Builder
export function LoginPageBuilder(){
  LoginPage()
}