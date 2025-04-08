import { HtmlUtil, RichTextInfo } from "../network/util/HtmlUtil"
import { common } from "@kit.AbilityKit"
import { BusinessError } from "@kit.BasicServicesKit"

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
            .lineHeight(20)
        } else {
          if (item.tagName === 'a') {
            Span(item.text)
              .fontSize(14)
              .fontColor(this.linkHovered === item.text ? '#1976D2' : '#2196F3')
              .decoration({
                type: TextDecorationType.Underline,
                color: this.linkHovered === item.text ? '#1976D2' : '#2196F3'
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
              .lineHeight(20)
          }
        }
      })
    }
    .copyOption(CopyOptions.LocalDevice)
    .textAlign(TextAlign.Start)
    .width('100%')
    .padding(16)
    .borderRadius(8)
    .shadow({
      radius: 4,
      color: '#00000005',
      offsetX: 0,
      offsetY: 2
    })
    .transition({
      type: TransitionType.All
    })
    .onHover((isHovered: boolean) => {
      this.isHovered = isHovered
    })
  }
}