import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { connection } from '@kit.NetworkKit';
import { ImageUtil } from '../network/util/ImageUtli';
import { SessionManager } from '../network/pool/SessionManager';
import { url } from '@kit.ArkTS';
import { NavRouterType } from '../param/NavRouterType';
import { AppConfig } from '../network/AppConfig';
import { UserPreference } from '../network/util/UserPerference';

export default class EntryAbility extends UIAbility {
  /**
   * 处理应用被拉起的参数
   * @param want
   */
  handleParam(want: Want){
    if (want.uri) {
      // https://www.pixiv.net/artworks/81804379
      // const tempUrl = 'https://www.pixiv.net/artworks/81804379'
      const urlInfo = url.URL.parseURL(want.uri)
      const paths = urlInfo.pathname.split('/')
      switch (paths[1]){
        case 'users':
          AppStorage.setOrCreate<NavRouterType>('routerType',{
            name:'userDetailPage',
            id:Number.parseInt(paths[2])
          })
          break;
        case 'artworks':
          AppStorage.setOrCreate<NavRouterType>('routerType',{
            name:'illustDetailPage',
            id:Number.parseInt(paths[2])
          })
          break;
        case 'novel':
          AppStorage.setOrCreate<NavRouterType>('routerType',{
            name:'novelDetailPage',
            id:Number.parseInt(paths[2])
          })
          break;
      }
    }
  }
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    // 初始化链接
    UserPreference.init(this.context)
    SessionManager.init()
    ImageUtil.init(this.context)
    AppStorage.setOrCreate(UserPreference.TOKEN,UserPreference.get(UserPreference.TOKEN))
    this.handleParam(want)
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    try {
      webview.WebviewController.setHttpDns(webview.SecureDnsMode.SECURE_ONLY,AppConfig.DOH)
    } catch (e) {
      hilog.error(0x0000, 'testTag', 'Failed to set httpDns. Cause: %{public}s', JSON.stringify(e) ?? '');
    }
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    ImageUtil.release()
    SessionManager.destroy()
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    windowStage.loadContent('pages/LoginPage', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
      const mainWindow = windowStage.getMainWindowSync()
      mainWindow.setWindowBackgroundColor('#DCDCDC')
      mainWindow.setWindowLayoutFullScreen(true)
      hilog.info(0x0000, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.handleParam(want)
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onNewWant');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}