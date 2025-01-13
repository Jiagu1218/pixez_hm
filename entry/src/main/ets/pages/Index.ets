import { OauthClient } from '../network/OauthClient';
import { BusinessError } from '@kit.BasicServicesKit';
import { ApiClient } from '../network/ApiClient';
import { TokenResponse } from '../network/response/TokenResponse';
import { webview } from '@kit.ArkWeb';
import { url, util } from '@kit.ArkTS';
import { Novel } from '../network/model/Novel';
import { NovelRecommendedResponse } from '../network/response/NovelRecommendedResponse';
import { AccountManager } from '../network/util/AccountManager';
import { ApiUtil } from '../network/util/ApiUtil';
import { router } from '@kit.ArkUI';
import { HtmlUtil } from '../network/util/HtmlUtil';
import { WebViewNovel } from '../network/model/WebViewNovel';
import { IllustDetailResponse } from '../network/response/IllustDetailResponse';
import { UgoiraMetadataResponse } from '../network/response/UgoiraMetadataResponse';
import { DownloadUtil } from '../network/util/DownloadUtil';
import { ImageUtil } from '../network/util/ImageUtli';
import { UgoiraImage } from '../comp/UgoiraImage';
import { Illust } from '../network/model/Illust';
import { NovelRankingModeEnum } from '../network/enums/NovelRankingModeEnum';
import { rcp } from '@kit.RemoteCommunicationKit';
import { AppConfig } from '../network/AppConfig';

@Entry
@ComponentV2
struct Index {
  private accountManager: AccountManager = AccountManager.getInstance();
  @Local url: string = '';
  @Local code: string = '';
  @Local controller: webview.WebviewController = new webview.WebviewController();
  schemeHandler: webview.WebSchemeHandler = new webview.WebSchemeHandler();
  @Local novels:Array<Novel> = new Array<Novel>();
  @Local aRatio:number = 1;
  @Local ani:Array<ImageFrameInfo> = []
  @Local illust:Illust|null = null

  aboutToAppear(): void {
    // schemeHandler 处理登录回调 todo 移植到登录页面
    this.schemeHandler.onRequestStart(callbacck=>{
      const parsedUrl = url.URL.parseURL(callbacck.getRequestUrl())
      const params = new url.URLParams(parsedUrl.search)
      if (params.has('code')){
        const code = params.get('code')!
        OauthClient.code2Token(code).then(res=>{
          if (res?.statusCode == 200) {
            const resp = res.toJSON() as TokenResponse
            this.accountManager.saveAccount(resp.user.account, resp.refresh_token)
            AppStorage.setOrCreate('token', resp.access_token)
            router.replaceUrl({
              url: 'pages/HomePage'
            })
          }
        })
        // 拦截请求
        return true
      }
      // 不进行拦截
      return false
    })
  }

