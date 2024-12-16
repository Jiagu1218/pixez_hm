import { photoAccessHelper } from "@kit.MediaLibraryKit";
import { common } from "@kit.AbilityKit";
import { image } from "@kit.ImageKit";
import { fileIo } from "@kit.CoreFileKit";
import { BusinessError } from "@kit.BasicServicesKit";

export class ImageUtil{
  private static photoHelper:photoAccessHelper.PhotoAccessHelper
  public static init(context:common.Context){
    try {
      ImageUtil.photoHelper = photoAccessHelper.getPhotoAccessHelper(context)
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
    // ImageUtil.photoHelper.createAssetWithShortTermPermission({
    //   title: name,
    //   fileNameExtension:ext,
    //   photoType: photoAccessHelper.PhotoType.IMAGE,
    //   subtype:photoAccessHelper.PhotoSubtype.DEFAULT
    // }).then(asset=>{
    //   const file = fileIo.openSync(asset,fileIo.OpenMode.CREATE|fileIo.OpenMode.READ_WRITE)
    //   const packer = image.createImagePacker()
    //   packer.packToFile(pixel,file.fd,{
    //     format:mimeType,
    //     quality:100
    //   }).catch((e:BusinessError)=>{
    //     console.log('打包图片失败',e)
    //   }).finally(()=>{
    //     fileIo.close(file)
    //     packer.release()
    //   })
    // }).catch((e:BusinessError)=>{
    //   console.log('创建资产失败',e)
    // })
  }

}