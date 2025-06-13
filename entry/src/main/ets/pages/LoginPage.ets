import { LoginViewModel } from "../viewmodel/LoginViewModel";

@Entry
@ComponentV2
struct LoginPage {
  @Local private model: LoginViewModel = new LoginViewModel()

  aboutToAppear(): void {
    this.model.init(this.getUIContext())
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
    Column({space:24}) {
      Image($r('app.media.app_icon'))
        .height(240)
        .width(240)
        .margin({top:80,bottom:60})
      Button('登录').onClick(() => {
        this.model.loginAction()
      })
        .width('80%')
        .height(48)
        .backgroundColor($r('sys.color.brand'))
        .fontSize(18)
      Button('注册').onClick(() => {
        this.model.registerAction()
      })
        .width('80%')
        .height(48)
        .backgroundColor(Color.White)
        .fontColor($r('sys.color.brand'))
        .borderColor($r('sys.color.brand'))
        .borderWidth(1)
        .fontSize(18)

      Text('© 2025 Pixez_HM')
        .fontSize(12)
        .fontColor($r('sys.color.ohos_id_color_titlebar_subtitle_text'))
        .margin({ bottom: 16 })
    }
    .alignItems(HorizontalAlign.Center)
    .justifyContent(FlexAlign.Start)
    .height('100%')
    .width('100%')
    .onAppear(() => {
      //默认为登录
      this.model.defaultSheet()
    })
    .bindSheet(this.model.showWeb!!,this.webSheet(),{
      title:{title:this.model.sheetTitle},
      preferType:SheetType.CENTER,
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