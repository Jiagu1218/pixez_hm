/**
 * 列表控制器基类
 */
export class ListControllerBase{
  /**
   * 回到顶部
   */
  top:()=>void = () => {}
  /**
   * 清除
   */
  clean:()=>void = () => {}
  /**
   * 获取第一页数据
   */
  getFirstPage:()=>void = ()=>{}
}