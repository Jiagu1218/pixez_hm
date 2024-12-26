import { AbilityConstant, ConfigurationConstant, UIAbility, Want } from '@kit.AbilityKit';
import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';
import { webview } from '@kit.ArkWeb';
import { connection } from '@kit.NetworkKit';
import { ImageUtil } from '../network/util/ImageUtli';
import { SessionPoolNew } from '../network/pool/SessionPoolNew';
import { SessionManager } from '../network/pool/SessionManager';

export default class EntryAbility extends UIAbility {
  onCreate(want: Want, launchParam: AbilityConstant.LaunchParam): void {
    this.context.getApplicationContext().setColorMode(ConfigurationConstant.ColorMode.COLOR_MODE_NOT_SET);
    try {
      // webview.WebviewController.setHttpDns(webview.SecureDnsMode.SECURE_ONLY,'https://max.rethinkdns.com/dns-query')
      // connection.setAppHttpProxy({
      //   host: '127.0.0.1',
      //   port: 7987,
      //   exclusionList: []
      // })
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
    // 初始化链接
    // SessionPoolNew.init()
    SessionManager.init()
    ImageUtil.init(this.context)
    windowStage.loadContent('pages/Index', (err) => {
      if (err.code) {
        hilog.error(0x0000, 'testTag', 'Failed to load the content. Cause: %{public}s', JSON.stringify(err) ?? '');
        return;
      }
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

  onBackground(): void {
    // Ability has back to background
    hilog.info(0x0000, 'testTag', '%{public}s', 'Ability onBackground');
  }
}