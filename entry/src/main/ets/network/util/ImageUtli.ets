import { photoAccessHelper } from "@kit.MediaLibraryKit";
import { common } from "@kit.AbilityKit";
import { image } from "@kit.ImageKit";
import { fileIo } from "@kit.CoreFileKit";
import { BusinessError } from "@kit.BasicServicesKit";
import { UgoiraMetadata } from "../model/UgoiraMetadata";

export class ImageUtil{
  private static photoHelper:photoAccessHelper.PhotoAccessHelper
  private static context:common.Context
  public static init(context:common.Context){
    try {
      ImageUtil.photoHelper = photoAccessHelper.getPhotoAccessHelper(context)
      ImageUtil.context = context
    } catch (e) {
      console.log('获取图片保存权限失败',e)
    }
  }

  public static release(){
    ImageUtil.photoHelper?.release()
  }
  /**
   * 保存图片
   * 需配合SaveButton组件使用
   * @param pixel 图片像素图
   * @param name 文件名
   * @param callback 保存结果回调
   * @returns
   * */
  public static async saveImage(pixel:image.PixelMap,name:string,callback?:(success:boolean)=>void):Promise<void>{
    if (!pixel || !name || !ImageUtil.photoHelper) {
      callback?.(false)
      return
    }
    const mimeType = pixel.getImageInfoSync().mimeType
    const ext = mimeType.split('/').pop()?.replace('jpeg', 'jpg')
    ImageUtil.photoHelper.createAsset(photoAccessHelper.PhotoType.IMAGE, ext, {
      title: name.split('.').shift()
    }).then(asset=>{
      const file = fileIo.openSync(asset,fileIo.OpenMode.CREATE|fileIo.OpenMode.READ_WRITE)
      const packer = image.createImagePacker()
      let result = true
      packer.packToFile(pixel,file.fd,{
        format:mimeType,
        quality:100
      }).catch((e:BusinessError)=>{
        result = false
        console.log('打包图片失败',e)
      }).finally(()=>{
        callback?.(result)
        fileIo.close(file)
        packer.release()
      })
    }).catch((e:BusinessError)=>{
      callback?.(false)
      console.log('创建资产失败',e)
    })
  }

  public static getUgoiraFormCache(metadate:UgoiraMetadata):Array<ImageFrameInfo>{
    const cacheDir = ImageUtil.context.cacheDir
    const imageFilePath =metadate.zip_urls.medium.split('/').pop()?.split('.').shift()
    const imageFileDir = cacheDir.concat('/ugoira/',imageFilePath!)
    return metadate.frames.map(frame=>{
      const imageFile = imageFileDir.concat('/',frame.file)
      return {
        src:`file://${imageFile}`,
        duration:frame.delay
      } as ImageFrameInfo
    })
  }

}