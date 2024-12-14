import { ApiClient } from '../network/ApiClient'
import { Illust } from '../network/model/Illust'
import { router } from '@kit.ArkUI'
import { HttpImage } from '../comp/HttpImage';
import { IllustDetailResponse } from '../network/response/IllustDetailResponse';

interface Params {
  illustId: number;
}

@Entry
@ComponentV2
struct IllustDetailPage {
  @Local illustId: number = 0
  @Local illust: Illust|null = null
  aboutToAppear(): void {
    const params = router.getParams() as Params
    this.illustId = params.illustId
    ApiClient.getIllustDetail(params.illustId).then(res=>{
      console.info('1111',res)
      const resp = res?.toJSON() as IllustDetailResponse
      this.illustId = resp.illust.id
      this.illust = resp.illust
    })
  }

  build() {
    Scroll(){
      Column(){
        if (this.illust) {
          HttpImage({url: this.illust.image_urls.large})
        }
        Row(){
          Text(this.illust?.title ?? '').fontSize(30)
        }
        Row(){
          Text(this.illust?.caption ?? '').fontSize(20)
        }
        Row(){
          Text(this.illust?.user.name ?? '').fontSize(20)
        }

      }
    }
    .height('100%')
    .width('100%')
  }
}