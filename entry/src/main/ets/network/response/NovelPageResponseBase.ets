import { Novel } from "../model/Novel"

export interface NovelPageResponseBase{
  novels: Novel[]
  next_url: string|null
}