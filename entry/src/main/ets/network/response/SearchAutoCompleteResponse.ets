export interface SearchAutoCompleteResponse{
  tags:Tag[]
}
interface Tag {
  name: string
  translated_name?: string
}