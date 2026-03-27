import { SymbolGlyphModifier } from '@kit.ArkUI'

import { UserPreviewCard } from '../comp/UserPreviewCard'

import { IllustWaterFlow } from '../comp/IllustWaterFlow'
import { NovelList } from '../comp/NovelList'
import { SearchViewModel } from '../viewmodel/SearchViewModel'
import { DateTimeUtil, TrendTag, UserPreview } from 'common'

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
    Column({ space: 16 }){
      Row(){
        Text('AI生成')
          .fontSize(15)
          .fontColor('#334155')
        Blank()
        Toggle({type:ToggleType.Switch,isOn:this.model.showAI}).onChange(isOn=>{
          this.model.showAI = isOn
        })
      }.width('100%')
      Divider().color('#EEF2F7')
      Row(){
        Text('搜索类型')
          .fontSize(15)
          .fontColor('#334155')
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
      Divider().color('#EEF2F7')
      Row(){
        Text('排序')
          .fontSize(15)
          .fontColor('#334155')
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
      Divider().color('#EEF2F7')
      Row(){
        Text('搜索条件')
          .fontSize(15)
          .fontColor('#334155')
        Blank()
        Select(this.model.targetSelectOpt)
          .selected(this.model.searchTargets.indexOf(this.model.searchTarget))
          .value(this.model.searchTarget)
          .onSelect((index,value)=>{
            this.model.searchTarget = value
          })
      }.width('100%')
      Divider().color('#EEF2F7')
      Row(){
        Text('日期范围')
          .fontSize(15)
          .fontColor('#334155')
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
    .width('100%')
    .padding({ left: 14, right: 14, top: 8, bottom: 8 })
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
    Column({ space: 2 }){
      Text(tag.tag)
        .fontSize(11)
        .fontWeight(FontWeight.Medium)
        .fontColor(Color.White)
        .maxLines(1)
        .textOverflow({ overflow: TextOverflow.Ellipsis })
      if (tag.translated_name){
        Text(tag.translated_name)
          .fontSize(10)
          .fontColor('#E2E8F0')
          .maxLines(1)
          .textOverflow({ overflow: TextOverflow.Ellipsis })
      }
    }
    .width('100%')
    .padding({ left: 8, right: 8, top: 8, bottom: 8 })
    .linearGradient({
      direction: GradientDirection.Bottom,
      colors: [['#00000000', 0.0], ['#000000AA', 0.55], ['#000000CC', 1.0]]
    })
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
          }.divider({ strokeWidth: 1, color: '#EEF2F7', startMargin: 16, endMargin: 16 })
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
    .padding({ top: 16 })
    .backgroundColor('#F8FAFC')
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