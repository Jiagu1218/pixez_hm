import { AbilityConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { url } from '@kit.ArkTS';
import { NavRouterType } from '../param/NavRouterType';
import { ImageUtil, SessionManager, UserPreference } from 'common';

const DOMAIN = 0x0000;

export default class NovelAbility extends UIAbility {
  novelWant: Want | undefined = undefined;

  handleParam(want: Want){
    this.novelWant = want;
    if (want.uri) {
      const urlInfo = url.URL.parseURL(want.uri)
      const paths = urlInfo.pathname.split('/')
      switch (paths[1]){
        case 'novel':
          AppStorage.setOrCreate<NavRouterType>('routerType',{
            name:'novelDetailPage',
            id:Number.parseInt(paths[2])
          })
          break;
      }
    }
  }

  onNewWant(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.handleParam(want)
  }

  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    UserPreference.init(this.context)
    SessionManager.init()
    ImageUtil.init(this.context)
    this.handleParam(want)
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onCreate');
  }

  onDestroy(): void {
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onDestroy');
  }

  onWindowStageCreate(windowStage: window.WindowStage): void {
    // Main window is created, set main page for this ability
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageCreate');
    let page = 'pages/Index'
    let parameters = this.novelWant!.parameters;
    if (parameters){
      let novelId = parameters['novelId']
      if (novelId) {
        page = 'pages/NovelDetailPage'
      }
    }
    windowStage.loadContent(page, (err) => {
      if (err.code) {
        hilog.error(DOMAIN, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err));
        return;
      }
      hilog.info(DOMAIN, 'testTag', 'Succeeded in loading the content.');
    });
  }

  onWindowStageDestroy(): void {
    // Main window is destroyed, release UI related resources
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onWindowStageDestroy');
  }

  onForeground(): void {
    // Ability has brought to foreground
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onForeground');
  }

  onBackground(): void {
    // Ability has back to background
    hilog.info(DOMAIN, 'testTag', '%{public}s', 'Ability onBackground');
  }
}
