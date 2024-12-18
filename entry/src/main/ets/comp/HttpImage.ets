import { image } from "@kit.ImageKit"
import { DownloadUtil } from "../network/util/DownloadUtil"
import { ImageUtil } from "../network/util/ImageUtli"

@ComponentV2
export struct HttpImage{
  @Require @Param url:string
  @Param aRatio:number|null = null
  @Param br:Length | BorderRadiuses | LocalizedBorderRadiuses|null = null
  @Local private defaultRatio:number = 16/9
  @Local private pic:image.PixelMap|null = null
  @Event callback?:(pixelMap:image.PixelMap)=>void

  aboutToAppear(): void {
    DownloadUtil.downloadImage({
      url:this.url,
      callback: (pic:image.PixelMap)=>{
        this.pic = pic
        const info = pic.getImageInfoSync()
        this.defaultRatio = info.size.width/info.size.height
        this.callback?.(pic)
      }
    })
  }
  build() {
    Image(this.pic)
      .aspectRatio(this.aRatio??this.defaultRatio)
      .width('100%')
      .alt($r('app.media.picture_damage'))
      .objectFit(ImageFit.Contain)
      .borderRadius(this.br)
      .draggable(false)
      .gesture(
        LongPressGesture({duration:1000})
          .onActionEnd(event=>{
            ImageUtil.saveImage(this.pic!,this.url.split('/').pop() ?? '')
          })
      )
  }
}