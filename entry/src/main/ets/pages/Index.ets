import { OauthClient } from '../network/OauthClient';
import { BusinessError } from '@kit.BasicServicesKit';
import { ApiClient } from '../network/ApiClient';
import { TokenResponse } from '../network/response/TokenResponse';
import { webview } from '@kit.ArkWeb';
import { url } from '@kit.ArkTS';
import { Novel } from '../network/model/Novel';
import { NovelRecommendedResponse } from '../network/response/NovelRecommendedResponse';
import { AccountManager } from '../util/AccountManager';
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

@Entry
@ComponentV2
struct Index {
  private accountManager: AccountManager = AccountManager.getInstance();
  @Param message: string = 'Hello World';
  @Local url: string = '';
  @Local code: string = '';
  @Local controller: webview.WebviewController = new webview.WebviewController();
  @Local novels:Array<Novel> = new Array<Novel>();
  @Local aRatio:number = 1;
  @Local ani:Array<ImageFrameInfo> = []
  @Local illust:Illust|null = null
  aboutToAppear(): void {
    this.login()
  }

  login(){
    AccountManager.getInstance().getAccounts().then(accounts=>{
      const account = accounts.shift()
      if (account) {
        const refreshToken = this.accountManager.getRefreshToken(account.name)
        refreshToken.then(refreshToken => {
          if (refreshToken) {
            OauthClient.postRefreshAutoToken(refreshToken, account.name).then(res => {
              if (res && res.statusCode == 200) {
                let result = res.toJSON() as TokenResponse
                this.accountManager.saveAccount(account.name, result.refresh_token,ApiUtil.noNullRecord(result.user))
                AppStorage.setOrCreate('token',result.access_token)
              }else {
                console.info('refreshToken', 'null')
              }
            }).catch((e: BusinessError) => {
              console.error('refreshToken', e)
            })
          }else {
            console.info('refreshToken', 'null')
          }
        }).catch((e: BusinessError) => {
          console.error('refreshToken', e)
        })
      }
    }).catch((e:BusinessError)=>{
      console.error('account', e)
    })
  }

  build() {
    Scroll(){
      Column() {
        if (this.illust){
          UgoiraImage({illust:this.illust})
        }
        Button("测试walkthroughIllusts").onClick(() => {
          ApiClient.walkthroughIllusts().then(res => {
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
        Button("测试getUser").onClick(() => {
          let userId:string = '6074768'
          ApiClient.getUser(userId).then(res => {
            console.info('11111', res)
          }).catch((e: BusinessError) => {
            console.error('22222', e)
          })
        })
        Button("测试postUser").onClick(() => {
          ApiClient.postUser().then(res => {
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
              DownloadUtil.downloadUgoiraFile(resp.ugoira_metadata.zip_urls.medium,(success)=>{
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
          //TODO 删除该token
          OauthClient.postRefreshAutoToken('zjvmJr5Ip4oVxuwFPOSQNDjV8wCp0O2lzeDrLHN9rX0', '').then(res => {
            if (res && res.statusCode == 200) {
              let result = res.toJSON() as TokenResponse
              this.accountManager.saveAccount(result.user.account, result.refresh_token,ApiUtil.noNullRecord(result.user))
              AppStorage.setOrCreate<string>('token', result.access_token)
              console.info('11111', res)
            }

          }).catch((e: BusinessError) => {
            console.error('22222', e)
          })
        })
        Button("首页").onClick(() => {
          router.pushUrl({
            url: 'pages/HomePage'
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
            this.controller.loadUrl(temp.toString())
          } catch (e) {
            console.error('加载webview失败', e)
          }
          console.info('获取验证地址', this.url)
        })
        List(){
          ForEach(this.novels, (novel:Novel) => {
            ListItem(){
              // HttpImage({url: novel.image_urls.large})
            }
          })
        }.layoutWeight(1)
        .width('100%')
        .lanes(2)
      }
    }
    .height('100%')
    .width('100%')
  }
}