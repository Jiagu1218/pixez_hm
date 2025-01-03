import { preferences } from "@kit.ArkData"
import { common } from "@kit.AbilityKit"
import { BusinessError } from "@kit.BasicServicesKit"

/**
 * UserPreference 类用于管理用户偏好设置，使用单例模式来确保全局只有一个实例
 */
export class UserPreference {
  // 用户偏好设置的键名常量
  public static readonly USER_PREFERENCE_KEY = 'user_preference'
  // 用于存储令牌的键名常量
  public static readonly TOKEN = 'token'
  // Preferences 实例，用于存储用户偏好设置
  private static instance: preferences.Preferences

  /**
   * 初始化 UserPreference 单例
   * @param context 应用程序上下文，用于获取 Preferences 实例
   */
  public static init(context:common.Context){
    // 如果尚未初始化实例，则尝试获取或创建
    if (!UserPreference.instance) {
      preferences.getPreferences(context,'userPreference').then((preferences)=>{
        // 成功获取 Preferences 实例
        UserPreference.instance = preferences
      }).catch((e:BusinessError)=>{
        // 处理获取 Preferences 实例时的错误
        console.error('创建用户首选项失败',e)
      })
    }
  }

  /**
   * 获取存储的值
   * @param key 要获取的键名
   * @returns 对应键名的值，如果不存在则返回空字符串
   */
  public static get(key:string):string{
    // 如果实例存在，使用 getSync 方法同步获取值
    if (UserPreference.instance) {
      return UserPreference.instance.getSync(key,'') as string
    }
    // 如果实例不存在，返回空字符串
    return ''
  }

  /**
   * 设置键值对
   * @param key 要设置的键名
   * @param value 要设置的值
   */
  public static set(key:string,value:string){
    // 如果实例存在，使用 put 方法设置键值对，并调用 flush 方法保存更改
    if (UserPreference.instance) {
      UserPreference.instance.put(key,value).then(()=>{
        UserPreference.instance.flush()
      }).catch((e:BusinessError)=>{
        // 处理设置键值对时的错误
        console.error('保存用户首选项失败',e)
      })
    }
  }

  /**
   * 删除指定的键值对
   * @param key 要删除的键名
   */
  public static delete(key:string){
    // 如果实例存在，使用 delete 方法删除指定的键值对，并调用 flush 方法保存更改
    if (UserPreference.instance) {
      UserPreference.instance.delete(key).then(()=>{
        UserPreference.instance.flush()
      }).catch((e:BusinessError)=>{
        // 处理删除键值对时的错误
        console.error('删除用户首选项失败',e)
      })
    }
  }

  /**
   * 清空所有用户偏好设置
   */
  public static clear(){
    // 如果实例存在，使用 clear 方法清空所有键值对，并调用 flush 方法保存更改
    if (UserPreference.instance) {
      UserPreference.instance.clear().then(()=>{
        UserPreference.instance.flush()
      }).catch((e:BusinessError)=>{
        // 处理清空用户偏好设置时的错误
        console.error('清空用户首选项失败',e)
      })
    }
  }
}
