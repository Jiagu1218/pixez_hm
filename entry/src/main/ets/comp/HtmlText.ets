import { HtmlUtil, RichTextInfo } from "../network/util/HtmlUtil"
import { common } from "@kit.AbilityKit"
import { BusinessError } from "@kit.BasicServicesKit"

@ComponentV2
export struct HtmlText{
  @Require @Param htmlText:string
  private richTextInfo:RichTextInfo[] = []
  aboutToAppear(): void {
    this.richTextInfo.push(...HtmlUtil.getRichTextInfo(this.htmlText))
  }
  build() {
    Text(){
      ForEach(this.richTextInfo,(item:RichTextInfo)=>{
        if (item.type === 'text'){
          Span(item.text)
        }else {
          if (item.tagName === 'a'){
            Span(item.text).fontColor(Color.Blue).decoration({
              type:TextDecorationType.Underline,
              color: Color.Blue
            }).onClick(()=>{
              //TODO 跳转网页或页面
              if (item.tagAttr?.['href']) {
                const context = getContext(this) as common.UIAbilityContext
                context.openLink(item.tagAttr['href'],{appLinkingOnly:false},(err,result)=>{
                  if (err) {
                    console.error('openLink failed, err:', err)
                  } else {
                    console.info('openLink success, result:', result)
                  }
                }).then(()=>{
                  console.info('openLink success')
                }).catch((err:BusinessError)=>{
                  console.error('openLink failed, err:', err)
                })
              }
            })
          }
        }
      })
    }
  }
}