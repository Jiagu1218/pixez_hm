import { ImageUtil } from "../network/util/ImageUtli"
import { image } from "@kit.ImageKit"
import { SwiperImageItem } from "./SwiperImageItem"
import { promptAction } from "@kit.ArkUI"

@ComponentV2
export struct SaveImage {
  private controller: SwiperController = new SwiperController()
  @Require @Param urls: Array<string>
  @Param initIndex: number = 0
  @Local private currentUrl: string = ''
  @Local private currentIndex: number = 0
  @Local private pixelMap: Map<string, image.PixelMap> = new Map()

  aboutToAppear(): void {
    this.controller.changeIndex(this.initIndex)
    this.currentIndex = this.initIndex
    if (this.urls.length == 1) {
      this.currentUrl = this.urls[0]
    } else {
      this.currentUrl = this.urls[this.currentIndex]
    }
  }

  @Builder
  private ImageSwiper() {
    Column() {
      Swiper(this.controller) {
        ForEach(this.urls, (url: string) => {
          SwiperImageItem({
            url: url, callback: (pixelMap: image.PixelMap) => {
              this.pixelMap.set(url, pixelMap)
            }
          })
        }, (url: string, index) => index.toString())
      }
      .onChange((index: number) => {
        this.currentUrl = this.urls[index]
      })
      .index(this.currentIndex)
      .cachedCount(3)
    }
    .height('100%')
    .width('100%')
  }

  @Builder
  private SaveButtonSection() {
    Row() {
      SaveButton({
        text: SaveDescription.SAVE_IMAGE
      })
        .onClick((event, result) => {
          const pixelMap = this.pixelMap.get(this.currentUrl)
          const filename = this.currentUrl.split('/').pop()
          if (result == SaveButtonOnClickResult.SUCCESS && pixelMap && filename) {
            ImageUtil.saveImage(pixelMap, filename,
              (success) => {
                promptAction.showToast({
                  message: success ? $r('app.string.save_success') : $r('app.string.save_fail'),
                  duration: 3000
                })
              })
          }
        })
    }
    .padding({bottom: 24})
  }

  build() {
    Stack() {
      this.ImageSwiper()
      this.SaveButtonSection()
    }
    .width('100%')
    .height('100%')
    .alignContent(Alignment.Bottom)
    .backgroundColor(Color.White)
    .borderRadius(12)
    .shadow({
      radius: 8,
      color: '#00000010',
      offsetX: 0,
      offsetY: 4
    })
  }
}