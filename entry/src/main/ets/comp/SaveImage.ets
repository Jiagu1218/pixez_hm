import { ImageUtil } from "../network/util/ImageUtli"
import { HttpImage } from "./HttpImage"
import { image } from "@kit.ImageKit"

@ComponentV2
export struct SaveImage{
  private controller:SwiperController = new SwiperController()
  @Require @Param urls:Array<string>
  currentUrl:string = ''
  @Local currentIndex:number = 0
  @Local pixelMap:Map<string,image.PixelMap> = new Map()
  aboutToAppear(): void {
    this.controller.changeIndex(this.urls.indexOf(this.currentUrl))
    if (this.urls.length==1) {
      this.currentUrl = this.urls[0]
    }else {
      this.currentUrl = this.urls[this.currentIndex]
    }
  }
  build() {
    Stack(){
      Column(){
        Swiper(this.controller){
          ForEach(this.urls,(url:string)=>{
            Column(){
              HttpImage({url: url,callback: (pixelMap:image.PixelMap)=>{
                this.pixelMap.set(url,pixelMap)
              }})
            }.width('100%')
            .height('100%')
          },(url:string,index)=>index.toString())
        }.onChange((index:number)=>{
          this.currentUrl = this.urls[index]
        })
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