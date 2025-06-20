import { WebViewNovel } from "pixez_network";
import { NovelContentPart } from "../entity/NovelContent";


// reg 正则匹配
const REG = /\[(uploadedimage:\d+(?:-\d+)?)\]|\[(pixivimage:\d+(?:-\d+)?)\]/g
// illustIndexReg 插画的索引
const ILLUST_INDEX_REG = /pixivimage:(\d+(?:-\d+)?)/
// uploadedImageIndexReg 上传的图片的索引
const IMAGE_INDEX_REG = /uploadedimage:(\d+(?:-\d+)?)/

export function getNovelContentParts(novel: WebViewNovel): NovelContentPart[] {
  if (!novel) {
    return [];
  }
  let text: string = novel.text;
  if (!Array.isArray(novel.illusts) && !Array.isArray(novel.images)) {
    return [{  type: 'text', content: text}];
  } else {
    const textParts = text.split(REG).filter(Boolean)
    return textParts.map((part: string):  NovelContentPart => {
      if (part) {
        if (ILLUST_INDEX_REG.test(part)) {
          return {
            type: 'illust',
            content: novel.illusts[part.replace(ILLUST_INDEX_REG, '$1').toString()].illust.images.medium
          }
        } else if (IMAGE_INDEX_REG.test(part)) {
          return {
            type: 'image',
            content: novel.images[part.replace(IMAGE_INDEX_REG, '$1').toString()].urls.original
          }
        } else {
          return {
            type: 'text',
            content: part
          }
        }
      }else {
        return {
          type: 'text',
          content: ''
        }
      }
    })
  }
}