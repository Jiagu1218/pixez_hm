/**
 * 搜索页路由参数
 */
export interface SearchRouterParam{
  /**
   * 搜索词
   */
  word:string
  /**
   * 搜索类型
   */
  type:'illust'|'novel'|'user'
  /**
   * 搜索目标
   */
  target:string
}
