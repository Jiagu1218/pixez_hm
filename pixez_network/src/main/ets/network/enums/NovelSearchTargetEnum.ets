/**
 * 小说搜索目标枚举类
 * 用于定义小说搜索的不同目标和方式
 */
export enum NovelSearchTargetEnum {
  /**
   * 标签部分一致
   * 使用方式：当需要查找包含一个或多个指定标签的小说时选择此方式
   */
  PARTIAL_MATCH_FOR_TAGS = 'partial_match_for_tags',
  
  /**
   * 标签完全一致
   * 使用方式：当需要查找包含所有指定标签的小说时选择此方式
   */
  EXACT_MATCH_FOR_TAGS = 'exact_match_for_tags',
  
  /**
   * 正文
   * 使用方式：当需要在小说的正文中搜索指定内容时选择此方式
   */
  TEXT = 'text',
  
  /**
   * 关键词
   * 使用方式：当需要根据关键词搜索小说时选择此方式，关键词可以是标题、标签或正文中的词汇
   */
  KEYWORD = 'keyword',
  
  /**
   * 全文搜索
   * 使用方式：当需要在整个文档中搜索指定内容，包括标题、标签和正文时选择此方式
   */
  FULL_TEXT_SEARCH = 'full_text_search'
}
