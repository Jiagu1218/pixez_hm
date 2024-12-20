import { image } from "@kit.ImageKit"
import { DownloadUtil, ImageTask } from "../network/util/DownloadUtil"
import { ImageUtil } from "../network/util/ImageUtli"

@ComponentV2
export struct HttpImage{
  @Require @Param url:string
  @Param aRatio:number|null = null
  @Param br:Length | BorderRadiuses | LocalizedBorderRadiuses|null = null
  @Local private defaultRatio:number = 16/9
  @Local private pic:image.PixelMap|null = null
  @Event callback?:(pixelMap:image.PixelMap)=>void
  private task:ImageTask|null = null

  aboutToAppear(): void {
    this.task = {
      url:this.url,
      callback:pixelMap=>{
        this.pic = pixelMap
        this.callback?.(pixelMap)
      }
    }
    DownloadUtil.downloadImage(this.task)
  }

  aboutToDisappear(): void {
    DownloadUtil.removeTask(this.task!)
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