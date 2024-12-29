export class HtmlUtil {
  private static readonly scriptTagRegex = /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi;
  /**
   * 用于匹配小说信息的正则表达式
   *
   * 这个正则表达式旨在捕获以 "novel:" 开头，后跟一个JSON对象，并以 ",\n\s*isOwnWork" 结尾的字符串
   * 它用于从一段文本中提取小说的JSON信息，该信息格式为一行，后面跟着一个表示是否是原创作品的标记
   */
  private static readonly novelJsonRegex = /novel: ({.*?}),\n\s*isOwnWork/;

  public static getNovelJson(html: string) :string{
    //解析HTML文本，提取出script标签
    const scripts = html.match(HtmlUtil.scriptTagRegex);
    if (scripts) {
      //遍历script标签，查找包含小说信息的script标签
      for (const script of scripts) {
        //使用正则表达式匹配小说信息
        const match = script.match(HtmlUtil.novelJsonRegex);
        if (match) {
          //返回小说信息
          return match[1];
        }
      }
    }
    return "";
  }

  /**
   * 从HTML字符串中提取富文本信息
   * 该方法用于解析给定的HTML字符串，并将其转换为一个包含富文本信息的数组
   * 每个富文本信息对象包含类型（文本或HTML标签）、文本内容、标签名和标签属性（如果适用）
   *
   * @param html 待解析的HTML字符串
   * @returns 返回一个RichTextInfo对象的数组，每个对象包含解析出的富文本信息
   */
  public static getRichTextInfo(html: string): Array<RichTextInfo> {
    // 将HTML中的<br />标签替换为换行符，以便于后续处理
    const text = html.replaceAll('<br />', '\n');
    // 初始化结果数组，用于存储解析后的富文本信息
    const result: Array<RichTextInfo> = [];
    // 定义正则表达式，用于匹配HTML标签或纯文本
    const tagRegex = /<([a-zA-Z0-9]+)([^>]*)>(.*?)<\/\1>|([^<]+)/g;
    // 初始化匹配结果变量
    let match: RegExpExecArray | null = null;

    // 使用正则表达式循环匹配文本中的每个部分
    while ((match = tagRegex.exec(text)) !== null) {
      if (match[4]) {
        /* 匹配到纯文本 */
        result.push({
          type: 'text',
          text: match[4]
        });
      } else {
        /* 匹配到HTML标签 */
        const tagName = match[1]
        const tagAttrStr = match[2]
        const tagContent = match[3]
        // 处理嵌套标签
        if (tagContent.includes('<')) {
          // 嵌套标签，递归调用getRichTextInfo方法解析嵌套标签
          result.push(...HtmlUtil.getRichTextInfo(tagContent))
          continue
        }
        // 初始化标签属性对象
        const tagAttr: Record<string, string> = {}
        // 解析标签属性
        const attrRegex = /(\w+)\s*=\s*(['"])(.*?)\2/g;
        let attrMatch: RegExpExecArray | null;
        while ((attrMatch = attrRegex.exec(tagAttrStr)) !== null) {
          tagAttr[attrMatch[1]] = attrMatch[3]
        }
        // 将解析的HTML标签信息添加到结果数组中
        result.push({
          type: 'html',
          text: tagContent,
          tagName: tagName,
          tagAttr: tagAttr
        });
      }
    }
    // 返回解析后的富文本信息数组
    return result
  }


}

/**
 * 富文本信息
 * 该接口用于描述富文本的相关信息，包括文本类型、文本内容、标签属性和标签名称
 */
export interface RichTextInfo{
  // 指定文本的类型，可以是纯文本('text')或HTML格式('html')
  type:'text'|'html'

  // 文本内容，根据type字段决定是否被解释为HTML
  text:string

  // 可选字段，用于指定标签的属性，是一个键值对的形式
  tagAttr?:Record<string,string>

  // 可选字段，用于指定标签名称，当需要将文本包装在特定标签内时使用
  tagName?:string
}
