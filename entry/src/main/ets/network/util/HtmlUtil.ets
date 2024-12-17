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
}