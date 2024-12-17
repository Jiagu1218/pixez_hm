export class HtmlUtil{
  private static readonly scriptTagRegex = /<script\b[^<]*(?:(?!<\/script>)<[^<]*)*<\/script>/gi;
  /**
 * 用于匹配小说信息的正则表达式
 *
 * 这个正则表达式旨在捕获以 "novel:" 开头，后跟一个JSON对象，并以 ",\n\s*isOwnWork" 结尾的字符串
 * 它用于从一段文本中提取小说的JSON信息，该信息格式为一行，后面跟着一个表示是否是原创作品的标记
 */
private static readonly novelJsonRegex = /novel: ({.*?}),\n\s*isOwnWork/;


  public static getNovelJson(html:string){
    html.match(HtmlUtil.scriptTagRegex)?.forEach((script)=>{

    })
  }

}