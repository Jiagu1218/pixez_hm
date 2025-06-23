/**
 * 小说内容片段
 */
export interface NovelContentPart{
  /**
   * 内容类型
   */
  type: NovelContentPartType
  /**
   * 内容
   * @description 根据type不同，content的内容不同
   * @description type为image时，content为图片的url
   * @description type为text时，content为文本内容
   * @description type为link时，content为链接的url
   * @description type为illust时，content为插画url
   */
  content: string
}

export type NovelContentPartType = 'image'|'illust'|'text'|'link'