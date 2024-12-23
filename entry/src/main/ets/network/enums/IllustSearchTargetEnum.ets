/**
 * 插画搜索目标枚举
 * 
 * 该枚举定义了插画搜索的不同目标，包括标签的部分一致、完全一致，以及标题和说明文的匹配
 */
export enum IllustSearchTargetEnum {
  /**
   * 标签部分一致
   * 
   * 搜索时，只要插画的标签中包含部分搜索关键词即可匹配
   */
  PARTIAL_MATCH_FOR_TAGS = 'partial_match_for_tags',
  /**
   * 标签完全一致
   * 
   * 搜索时，插画的标签需要完全匹配搜索关键词才能被找到
   */
  EXACT_MATCH_FOR_TAGS = 'exact_match_for_tags',
  /**
   * 标题说明文
   * 
   * 搜索时，会同时在插画的标题和说明文中寻找匹配搜索关键词的内容
   */
  TITLE_AND_CAPTION = 'title_and_caption'

}
