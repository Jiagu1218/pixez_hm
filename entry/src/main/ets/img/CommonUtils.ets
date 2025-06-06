/*
 * Copyright (c) 2024 Huawei Device Co., Ltd.
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import { hilog } from '@kit.PerformanceAnalysisKit';
import { window } from '@kit.ArkUI';

const TAG: string = '[CommonUtils]';

/**
 * Animate the execution of a function
 * @param fn：Callback functions to be executed within the animation, usually fn will change the state variable
 * @param duration：Animation duration
 * @param curve：Animation area line
 */
export function runWithAnimation(
  fn: Function,
  duration: number = 300, // Scale the duration of the animation
  curve: Curve = Curve.Smooth): void {
  animateTo({ duration: duration, curve: curve }, () => {
    fn();
  });
}

class WindowSizeManager {
  private size: window.Size = { width: 0, height: 0 };

  constructor() {
    window.getLastWindow(getContext()).then((value: window.Window) => {
      const rect: window.Rect = value.getWindowProperties().windowRect;
      this.size.width = px2vp(rect.width);
      this.size.height = px2vp(rect.height);
      hilog.info(0x0000, TAG, `[windowWidth]${this.size.width} [windowHeight]${this.size.height}`);
    });
  }

  get(): window.Size {
    return this.size;
  }
}

export const windowSizeManager: WindowSizeManager = new WindowSizeManager();