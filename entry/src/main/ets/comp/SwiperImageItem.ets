import { ImageViewTouch, DisplayType} from "@ohos/imageviewzoom"
import { DownloadUtil } from "../network/util/DownloadUtil"
import { image } from "@kit.ImageKit"

@ComponentV2
export struct SwiperImageItem{
  @Require @Param url:string
  @Provider('ImageViewTouchModel') private touchModel:ImageViewTouch.Model = new ImageViewTouch.Model()
  @Event callback?:(pixelMap:image.PixelMap)=>void
  @Local private loading:boolean = true
  aboutToAppear(): void {
    // this.touchModel.setDisplayType(DisplayType.FIT_TO_SCREEN)
    this.loadAllPixelMap()
  }

  loadAllPixelMap(){
    DownloadUtil.downloadImage(this.url).then((pic:image.PixelMap)=>{
      this.touchModel.setImageSrc(pic)
      this.loading = false
      this.callback?.(pic)
    })
  }
  build() {
    Stack(){
      ImageViewTouch({})
      if (this.loading){
        LoadingProgress().width(80)
      }
    }.width('100%')
    .height('100%')
  }
}