import { SymbolGlyphModifier } from '@kit.ArkUI'
import { DateTimeUtil } from '../network/util/DateTimeUtil'
import { UserPreview } from '../network/model/UserPreview'
import { UserPreviewCard } from '../comp/UserPreviewCard'
import { TrendTag } from '../network/response/TrendTagsResponse'
import { IllustWaterFlow } from '../comp/IllustWaterFlow'
import { NovelList } from '../comp/NovelList'
import { SearchViewModel } from '../viewmodel/SearchViewModel'

@ComponentV2
export struct SearchPage{

  @Local private model: SearchViewModel = new SearchViewModel()

  aboutToAppear(): void {
    this.model.init(this.queryNavigationInfo())
  }

  @Monitor('model.searchType')
  watch(){
    this.model.watchSearchType()
  }

  @Builder searchSetting(){
    Column({space:16}){
      Row(){
        Text('AI生成')
        Blank()
        Toggle({type:ToggleType.Switch,isOn:this.model.showAI}).onChange(isOn=>{
          this.model.showAI = isOn
        })
      }.width('100%')
      Divider()
      Row(){
        Text('搜索类型')
        Blank()
        Repeat(this.model.searchTypeOpts).each(item=>{
          Row(){
            Text(item.item.value)
            Radio(item.item).onChange(choose=>{
              if (choose){
                this.model.searchType = item.item.value
              }
            }).checked(item.item.value === this.model.searchType)
          }
        }).key(item=>item.value)
      }.width('100%')
      Divider()
      Row(){
        Text('排序')
        Blank()
        Row({space:6}){
          Repeat(this.model.sortOpts).each(item=>{
            Row(){
              Text(item.item.value)
              Radio(item.item).onChange(choose=>{
                if (choose){
                  this.model.sort = item.item.value
                }
              }).checked(item.item.value === this.model.sort)
            }
          }).key(item=>item.value)
        }
      }.width('100%')
      Divider()
      Row(){
        Text('搜索条件')
        Blank()
        Select(this.model.targetSelectOpt)
          .selected(this.model.searchTargets.indexOf(this.model.searchTarget))
          .value(this.model.searchTarget)
          .onSelect((index,value)=>{
            this.model.searchTarget = value
          })
      }.width('100%')
      Divider()
      Row(){
        Text('日期范围')
        Blank()
        Row({space:6}){
          Text(this.model.startDate? DateTimeUtil.parseDateToLocalFormatTime(this.model.startDate,'YYYY-MM-DD') : '选择日期')
            .onClick(()=>{
              DatePickerDialog.show({
                selected:this.model.startDate,
                end:this.model.endDate,
                onDateAccept:(date)=>{
                  this.model.startDate = date
                }
              })
            })
          Text('/')
          Text(this.model.endDate? DateTimeUtil.parseDateToLocalFormatTime(this.model.endDate,'YYYY-MM-DD') : '选择日期')
            .onClick(()=>{
              DatePickerDialog.show({
                selected:this.model.endDate,
                start:this.model.startDate,
                end:new Date(),
                onDateAccept:(date)=>{
                  this.model.endDate = date
                }
              })
            })
        }
      }.width('100%')
    }
  }

  @Builder searchTitle(){
    Search({value: this.model.word,controller: this.model.searchController})
      .onChange((value: string) => {
        this.model.searchAutocomplete(value)
      })
      .onSubmit(value=>{
        this.model.searchSubmitAction(value)
      })

  }
  @Builder tagTitle(tag:TrendTag){
    Column(){
      Text(tag.tag).fontSize(12).maxLines(1)
      if (tag.translated_name){
        Text(tag.translated_name).fontSize(10).maxLines(1)
      }
    }.width('100%')
    .height(30)
    .backgroundBlurStyle(BlurStyle.BACKGROUND_THIN)
  }

  build() {
    NavDestination(){
      if (this.model.searchType === 'illust'){
        IllustWaterFlow({controller:this.model.illustController,firstPage:()=>this.model.searchIllust()})
      }else if (this.model.searchType === 'novel'){
        NovelList({controller:this.model.novelController,firstPage:()=>this.model.searchNovel()})
      }else if (this.model.searchType === 'user'){
        List({space:8}){
          ListItemGroup({
            style:ListItemGroupStyle.CARD,
            space:8
          }){
            LazyForEach(this.model.users, (item:UserPreview)=>{
              ListItem({style:ListItemStyle.CARD}){
                UserPreviewCard({userPreview: item})
              }.onClick(()=>{
                this.model.userDetailAction(item)
              }).height(undefined)
            },(item:UserPreview)=>item.user.id.toString())
          }.divider({strokeWidth:2,startMargin:16,endMargin:16})
        }.cachedCount(4)
        .onReachEnd(()=>{
          this.model.nextPageUserAction()
        })
      }
    }
    .title(this.searchTitle,{
      backgroundBlurStyle: BlurStyle.BACKGROUND_THIN,
      enableHoverMode:true
    })
    .menus([{
      value: '搜索设置',
      symbolIcon:new SymbolGlyphModifier($r('sys.symbol.more')),
      action:()=>{
        this.model.showSheet = true
      }
    }])
    .padding({top:32})
    .bindSheet(this.model.showSheet,this.searchSetting(),{
      title: { title:'搜索设置' },
      height:SheetSize.MEDIUM,
      blurStyle:BlurStyle.Thin,
      shouldDismiss:()=>{
        this.model.showSheet = false
      }
    })
  }
}

@Builder export function SearchPageBuilder(){
  SearchPage()
}