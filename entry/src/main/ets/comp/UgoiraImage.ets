import { ApiClient, DownloadUtil, Illust, ImageUtil, UgoiraMetadataResponse } from "pixez_network"
import { HttpImage } from "./HttpImage"

@ComponentV2
export struct UgoiraImage{
  @Require @Param illust:Illust
  @Local private aRatio:number = 1
  @Local private ani:Array<ImageFrameInfo> = []
  aboutToAppear(): void {
    this.aRatio = this.illust.width / this.illust.height
  }

  getUgoiraImage(){
    ApiClient.getUgoiraMetadata(this.illust.id).then(res => {
      if (res) {
        const resp = res.toJSON() as UgoiraMetadataResponse
        DownloadUtil.downloadUgoiraFile(resp.ugoira_metadata.zip_urls.medium).then((success)=>{
          if (success) {
            this.ani.push(...ImageUtil.getUgoiraFormCache(resp.ugoira_metadata))
          }
        })
      }
    })
  }

  build() {
    Stack(){
      HttpImage({url: this.illust.meta_single_page.original_image_url,aRatio:this.aRatio})
      .onClick(()=>{
        this.getUgoiraImage()
      })
      if (this.ani.length>0){
        ImageAnimator()
          .images(this.ani)
          .width('100%')
          .state(AnimationStatus.Running)
          .aspectRatio(this.aRatio)
          .iterations(-1)
      }
    }.width('100%')

  }
}