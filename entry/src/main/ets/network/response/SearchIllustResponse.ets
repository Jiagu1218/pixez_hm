import { Illust } from "../model/Illust"

export interface SearchIllustResponse{
  illusts: Illust[]
  next_url: string|null
  search_span_limit: number
  show_ai: boolean
}