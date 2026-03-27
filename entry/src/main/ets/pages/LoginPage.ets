import { LoginViewModel } from "../viewmodel/LoginViewModel";

@Entry
@ComponentV2
struct LoginPage {
  @Local private model: LoginViewModel = new LoginViewModel()
  @Local private webLoadFailed: boolean = false
  @Local private webErrorText: string = '网页加载失败，请重试'

  aboutToAppear(): void {
    this.model.init(this.getUIContext())
  }

  @Builder webSheet(){
    Stack() {
      Web({ controller: this.model.controller, src: this.model.webUrl })
        .onControllerAttached(() => {
          this.webLoadFailed = false
          this.webErrorText = '网页加载失败，请重试'
          this.model.controllerAttach()
        })
        .onPageBegin(() => {
          this.webLoadFailed = false
        })
        .onErrorReceive(e => {
          let errorInfo = e.error.getErrorInfo()
          let errorCode = e.error.getErrorCode()
          let errorMessage = `${errorInfo}`
          if (`${errorInfo}`.includes('ERR_TIMED_OUT')) {
            errorMessage = '登录页加载超时（ERR_TIMED_OUT），请检查网络或代理后重试'
          }
          this.webErrorText = errorMessage
          this.webLoadFailed = true
          console.error('加载webview失败', errorInfo, errorCode)
        })
        .onHttpErrorReceive(e => {
          this.webErrorText = `网页请求失败：${e.response.getResponseCode()}`
          this.webLoadFailed = true
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

      if (this.webLoadFailed) {
        Column({ space: 12 }) {
          Text('登录页面加载失败')
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .fontColor('#1E293B')
          Text(this.webErrorText)
            .fontSize(12)
            .fontColor('#64748B')
            .textAlign(TextAlign.Center)
          Button('重试加载')
            .onClick(() => {
              this.webLoadFailed = false
              this.model.controllerAttach()
            })
            .height(40)
            .padding({ left: 16, right: 16 })
            .backgroundColor($r('sys.color.brand'))
            .fontColor(Color.White)
            .borderRadius(10)
        }
        .width('86%')
        .padding(16)
        .backgroundColor('#FFFFFFF2')
        .borderRadius(12)
        .border({
          width: 1,
          color: '#E2E8F0'
        })
        .shadow({
          radius: 12,
          color: '#00000012',
          offsetX: 0,
          offsetY: 6
        })
        .alignItems(HorizontalAlign.Center)
      }
    }
    .width('100%')
    .height('100%')
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#E0EAFF', 0.0], ['#F8FBFF', 0.45], ['#FFFFFF', 1.0]]
        })

      Column({ space: 18 }) {
        Image($r('app.media.app_icon'))
          .height(128)
          .width(128)
          .borderRadius(28)
          .shadow({
            radius: 20,
            color: '#1D4ED822',
            offsetX: 0,
            offsetY: 10
          })
          .margin({ bottom: 8 })

        Text('Pixez')
          .fontSize(28)
          .fontWeight(FontWeight.Bold)
          .fontColor('#1E293B')

        Text('发现灵感，尽享创作')
          .fontSize(14)
          .fontColor('#64748B')
          .margin({ bottom: 12 })

        Button('登录')
          .onClick(() => {
            this.webLoadFailed = false
            this.model.loginAction()
          })
          .width('100%')
          .height(50)
          .backgroundColor($r('sys.color.brand'))
          .fontColor(Color.White)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .borderRadius(14)
          .shadow({
            radius: 12,
            color: '#1D4ED833',
            offsetX: 0,
            offsetY: 6
          })

        Button('注册')
          .onClick(() => {
            this.webLoadFailed = false
            this.model.registerAction()
          })
          .width('100%')
          .height(50)
          .backgroundColor('#F8FAFF')
          .fontColor($r('sys.color.brand'))
          .borderColor('#BFDBFE')
          .borderWidth(1)
          .fontSize(18)
          .fontWeight(FontWeight.Medium)
          .borderRadius(14)

        Text('© 2025 Pixez_HM')
          .fontSize(12)
          .fontColor($r('sys.color.ohos_id_color_titlebar_subtitle_text'))
          .margin({ top: 6 })
      }
      .width('86%')
      .padding({ left: 20, right: 20, top: 28, bottom: 22 })
      .backgroundColor('#FFFFFFEE')
      .borderRadius(24)
      .border({
        width: 1,
        color: '#E2E8F0'
      })
      .shadow({
        radius: 24,
        color: '#00000014',
        offsetX: 0,
        offsetY: 10
      })
      .alignItems(HorizontalAlign.Center)
    }
    .alignContent(Alignment.Center)
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