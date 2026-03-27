import { image } from "@kit.ImageKit"

import { BusinessError } from "@kit.BasicServicesKit"
import { LocalCacheInfo } from "pixez_network"
import { DownloadUtil } from "pixez_network"

@ReusableV2
@ComponentV2
export struct HttpImage {
  @Require @Param url: string
  @Param aRatio: number | null = null
  @Param br: Length | BorderRadiuses | LocalizedBorderRadiuses | null = null
  @Param cacheInfo: LocalCacheInfo | undefined = undefined
  @Local private defaultRatio: number = 16/9
  @Local private pic: image.PixelMap | null = null
  @Local private isLoading: boolean = true
  @Local private hasError: boolean = false
  @Event callback?: (pixelMap: image.PixelMap) => void

  aboutToAppear(): void {
    this.loadImage()
  }

  aboutToReuse(): void {
    this.loadImage()
  }

  aboutToRecycle(): void {
    // console.debug("")
  }

  private loadImage(): void {
    this.isLoading = true
    this.hasError = false

    DownloadUtil.downloadImage(this.url, this.cacheInfo)
      .then(pixelMap => {
        this.pic = pixelMap
        this.callback?.(pixelMap)
      })
      .catch((e: BusinessError) => {
        console.error('图片加载失败:', e)
        this.hasError = true
      })
      .finally(() => {
        this.isLoading = false
      })
  }

  aboutToDisappear(): void {
    // 清理资源
    this.pic = null
  }

  @Builder loadingPlaceholder() {
    Column() {
      LoadingProgress()
        .width(40)
        .height(40)
        .color('#2563EB')
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#F8FAFC')
  }

  @Builder errorPlaceholder() {
    Column() {
      SymbolGlyph($r('sys.symbol.picture_damage'))
        .fontSize(40)
        .fontColor(['#94A3B8'])
      Text('图片加载失败')
        .fontSize(14)
        .fontColor('#94A3B8')
        .margin({ top: 8 })
    }
    .width('100%')
    .height('100%')
    .justifyContent(FlexAlign.Center)
    .alignItems(HorizontalAlign.Center)
    .backgroundColor('#F8FAFC')
  }

  build() {
    Stack() {
      if (this.isLoading) {
        this.loadingPlaceholder()
      } else if (this.hasError) {
        this.errorPlaceholder()
      } else {
        Image(this.pic)
          .aspectRatio(this.aRatio ?? this.defaultRatio)
          .width('100%')
          .objectFit(ImageFit.Contain)
          .borderRadius(this.br)
          .transition({
            type: TransitionType.All
          })
      }
    }
    .width('100%')
    .aspectRatio(this.aRatio ?? this.defaultRatio)
    .borderRadius(this.br)
    .clip(true)
  }
}