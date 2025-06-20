/**
 * DateTimeUtil 类提供了与日期和时间处理相关的实用方法
 * 它包括时区偏移计算、ISO格式时间解析以及当前时间的ISO格式表示等功能
 */
export class DateTimeUtil {
  /**
   * 当前时区偏移量，表示本地时间与UTC时间的时差
   * */
  public static currentTimeZoneOffset: string
  static {
    //初始化时区偏移量
    DateTimeUtil.currentTimeZoneOffset = DateTimeUtil.getTimeZoneOffset()
  }

  /**
   * 重置当前时区偏移量，使其反映当前的时区设置
   */
  public static resetTimeZoneOffset() {
    DateTimeUtil.currentTimeZoneOffset = DateTimeUtil.getTimeZoneOffset()
  }

  /**
   * 将Date对象转换为本地格式的时间字符串
   *
   * @param date Date对象，接受null或undefined，在这种情况下返回空字符串
   * @param format 可选参数，指定输出时间的格式，默认为'YYYY-MM-DD HH:mm:ss'
   * @returns 根据指定格式返回本地时间字符串，如果输入无效则返回空字符串
   */
  public static parseDateToLocalFormatTime(date: Date,format: string = 'YYYY-MM-DD HH:mm:ss'){
    return DateTimeUtil.parseIsoTimeToLocalFormatTime(date.toISOString(),format)
  }

  /**
   * 将ISO格式的时间字符串解析为本地格式的时间字符串
   *
   * @param isoTime ISO格式的时间字符串，接受null或undefined，在这种情况下返回空字符串
   * @param format 可选参数，指定输出时间的格式，默认为'YYYY-MM-DD HH:mm:ss'
   * @returns 根据指定格式返回本地时间字符串，如果输入无效则返回空字符串
   */
  public static parseIsoTimeToLocalFormatTime(isoTime: string | null | undefined,
    format: string = 'YYYY-MM-DD HH:mm:ss'): string {
    // 检查输入是否为空
    if (!isoTime) {
      return ''
    }

    // 验证日期有效性
    const date = new Date(isoTime)
    if (isNaN(date.getTime())) {
      return ''
    }

    // 使用 Intl.DateTimeFormat 处理时区信息
    const options: Intl.DateTimeFormatOptions = {
      year: 'numeric',
      month: '2-digit',
      day: '2-digit',
      hour: '2-digit',
      minute: '2-digit',
      second: '2-digit',
      hour12: false
    }
    const formatter = new Intl.DateTimeFormat('zh-CN', options)
    const parts = formatter.formatToParts(date)

    // 提取年、月、日、时、分、秒
    const year = parts.find(part => part.type === 'year')?.value || ''
    const month = parts.find(part => part.type === 'month')?.value || ''
    const day = parts.find(part => part.type === 'day')?.value || ''
    const hours = parts.find(part => part.type === 'hour')?.value || ''
    const minutes = parts.find(part => part.type === 'minute')?.value || ''
    const seconds = parts.find(part => part.type === 'second')?.value || ''

    // 替换格式字符串中的占位符
    return format
      .replace('YYYY', year)
      .replace('MM', month)
      .replace('DD', day)
      .replace('HH', hours)
      .replace('mm', minutes)
      .replace('ss', seconds)
  }


  /**
   * 获取当前时区偏移量
   * 时区偏移量表示本地时间与UTC时间之间的差异
   *
   * @returns {string} 返回时区偏移量字符串，格式为±HH:mm
   * 例如，如果本地时间比UTC时间早8小时，则返回'+08:00'
   */
  private static getTimeZoneOffset(): string {
    // 获取当前日期和时间
    let now = new Date()
    // 计算本地时间与UTC时间之间的时差，单位为分钟
    let offsetMinutes = now.getTimezoneOffset()
    // 确定时区偏移的正负号，本地时间早于UTC则为'+', 晚于UTC则为'-'
    let offsetSign = offsetMinutes < 0 ? '+' : '-'
    // 计算时区偏移的小时部分
    let offsetHours = Math.abs(Math.floor(offsetMinutes / 60))
    // 计算时区偏移的分钟部分
    let offsetMinutesRemaining = Math.abs(offsetMinutes % 60)
    // 构造时区偏移字符串，格式为±HH:mm
    return `${offsetSign}${String(offsetHours).padStart(2, '0')}:${String(offsetMinutesRemaining).padStart(2, '0')}`
  }


  /**
   * 获取当前时间的ISO格式表示，带有时区偏移
   *
   * 此函数旨在提供一个标准化的时间表示方法，用于在不同时间区的用户之间进行时间通信和记录
   * 它生成的时间字符串格式符合ISO 8601标准，确保了时间和日期数据的全球互操作性和理解性
   *
   * @returns {string} 当前时间的ISO格式字符串，形如"YYYY-MM-DDTHH:mm:ss±HH:mm"
   */
  public static getIsoTime(): string {
    // 获取当前日期和时间
    let now = new Date()
    // 返回当前时间的ISO格式字符串，并拼接上时区偏移
    return now.toISOString().split('.')[0] + DateTimeUtil.currentTimeZoneOffset
  }
}