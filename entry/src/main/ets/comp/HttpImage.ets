import { image } from "@kit.ImageKit"
import { DownloadUtil, LocalCacheInfo } from "../network/util/DownloadUtil"
import { BusinessError } from "@kit.BasicServicesKit"

@ComponentV2
export struct HttpImage{
  @Require @Param url:string
  @Param aRatio:number|null = null
  @Param br:Length | BorderRadiuses | LocalizedBorderRadiuses|null = null
  @Param cacheInfo:LocalCacheInfo|undefined = undefined
  @Local private defaultRatio:number = 16/9
  @Local private pic:image.PixelMap|null = null
  @Event callback?:(pixelMap:image.PixelMap)=>void

  aboutToAppear(): void {
    DownloadUtil.downloadImage(this.url,this.cacheInfo).then(pixelMap=>{
      this.pic = pixelMap
      this.callback?.(pixelMap)
    }).catch((e:BusinessError)=>{
      console.info('error',e)
    })
  }

  aboutToDisappear(): void {

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