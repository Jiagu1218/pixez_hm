import { image } from "@kit.ImageKit"
import { DownloadUtil } from "../network/util/DownloadUtil"

@ComponentV2
export struct HttpImage{
  @Require @Param url:string
  @Param aRatio:number|null = null
  @Param br:Length | BorderRadiuses | LocalizedBorderRadiuses|null = null
  @Local pic:image.PixelMap|null = null

  aboutToAppear(): void {
    DownloadUtil.downloadImage({
      url:this.url,
      callback: (pic:image.PixelMap)=>{
        this.pic = pic
      }
    })
  }
  build() {
    Image(this.pic)
      .aspectRatio(this.aRatio)
      .width('100%')
      .alt($r('app.media.picture_damage'))
      .objectFit(ImageFit.Contain)
      .borderRadius(this.br)
  }
}