  build() {
    Column(){
      Web({controller:this.controller,src:'https://www.youtube.com'})
        .onControllerAttached(()=>{
          this.controller.enableSafeBrowsing(false)
          this.controller.setCustomUserAgent('Mozilla/5.0 (Phone Android; OpenHarmony 5.0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Safari/537.36 ArkWeb/4.1.6.1 Mobile')
          this.controller.setWebSchemeHandler('pixiv', this.schemeHandler)
        })
        .onErrorReceive(e => {
          let errorInfo = e.error.getErrorInfo()
          console.error('加载webview失败', errorInfo, e.error.getErrorCode())
        })
        .onHttpErrorReceive(e => {
          console.error('加载webview失败', e)
        })
        .onSslErrorEvent(e => {
          e.handler.handleConfirm()
          console.error('加载webview失败', e)
        })
        .onSslErrorEventReceive(e => {
          e.handler.handleConfirm()
          console.error('加载webview失败', e)
        })
        .javaScriptAccess(true)
        .domStorageAccess(true)
        .fileAccess(true)
        .onlineImageAccess(true)
        .imageAccess(true)
        .mixedMode(MixedMode.All)
        .zoomAccess(true)
        .databaseAccess(true)
        .layoutWeight(1)
        .width('100%')
        .height(500)
        .backgroundColor(Color.Gray)
      Scroll(){
        Column() {

          if (this.illust){
            UgoiraImage({illust:this.illust})
          }
          Button('测试DOH').onClick(()=>{
            const session = rcp.createSession({baseAddress:'https://208.67.220.220',headers:{
              'Content-Type': 'application/dns-message',
              'accept': 'application/dns-json'
            }})
            // const params = new url.URLParams({
            //   name: 'app-api.pixiv.net',
            //   type: 'A'
            // })
            session.post(`/dns-query`,{
              url: 'app-api.pixiv.net',
              type: 'A'
            }).then((res)=>{
              if (res){
                const resp = res.toJSON()
                console.info('DOH', resp)
              }
            }).catch((e: BusinessError)=>{
              console.error('22222', e)
            }).finally(()=>{
              session.close()
            })
          })
          Button("测试getRichTextInfo").onClick(() => {
            const html = 'おしまいと言ったな！あれは嘘だ！<br />これで今日はおしまいです<br />BOOTHに新作出しました<br />着せ恋　乾 紗寿叶のいろいろAIイラスト集　100枚<br /><a href="https://b-ai-cat.booth.pm/items/6414565" target="_blank">https://b-ai-cat.booth.pm/items/6414565</a><br />ぜひ支援よろしくお願いします。<br />ブックマーク、いいね、ぜひよろしくお願いします<br />タグも作品に合うと思ったら追加してくれたらうれしいです<br />Xもやってます。ぜひフォローよろしくお願いします<br /><a href="https://x.com/b_neko0505" target=\'_blank\' rel=\'noopener noreferrer\'>https://x.com/b_neko0505</a><br />Boothにてまとめた画像を販売してます。<br /><a href="https://b-ai-cat.booth.pm/" target="_blank">https://b-ai-cat.booth.pm/</a> 用正则表达式对该字符串进行处理分段，返回为标签类型，标签内容，标签属性，文本位置おしまいと言ったな！あれは嘘だ！<br />これで今日はおしまいです<br />BOOTHに新作出しました<br />着せ恋　乾 紗寿叶のいろいろAIイラスト集　100枚<br /><a href="https://b-ai-cat.booth.pm/items/6414565" target="_blank">https://b-ai-cat.booth.pm/items/6414565</a><br />ぜひ支援よろしくお願いします。<br />ブックマーク、いいね、ぜひよろしくお願いします<br />タグも作品に合うと思ったら追加してくれたらうれしいです<br />Xもやってます。ぜひフォローよろしくお願いします<br /><a href="https://x.com/b_neko0505" target=\'_blank\' rel=\'noopener noreferrer\'>https://x.com/b_neko0505</a><br />Boothにてまとめた画像を販売してます。<br /><a href="https://b-ai-cat.booth.pm/" target="_blank">https://b-ai-cat.booth.pm/</a>'
            const richTextInfos = HtmlUtil.getRichTextInfo(html)
            console.info('11111', richTextInfos)
          })
          Button("测试getSpotlightArticles").onClick(()=>{
            ApiClient.getSpotlightArticles('all').then(res => {
              console.info('11111', res)
            })
          })
          Button("测试getUserRecommended").onClick(() => {
            ApiClient.getUserRecommended().then(res => {
              console.info('11111', res)
            })
          })
          Button("测试getIllustBookmarkUsers").onClick(() => {
            ApiClient.getIllustBookmarkUsers(81804379,50).then(res => {
              console.info('11111', res)
            }).catch((e: BusinessError) => {
              console.error('22222', e)
            })
          })
          Button("测试getIllustNew").onClick(() => {
            ApiClient.getIllustNew().then(res => {
              console.info('11111', res)
            }).catch((e: BusinessError) => {
              console.error('22222', e)
            })
          })
          Button("测试NovelRanking").onClick(() => {
            ApiClient.getNovelRanking(NovelRankingModeEnum.DAY).then(res => {
              console.info('11111', res)
            }).catch((e: BusinessError) => {
              console.error('22222', e)
            })
          })
          Button("测试getUserList").onClick(() => {
            ApiClient.getUserList(40369071).then(res => {
              console.info('11111', res)
            }).catch((e: BusinessError) => {
              console.error('22222', e)
            })
          })
          Button("测试getgetUserMyPixiv").onClick(() => {
            ApiClient.getUserMyPixiv(40369071).then(res => {
              console.info('11111', res)
            }).catch((e: BusinessError) => {
              console.error('22222', e)
            })
          })
          Button("测试getMangaRecommend").onClick(() => {
            ApiClient.getMangaRecommend().then(res => {
              console.info('11111', res)
            }).catch((e: BusinessError) => {
              console.error('22222', e)
            })
          })
          Button("测试getUserDetail").onClick(() => {
            let userId:number = 6074768
            ApiClient.getUserDetail(userId).then(res => {
              console.info('11111', res)
            }).catch((e: BusinessError) => {
              console.error('22222', e)
            })
          })
          Button("测试getUserNovels").onClick(() => {
            let userId:number = 6634929
            ApiClient.getUserNovels(userId).then(res => {
              console.info('11111', res)
            }).catch((e: BusinessError) => {
              console.error('22222', e)
            })
          })
          Button('测试getIllustDetail').onClick(() => {
            ApiClient.getIllustDetail(81804379).then(res => {
              console.info('11111', res)
              if(res){
                const resp = res.toJSON() as IllustDetailResponse
                this.illust = resp.illust
                this.aRatio = resp.illust.width / resp.illust.height
                console.info('getIllustDetail',resp)
              }
            }).catch((e: BusinessError) => {
              console.error('22222', e)
            })
          })
          Button("测试getUgoiraMetadata").onClick(() => {
            ApiClient.getUgoiraMetadata(81804379).then(res => {
              console.info('11111', res)
              if (res) {
                const resp = res.toJSON() as UgoiraMetadataResponse
                DownloadUtil.downloadUgoiraFile(resp.ugoira_metadata.zip_urls.medium).then((success)=>{
                  if (success) {
                    this.ani.push(...ImageUtil.getUgoiraFormCache(resp.ugoira_metadata))
                  }
                })
                console.info('getUgoiraMetadata', resp)
              }
            }).catch((e: BusinessError) => {
              console.error('22222', e)
            })
          })
          Button("测试getSearchIllust").onClick(() => {
            ApiClient.getSearchIllust({
              word:'原神'
            }).then(res => {
              console.info('11111', res)
            }).catch((e: BusinessError) => {
              console.error('22222', e)
            })
          })
          Button("测试NovelRecommended").onClick(() => {
            ApiClient.getNovelRecommended().then(res => {
              console.info('11111', res)
              if (res) {
                const resp = res.toJSON() as NovelRecommendedResponse
                this.novels.push(...resp.novels)
                this.novels.push(...resp.ranking_novels)
              }
            }).catch((e: BusinessError) => {
              console.error('22222', e)
            })
          })
          Button('getNovelDetail').onClick(() => {
            ApiClient.getNovelDetail(15832696).then(res => {
              console.info('11111', res)
            }).catch((e: BusinessError)=>{
              console.error('22222', e)
            })
          })
          Button("测试webviewNovel").onClick(() => {
            ApiClient.webviewNovel(this.novels[5].id).then(res => {
              if (res?.headers['content-type']?.match('text/html')) {
                const body = res.toString()
                const jsonStr = HtmlUtil.getNovelJson(body!)
                console.info('11111', body,jsonStr)
                if (jsonStr) {
                  const json = JSON.parse(jsonStr) as WebViewNovel
                  console.info('webviewNovel',json)
                }
              }
            }).catch((e: BusinessError)=>{
              console.error('22222', e)
            })
          })
          Button("测试getNext").onClick(() => {
            ApiClient.getNext('https://app-api.pixiv.net/v1/novel/recommended?include_ranking_novels=false&include_privacy_policy=false&offset=15&already_recommended=22291583%2C17926293%2C18913289%2C22438378%2C17896532%2C22302763%2C23425714%2C18311794%2C23071218%2C13033079%2C23508714%2C17818353%2C17037801%2C23411262%2C22335392%2C13258882%2C18445500%2C17778560%2C21241060%2C23571787%2C23432939%2C22226712%2C22376729%2C13214719%2C22131414%2C22831890%2C22226144%2C23508040%2C22387489%2C21274507%2C22974989%2C19902538%2C20576645&max_bookmark_id_for_recommend=5842399607')
              .then(res => {
                console.info('1111', res)
              })
              .catch((e: BusinessError) => {
                console.error('22222', e)
              })
          })
          Button("测试getUserBookmarkNovel").onClick(() => {
            ApiClient.getUserBookmarkNovel('40369071', 'remark').then(res => {
              console.info('11111', res)
            }).catch((e: BusinessError) => {
              console.error('22222', e)
            })
          })
          Button("刷新token").onClick(() => {

          })
          Button("首页").onClick(() => {
            router.pushUrl({
              url: 'pages/HomePage'
            })
          })
          Button("用户信息").onClick(() => {
            router.pushUrl({
              url: 'pages/UserDetailPage'
            })
          })
          Button("获取验证信息").onClick(() => {
            let codeVerifier = OauthClient.generateCodeVerify()
            let challenge = OauthClient.getCodeChallenge(codeVerifier)
            console.info('获取验证信息', codeVerifier, challenge)
          })
          Button("获取验证地址").onClick(() => {
            this.url = OauthClient.generateWebviewUrl()
            try {
              this.controller.clearMatches()
              this.controller.clearHistory()
              this.controller.clearSslCache()
              this.controller.clearClientAuthenticationCache()
              const temp = url.URL.parseURL(this.url)
              const query =  new url.URLParams()
              query.set('prompt','select_account')
              query.set('return_to',temp.toString())
              query.set('source','pixiv-android')
              query.set('ref','')
              this.controller.loadUrl(this.url,
                [
                  {headerKey:'User-Agent',headerValue:AppConfig.USER_AGENT},
                  {headerKey:'Accept-language',headerValue:AppConfig.ACCEPT_LANGUAGE},
                  {headerKey:'App-OS',headerValue:AppConfig.APP_OS},
                  {headerKey:'App-OS-Version',headerValue:AppConfig.APP_OS_VERSION},
                  {headerKey:'App-Version',headerValue:AppConfig.APP_VERSION},
                  {headerKey:'Content-type',headerValue:'application/x-www-form-urlencoded;charset=UTF-8'},
                  {headerKey:'Referer',headerValue:AppConfig.BASE_API_URL}
                ]
              )
            } catch (e) {
              console.error('加载webview失败', e)
            }
            console.info('获取验证地址', this.url)
          })

        }
      }
      .layoutWeight(1)
      .width('100%')
    }.width('100%').height('100%')
  }
}