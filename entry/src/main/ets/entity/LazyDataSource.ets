/**
 * 列表懒加载数据源
 * */
export class LazyDataSource<T> implements IDataSource {
  /**
   * 数据源
   * */
  private dataSource: T[] = []
  private listeners: DataChangeListener[] = []

  /**
   * 添加数据并提醒ui更新
   * @param items 待添加的数据
   * */
  push(...items: T[]) {
    if (items?.length > 0) {
      let dataOperation = items.map<DataOperation>((item, index) => {
        return {
          //数据添加类型
          type: DataOperationType.ADD,
          //插入数据索引值
          index: this.dataSource.length + index,
        }
      })
      this.dataSource.push(...items)
      this.notifyDatasetChange(dataOperation)
    }
  }
  /**
   * 覆盖数据并提醒ui更新
   * */
  setData(data: T[]){
    this.dataSource = data
    this.notifyDataReloaded()
  }

  /**
   * 清空数据并提醒ui更新
   * */
  clean() {
    this.dataSource = []
    this.notifyDataReloaded()
  }

  /**
   * 获得数据总数
   * */
  totalCount(): number {
    return this.dataSource.length
  }

  /**
   * 获取索引值index对应的数据
   * @param index 获取数据对应的索引值
   * */
  getData(index: number): T {
    return this.dataSource[index]
  }

  /**
   * 注册数据改变的监听器
   * @param listener 数据变化监听器
   * @description 提供给系统注册的接口
   * */
  registerDataChangeListener(listener: DataChangeListener): void {
    if (this.listeners.indexOf(listener) < 0) {
      this.listeners.push(listener);
    }
  }

  /**
   * 注销数据改变的监听器
   * @param listener 数据变化监听器
   * @description 提供给系统注销的接口
   * */
  unregisterDataChangeListener(listener: DataChangeListener): void {
    const pos = this.listeners.indexOf(listener);
    if (pos >= 0) {
      this.listeners.splice(pos, 1);
    }

  }

  /**
   * 通知组件重新加载所有数据
   * 键值没有变化的数据项会使用原先的子组件，键值发生变化的会重建子组件
   * */
  notifyDataReloaded() {
    this.listeners?.forEach(listener => {
      listener.onDatasetChange([{ type: DataOperationType.RELOAD}])
    })

  }

  /**
   * 通知组件index的位置有数据添加
   * @param index 数据添加位置的索引值
   * */
  notifyDataAdd(index: number) {
    this.listeners?.forEach(listener => {
      listener.onDataAdd(index)
    })
  }

  /**
   * 通知组件数据有移动
   * @param from 数据移动起始位置
   * @param to 数据移动目标位置
   * @description 将from和to位置的数据进行交换
   * 说明：数据移动前后键值要保持不变，如果键值有变化，应使用删除数据和新增数据接口
   * */
  notifyDataMove(from: number, to: number) {
    this.listeners?.forEach(listener => {
      listener.onDataMove(from, to)
    })
  }

  /**
   * 通知组件删除index位置的数据并刷新LazyForEach的展示内容
   * @param index 数据删除位置的索引值
   * @description 说明：需要保证dataSource中的对应数据已经在调用onDataDelete前删除，否则页面渲染将出现未定义的行为
   * */
  notifyDataDelete(index: number) {
    this.listeners?.forEach(listener => {
      listener.onDataDelete(index)
    })
  }

  /**
   * 通知组件index的位置有数据有变化
   * @param index 数据变化位置的索引值
   * */
  notifyDataChange(index: number) {
    this.listeners?.forEach(listener => {
      listener.onDataChange(index)
    })
  }

  /**
   * 进行批量的数据处理
   * 该接口不可与上述接口混用
   * @param dataOperations 一次处理数据的操作
   * */
  notifyDatasetChange(dataOperations: DataOperation[]) {
    this.listeners?.forEach(listener => {
      listener.onDatasetChange(dataOperations)
    })
  }
}