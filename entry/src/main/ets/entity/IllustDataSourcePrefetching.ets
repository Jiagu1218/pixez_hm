import { IDataSourcePrefetching } from "@kit.ArkUI";
import { Illust } from "../network/model/Illust";
import { LazyDataSource } from "./LazyDataSource";
import { PlainArray } from "@kit.ArkTS";
import { rcp } from "@kit.RemoteCommunicationKit";
import { DownloadUtil } from "../network/util/DownloadUtil";
import { SessionManager } from "../network/pool/SessionManager";

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
    const data = this.getData(index)
    if (data) {
      const request = new rcp.Request(data.image_urls.medium)
      this.preFetchList.add(index, request)
      DownloadUtil.fetch(request).finally(()=>{
        this.preFetchList.remove(index)
      })
    }
  }

  cancel?(index: number): void | Promise<void> {
    if (this.preFetchList.has(index)) {
      const request = this.preFetchList.get(index)
      this.session?.cancel(request)
      this.preFetchList.remove(index)
    }
  }

}