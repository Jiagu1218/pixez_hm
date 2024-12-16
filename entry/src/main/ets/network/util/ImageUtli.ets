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

  public static async saveImage(pixel:image.PixelMap,name:string):Promise<void>{
    if (!pixel || !name || !ImageUtil.photoHelper) {
      return
    }
    const mimeType = pixel.getImageInfoSync().mimeType
    const ext = mimeType.split('/').pop()?.replace('jpeg', 'jpg')
    ImageUtil.photoHelper?.createAssetWithShortTermPermission({
      title: name,
      fileNameExtension:ext,
      photoType: photoAccessHelper.PhotoType.IMAGE
    }).then(asset=>{
      const file = fileIo.openSync(asset,fileIo.OpenMode.CREATE|fileIo.OpenMode.READ_WRITE)
      const packer = image.createImagePacker()
      packer.packToFile(pixel,file.fd,{
        format:mimeType,
        quality:100
      }).catch((e:BusinessError)=>{
        console.log('打包图片失败',e)
      }).finally(()=>{
        fileIo.close(file)
        packer.release()
      })
    }).catch((e:BusinessError)=>{
      console.log('创建资产失败',e)
    })
  }

}