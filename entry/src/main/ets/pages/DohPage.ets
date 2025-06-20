
import { BusinessError } from '@kit.BasicServicesKit'
import { SymbolSpanModifier } from '@kit.ArkUI'
import { SniUtil } from 'pixez_network'

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
      }.fontSize(16)
      .maxLines(2)
      Text(this.ips[item.index])
    }.borderWidth(1)
    .borderColor(Color.Gray)
    .constraintSize({minWidth:300})
    .borderRadius(16)
  }

  build() {
    Column({space:16}){
      Row(){
        Text('测试地址')
        Blank()
        TextInput({placeholder: '请输入网址',text: this.testUrl}).onChange((value) => {
          this.testUrl = value
        }).width(300).height(50).margin({ top: 10, bottom: 10 }).placeholderColor(Color.Gray).fontSize(20)
      }

      Repeat(this.dohUrl)
        .each((url) => {
          this.dohCard(url)
        })
        .key((url) => url)
      Button('查询').onClick(() => {
        this.query()
      })
      Button('跳转主页').onClick(() => {
        this.getUIContext().getRouter().pushUrl({
          url:'pages/HomePage'
        })
      })
    }
    .height('100%')
    .width('100%')
  }


}

@Builder
export function DohPageBuilder() {
  DohPage()
}