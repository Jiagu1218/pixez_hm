import { ImageUtil } from "../network/util/ImageUtli"
import { HttpImage } from "./HttpImage"
import { image } from "@kit.ImageKit"
import { ImageViewTouch, DisplayType} from "@ohos/imageviewzoom"
import { DownloadUtil } from "../network/util/DownloadUtil"

@ComponentV2
export struct SaveImage{
  private controller:SwiperController = new SwiperController()
  @Require @Param urls:Array<string>
  @Local currentUrl:string = ''
  @Local currentIndex:number = 0
  @Local pixelMap:Map<string,image.PixelMap> = new Map()
  @Provider('ImageViewTouchModel') touchModel:ImageViewTouch.Model = new ImageViewTouch.Model()
  aboutToAppear(): void {
    this.loadAllPixelMap()
    this.controller.changeIndex(this.urls.indexOf(this.currentUrl))
    this.touchModel.setDisplayType(DisplayType.FIT_TO_SCREEN)
    if (this.urls.length==1) {
      this.currentUrl = this.urls[0]
    }else {
      this.currentUrl = this.urls[this.currentIndex]
    }
  }

  loadAllPixelMap(){
    this.urls.forEach(url=>{
      DownloadUtil.downloadImage({
        url:url,
        callback: (pic:image.PixelMap)=>{
          this.pixelMap.set(url,pic)
          this.touchModel.setImageSrc(this.pixelMap.get(this.currentUrl))
        }
      })
    })
  }

  @Monitor('currentUrl')
  loadPixelMap(){
    this.touchModel.setImageSrc(this.pixelMap.get(this.currentUrl))
  }

  build() {
    Stack(){
      Column(){
        Swiper(this.controller){
          ForEach(this.urls,(url:string)=>{
            Column(){
              ImageViewTouch({})
              // HttpImage({url: url,callback: (pixelMap:image.PixelMap)=>{
              //   this.pixelMap.set(url,pixelMap)
              //   this.touchModel.setImageSrc(pixelMap)
              // }})
            }.width('100%')
            .height('100%')
          },(url:string,index)=>index.toString())
        }.onChange((index:number)=>{
          this.currentUrl = this.urls[index]
        }).index(this.currentIndex)
      }.height('100%')
      .width('100%')
      Row(){
        SaveButton({
          text: SaveDescription.SAVE_IMAGE
        })
          .onClick((event,result)=>{
            if (result == SaveButtonOnClickResult.SUCCESS) {
              ImageUtil.init(getContext(this))
              ImageUtil.saveImage(this.pixelMap.get(this.currentUrl)!,this.currentUrl.split('/').pop()!)
            }
          })
      }.width('100%')
    }.width('100%')
    .height('100%')
    .alignContent(Alignment.Bottom)
    .backgroundColor(Color.White)
  }
}