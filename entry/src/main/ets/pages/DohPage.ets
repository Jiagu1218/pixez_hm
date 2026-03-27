
import { BusinessError } from '@kit.BasicServicesKit'
import { SymbolSpanModifier } from '@kit.ArkUI'
import { SniUtil } from 'common'
import { common } from '@kit.AbilityKit'

@Entry
@ComponentV2
struct DohPage{
  @Local dohUrl:Array<string> = SniUtil.DOH_URLS
  @Local checked:Array<boolean> = []
  @Local ips:Array<string> = []

  @Monitor('dohUrl')
  check(){
    for (let i = 0; i < this.dohUrl.length; i++) {
      this.checked[i] = false
    }
    for (let i = 0; i < this.dohUrl.length; i++) {
      this.ips[i] = ''
    }
  }

  @Local testUrl:string = 'https://www.baidu.com'
  private ok:SymbolSpanModifier = new  SymbolSpanModifier($r('sys.symbol.checkmark_circle_fill')).fontColor([Color.Green]).fontSize(20)
  private error:SymbolSpanModifier = new  SymbolSpanModifier($r('sys.symbol.xmark_circle_fill')).fontColor([Color.Red]).fontSize(20)
  aboutToAppear(): void {

  }

  private query() {
    this.dohUrl.forEach((url, index) => {
      SniUtil.tryIpFormDoHUrl(SniUtil.getHostName(this.testUrl), url).then((ip) => {
        this.checked[index] = true
        this.ips[index] = ip
      }).catch((e: BusinessError) => {
        this.checked[index] = false
        this.ips[index] = ''
      })
    })
  }

  @Builder dohCard(item:RepeatItem<string>){
    Column({space:8}){
      Text(){
        Span(item.item + ' ')
        SymbolSpan(undefined).attributeModifier(this.checked[item.index] ? this.ok : this.error)
      }.fontSize(15)
      .fontColor('#1E293B')
      .maxLines(2)
      Text(this.ips[item.index])
        .fontSize(13)
        .fontColor('#64748B')
    }
    .padding(14)
    .borderWidth(1)
    .borderColor('#E2E8F0')
    .backgroundColor('#FFFFFF')
    .constraintSize({minWidth:300})
    .borderRadius(14)
    .shadow({
      radius: 10,
      color: '#0000000C',
      offsetX: 0,
      offsetY: 3
    })
  }

  build() {
    Stack() {
      Column()
        .width('100%')
        .height('100%')
        .linearGradient({
          direction: GradientDirection.Bottom,
          colors: [['#EEF2FF', 0.0], ['#F8FAFC', 0.55], ['#FFFFFF', 1.0]]
        })
      Scroll() {
        Column({ space: 16 }) {
          Row() {
            Text('测试地址')
              .fontSize(15)
              .fontColor('#334155')
            Blank()
            TextInput({ placeholder: '请输入网址', text: this.testUrl }).onChange((value) => {
              this.testUrl = value
            }).width(300).height(48).margin({ top: 10, bottom: 10 })
              .placeholderColor('#94A3B8')
              .fontSize(16)
              .backgroundColor('#F8FAFC')
              .borderRadius(12)
          }

          Repeat(this.dohUrl)
            .each((url) => {
              this.dohCard(url)
            })
            .key((url) => url)
          Button('查询')
            .width('100%')
            .height(46)
            .fontSize(16)
            .fontWeight(FontWeight.Medium)
            .borderRadius(12)
            .backgroundColor('#2563EB')
            .fontColor(Color.White)
            .onClick(() => {
              this.query()
            })
          Button('跳转主页')
            .width('100%')
            .height(44)
            .fontSize(15)
            .borderRadius(12)
            .backgroundColor('#F1F5F9')
            .fontColor('#334155')
            .onClick(() => {
              this.getUIContext().getRouter().pushUrl({
                url: 'pages/HomePage'
              })
            })
          Button('跳转测试页')
            .width('100%')
            .height(44)
            .fontSize(15)
            .borderRadius(12)
            .backgroundColor('#F1F5F9')
            .fontColor('#334155')
            .onClick(() => {
              this.getUIContext().getRouter().pushUrl({
                url: 'pages/Index'
              })
            })
          Button('跳转小说')
            .width('100%')
            .height(44)
            .fontSize(15)
            .borderRadius(12)
            .backgroundColor('#EEF2FF')
            .fontColor('#2563EB')
            .onClick(() => {
              const content = this.getUIContext().getHostContext() as common.UIAbilityContext
              content.startAbility({
                bundleName: 'com.xjg.pixez',
                moduleName: 'novel',
                abilityName: 'NovelAbility',
              }).then((res) => {
                console.info('testTag', 'startAbility success')
              }).catch((err: BusinessError) => {
                console.error('testTag', err)
              })
            })
        }
        .width('100%')
        .padding({ left: 16, right: 16, top: 16, bottom: 32 })
      }
      .width('100%')
      .height('100%')
      .scrollBar(BarState.Auto)
      .edgeEffect(EdgeEffect.Spring)
    }
    .width('100%')
    .height('100%')
  }


}

@Builder
export function DohPageBuilder() {
  DohPage()
}