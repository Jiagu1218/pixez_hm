import { Illust } from "../../entity/Illust"

export interface SearchIllustResponse{
  illusts: Illust[]
  next_url?: string
  search_span_limit: number
  show_ai: boolean
}