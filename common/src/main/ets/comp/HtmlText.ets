
import { common } from "@kit.AbilityKit"
import { BusinessError } from "@kit.BasicServicesKit"
import { HtmlUtil, RichTextInfo } from "pixez_network"

@ComponentV2
export struct HtmlText {
  @Require @Param htmlText: string
  private richTextInfo: RichTextInfo[] = []
  @Local private isHovered: boolean = false
  @Local private linkHovered: string | null = null

  aboutToAppear(): void {
    this.richTextInfo.push(...HtmlUtil.getRichTextInfo(this.htmlText))
  }

  build() {
    Text() {
      ForEach(this.richTextInfo, (item: RichTextInfo) => {
        if (item.type === 'text') {
          Span(item.text)
            .fontSize(14)
            .lineHeight(22)
            .fontColor('#334155')
        } else {
          if (item.tagName === 'a') {
            Span(item.text)
              .fontSize(14)
              .fontColor(this.linkHovered === item.text ? '#1D4ED8' : '#2563EB')
              .decoration({
                type: TextDecorationType.Underline,
                color: this.linkHovered === item.text ? '#1D4ED8' : '#2563EB'
              })
              .onClick(() => {
                if (item.tagAttr?.['href']) {
                  const context = getContext(this) as common.UIAbilityContext
                  context.openLink(item.tagAttr['href'], { appLinkingOnly: false }, (err) => {
                    if (err) {
                      console.error('openLink failed, err:', err)
                    }
                  }).catch((err: BusinessError) => {
                    console.error('openLink failed, err:', err)
                  })
                }
              })
              .onHover((isHovered: boolean) => {
                this.linkHovered = isHovered ? item.text : null
              })
              .transition({
                type: TransitionType.All
              })
          } else {
            Span(item.text)
              .fontSize(14)
              .lineHeight(22)
              .fontColor('#334155')
          }
        }
      },(item: RichTextInfo,index)=>index + item.text)
    }
    .copyOption(CopyOptions.LocalDevice)
    .textAlign(TextAlign.Start)
    .width('100%')
    .padding(16)
    .backgroundColor(this.isHovered ? '#F8FAFF' : '#FFFFFF')
    .borderRadius(12)
    .border({
      width: 1,
      color: this.isHovered ? '#DBEAFE' : '#EEF2F6'
    })
    .shadow({
      radius: this.isHovered ? 12 : 8,
      color: this.isHovered ? '#2563EB18' : '#00000008',
      offsetX: 0,
      offsetY: this.isHovered ? 6 : 3
    })
    .transition({
      type: TransitionType.All
    })
    .onHover((isHovered: boolean) => {
      this.isHovered = isHovered
    })
  }
}