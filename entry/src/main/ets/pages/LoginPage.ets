import { LoginViewModel } from "../viewmodel/LoginViewModel";

@Entry
@ComponentV2
struct LoginPage {
  @Local private model: LoginViewModel = new LoginViewModel()

  aboutToAppear(): void {
    this.model.init()
  }

  @Builder webSheet(){
    Web({controller:this.model.controller,src:this.model.webUrl})
      .onControllerAttached(()=>{
        this.model.controllerAttach()
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

  build() {
    Column({space:16}) {
      Image($r('app.media.app_icon')).width('40%')
      Row({space:32}){
        Button('登录').onClick(() => {
          this.model.loginAction()
        })
        Button('注册').onClick(() => {
          this.model.registerAction()
        })
      }
    }
    .justifyContent(FlexAlign.Center)
    .height('100%')
    .width('100%')
    .onAppear(() => {
      //默认为登录
      this.model.defaultSheet()
    })
    .bindSheet(this.model.showWeb!!,this.webSheet(),{
      title:{title:this.model.sheetTitle},
      shouldDismiss:()=>{
        this.model.showWeb = false
      }
    })
  }
}

@Builder
export function LoginPageBuilder(){
  LoginPage()
}