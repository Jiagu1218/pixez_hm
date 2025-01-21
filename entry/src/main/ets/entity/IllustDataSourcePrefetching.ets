import { IDataSourcePrefetching } from "@kit.ArkUI";
import { Illust } from "../network/model/Illust";
import { LazyDataSource } from "./LazyDataSource";
import { PlainArray } from "@kit.ArkTS";
import { rcp } from "@kit.RemoteCommunicationKit";
import { DownloadUtil } from "../network/util/DownloadUtil";
import { SessionManager } from "../network/pool/SessionManager";
import { BusinessError } from "@kit.BasicServicesKit";

export class IllustDataSourcePrefetching extends LazyDataSource<Illust> implements IDataSourcePrefetching {
  private preFetchList: PlainArray<rcp.Request>  = new PlainArray<rcp.Request>()
  private session: rcp.Session|undefined
  constructor() {
    super();
  }

  public async getSession(){
    this.session = await SessionManager.fileSessionPool.acquire()
  }

  public destroy(){
    this.session && SessionManager.fileSessionPool.release(this.session)
  }

  prefetch(index: number): void | Promise<void> {
    //todo 优化
    // const data = this.getData(index)
    // if (data) {
    //   const request = new rcp.Request(data.image_urls.medium)
    //   this.preFetchList.add(index, request)
    //   if (this.session) {
    //     DownloadUtil.fetchForPrefetch(request,this.session).catch((e:BusinessError)=>{
    //       console.error('prefetch fetch error',e)
    //     }).finally(()=>{
    //       this.preFetchList.remove(index)
    //     })
    //   }
    // }
  }

  cancel?(index: number): void | Promise<void> {
    if (this.preFetchList.has(index)) {
      const request = this.preFetchList.get(index)
      this.session?.cancel(request)
      this.preFetchList.remove(index)
    }
  }

}