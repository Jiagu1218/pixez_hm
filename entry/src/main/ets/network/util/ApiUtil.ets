import { buffer } from "@kit.ArkTS"
import { cryptoFramework } from "@kit.CryptoArchitectureKit"
import { rcp } from "@kit.RemoteCommunicationKit"
import { SessionPoolNew } from "../pool/SessionPoolNew"

export class ApiUtil {

  /**
   * 发送POST请求
   * */
  public static async post(url: string, content?: rcp.RequestContent): Promise<rcp.Response | null> {
    const session: rcp.Session = await SessionPoolNew.acquire()
    const request: rcp.Request = new rcp.Request(url, 'POST')
    request.content = content
    return session.fetch(request)
  }


  /**
   * 发送GET请求
   * */
  public static async get(url: rcp.URLOrString, desc?: rcp.ResponseBodyDestination): Promise<rcp.Response | null> {
    const session: rcp.Session = await SessionPoolNew.acquire()
    const request: rcp.Request = new rcp.Request(url,'GET')
    request.destination = desc;
    try {
      return session.fetch(request)
    } finally {
      SessionPoolNew.release(session)
    }
  }

  /**
   * 发送请求
   * */
  public static async fetch(request: rcp.Request): Promise<rcp.Response | null> {
    const session: rcp.Session = await SessionPoolNew.acquire()
    try {
      return session.fetch(request)
    } finally {
      SessionPoolNew.release(session)
    }
  }

  /**
   * 将给定的对象转换为一个不含null、undefined或空字符串记录的键值对对象
   * 此函数用于清理对象中所有为空或未定义的值，并将键名从驼峰写法转换为下划线写法
   * 对于布尔值、数字、大整数类型的值，将转换为字符串
   * 对于数组，将转换为以空格分隔的字符串，并在键名后添加"[]"后缀
   * 对于其他对象类型，将转换为JSON字符串
   *
   * @param obj 一个任意对象，包含可能为null、undefined或空字符串的值
   * @param arraysSplice 数组元素之间的分隔符，默认为空格
   * @returns 返回一个不含null、undefined或空字符串记录的键值对对象，键名转换为下划线写法
   */
  public static noNullRecord(obj?: object, arraysSplice: string=' '): Record<string, string> {
    // 初始化一个新的记录对象，用于存储转换后的键值对
    const record: Record<string, string> = {}
    if (obj === undefined || obj === null){
      return record
    }
    // 遍历原始对象的所有键
    Object.keys(obj).forEach(key => {
      // 只处理值不为null、undefined或空字符串的键值对
      if (obj[key] !== undefined && obj[key] !== null && obj[key] != '') {
        // 将小驼峰写法的key转换为下划线写法
        const lineKey = key.replace(/([A-Z])/g, '_$1').toLowerCase()
        // 根据值的类型进行相应的转换
        switch (typeof obj[key]){
          case 'boolean':
            // 将布尔值转换为字符串"true"或"false"
            record[lineKey] = obj[key] ? 'true' : 'false'
            break
          case 'number':
          case 'bigint':
            // 将数字或大整数类型转换为字符串
            record[lineKey] = obj[key].toString()
            break
          case 'string':
            // 直接使用字符串类型的值
            record[lineKey] = obj[key]
            break
          case 'object':
            if (Array.isArray(obj[key])) {
              // 对于数组，将其转换为以分隔符分隔的字符串，并在键名后添加"[]"后缀
              record[`${lineKey}[]`] = obj[key].join(arraysSplice)
            } else {
              // 对于其他对象类型，将其转换为JSON字符串
              record[lineKey] = JSON.stringify(obj[key])
            }
            break
          default:
        }
      }
    })
    // 返回转换后的记录对象
    return record
  }

  /**
   * 使用MD5算法为给定字符串生成哈希值。
   * 该方法用于将字符串转换为固定长度的哈希值，常用于数据完整性检查或生成唯一标识符。
   *
   * @param message 要进行哈希运算的输入字符串。
   * @returns 返回生成的哈希值的十六进制字符串形式。
   */
  public static getHash(message: string): string {
    // 创建一个MD5哈希对象，使用crypto框架。
    let md5 = cryptoFramework.createMd('MD5')
    // 将输入字符串转换为Uint8Array，并更新哈希对象。
    md5.updateSync({ data: new Uint8Array(buffer.from(message, 'utf-8').buffer) })
    // 执行哈希计算并获取结果。
    let digest = md5.digestSync()
    // 将哈希结果转换为数组。
    let hashArray = Array.from(new Uint8Array(digest.data))
    // 将数组中的每个元素转换为十六进制字符串，并连接形成最终的哈希值。
    let hashHex = hashArray.map(byte => byte.toString(16).padStart(2, '0')).join('');
    // 返回最终的哈希值。
    return hashHex
  }

}