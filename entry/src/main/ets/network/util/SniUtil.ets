import { url } from '@kit.ArkTS'
import { rcp } from '@kit.RemoteCommunicationKit'

/**
 * SniUtil类提供了与SNICheck相关的实用方法
 * 通过DNS over HTTPS (DoH) 查询域名真实IP地址的类，主要用于绕过SNI（Server Name Indication）
 */
export class SniUtil {

  /**
   * 定义了一系列可用的DNS-over-HTTPS(DOH)服务器地址
   */
  private static readonly DOH_URLS:Array<string> = [
    "https://1.0.0.1/dns-query",
    "https://1.1.1.1/dns-query",
    "https://doh.dns.sb/dns-query",
    "https://doh.pub/dns-query",
    "https://208.67.220.220/dns-query",
    "https://cloudflare-dns.com/dns-query"
  ]

  /**
   * 从给定的URL字符串中提取主机名
   * @param urlStr - 待解析的URL字符串
   * @returns 返回解析出的主机名
   */
  public static getHostName(urlStr:string):string{
    return url.URL.parseURL(urlStr).hostname
  }

  /**
   * 使用DNS-over-HTTPS(DOH)尝试获取主机名对应的IP地址
   * @param hostName - 待查询的主机名
   * @returns 返回查询到的IP地址，如果没有查询到则返回主机名
   */
  public static async tryIpFormDoH(hostName:string):Promise<string>{
    // 创建一个会话，用于发送DNS查询请求
    let session = rcp.createSession({
      headers: {
        "accept": "application/dns-json"
      },
      requestConfiguration:{
        transfer: {
          timeout: {
            // 设置连接超时时间 单位毫秒
            connectMs:2000
          }
        },
        security: {
          // 禁用远程验证
          remoteValidation: (context) => true
        }
      }
    })
    // 准备查询参数
    let params = new url.URLParams()
    params.set("name", hostName)
    // 查询A记录（IPv4）
    params.set("type", "A")
    // 禁用DNSSEC验证
    params.set("do","false")
    // 禁用检查禁用标志
    params.set("cd","false")

    let dohPromises = SniUtil.DOH_URLS.map(doh => {
      return new Promise<string | null>(resolve => {
        session.get(`${doh}?${params}`).then((resp) => {
          if (resp.statusCode == 200) {
            let json = resp.toJSON()
            if (json) {
              // 获取IP
              let ip: string = json['Answer'][0]["data"]
              resolve(ip)
            }
          }
          resolve(null)
        }).catch(() => {
          resolve(null)
        })
      })
    })

    try {
      // 发起并发请求并等待所有结果
      const results = await Promise.allSettled(dohPromises);
      // 遍历结果，返回第一个有效的 IP 地址
      for (const result of results) {
        if (result.status === 'fulfilled' && typeof result.value === 'string') {
          session.close();
          return result.value;
        }
      }
    } catch (e) {
      console.error('并发DNS查询异常:', e);
    } finally {
      session.close();
    }


    // // 遍历DOH_URLS，尝试从每个服务器查询IP
    // for (const doh of SniUtil.DOH_URLS){
    //   try {
    //     let resp = await session.get(`${doh}?${params}`)
    //     if (resp.statusCode == 200) {
    //       let json = resp.toJSON()
    //       if (json) {
    //         // 获取IP
    //         let ip: string = json['Answer'][0]["data"]
    //         // 关闭会话
    //         session.close()
    //         return ip
    //       }
    //     }
    //   } catch (e) {
    //     console.log(e)
    //   }
    // }
    // 关闭会话
    // session.close()
    return hostName
  }
}
