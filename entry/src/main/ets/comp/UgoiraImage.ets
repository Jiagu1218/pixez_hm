import { ApiClient, DownloadUtil, HttpImage, Illust, ImageUtil, UgoiraMetadataResponse } from "common"


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
      HttpImage({
        url: this.illust.meta_single_page.original_image_url,
        aRatio: this.aRatio,
        br: 12
      })
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
          .borderRadius(12)
      }
    }
    .width('100%')
    .borderRadius(12)
    .clip(true)
    .shadow({
      radius: 10,
      color: '#0000000C',
      offsetX: 0,
      offsetY: 3
    })
  }
}