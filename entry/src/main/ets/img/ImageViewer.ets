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


import { common } from '@kit.AbilityKit';
import { ImageModel } from './CommonModel';
import { windowSizeManager } from './CommonUtils';


const TAG: string = '[ImageItemView]';

/**
 * ImageItemView
 * @link https://gitee.com/harmonyos_samples/PicturePreview
 */
@ComponentV2
export struct ImageItemView {
  @Require @Param imageData: PixelMap | ResourceStr | DrawableDescriptor;
  @Param imageModel: ImageModel = new ImageModel();
  // Whether to display the picture toolbar
  @Require @Param isOverlay: boolean;
  @Event $isOverlay:(val:boolean)=>void = (val:boolean)=>{}
  // Swipe whether to switch
  @Require @Param isDisableSwipe: boolean;
  @Event $isDisableSwipe:(val:boolean)=>void = (val:boolean)=>{}
  @Require @Param isImageReset: boolean;
  @Require @Param bgc: Color;
  private context: common.UIAbilityContext = getContext(this) as common.UIAbilityContext;
  // Image original aspect ratio
  private imageWHRatio: number = 0;

  aboutToAppear(): void {
    this.imageModel.windowSize();
  }

  // When switching images, reset the previous image
  @Monitor('isImageReset')
  onImageReset(): void {
    if (this.isImageReset) {
      this.imageModel.imageReset();
    }
  }


  build() {
    Stack() {
      Image(this.imageData)
        .width(this.imageModel.imageWidth)
        .height(this.imageModel.imageHeight)
        .aspectRatio(this.imageWHRatio)
        .objectFit(ImageFit.Cover)
        .autoResize(false)
        .defaultFocus(true)
        .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
        .transform(this.imageModel.matrix)// Control picture scaling with matrix
        .translate({
          x: this.imageModel.curOffsetX,
          y: this.imageModel.curOffsetY
        })
        .onComplete((e) => {
          if (e) {
            /**
             * Set information about the current image: uri, whRatio, pixelMap, defaultSize, maxScaleValue
             * Obtain the Image information in advance for the size setting of
             * the image component and subsequent related calculations
             */
            this.imageWHRatio = e.width / e.height
            this.imageModel.imageWidth = this.imageModel.componentWidth
            this.imageModel.imageHeight = this.imageModel.imageWidth / this.imageWHRatio
          }
          this.imageModel.maxScale = this.imageModel.calcFitScaleRatio({
            width: this.imageModel.imageWidth,
            height: this.imageModel.imageHeight
          }, windowSizeManager.get());
        })
    }
    .backgroundColor(this.bgc)
    .alignContent(Alignment.Center)
    .expandSafeArea([SafeAreaType.SYSTEM], [SafeAreaEdge.TOP, SafeAreaEdge.BOTTOM])
    .width('100%')
    .height('100%')
    .parallelGesture(
      GestureGroup(
        GestureMode.Exclusive,
        // Slide picture
        // Swiping left and right under the default size should switch images
        PanGesture({ fingers: 1, distance: this.isDisableSwipe ? 3 : 50 })
          .onActionUpdate((event: GestureEvent) => {
            this.$isDisableSwipe(this.imageModel.panGestureUpdate(event));
          })
          .onActionEnd(() => {
            this.imageModel.gestureEnd();
          }),
        // Two-finger scaling
        PinchGesture({ fingers: 2, distance: 1 })
          .onActionStart((event: GestureEvent) => {
            this.imageModel.pinchGestureStart(event);
          })
          .onActionUpdate((event: GestureEvent) => {
            this.$isDisableSwipe(this.imageModel.pinchGestureUpdate(event));
          })
          .onActionEnd(() => {
            this.imageModel.pinchGestureEnd();
          }),
        // Double click picture
        TapGesture({ count: 2 })
          .onAction((event: GestureEvent) => {
            this.$isDisableSwipe(this.imageModel.doubleTapGesture(event)) ;
          }),
        // Click Switch picture toolbar
        TapGesture({ count: 1 })
          .onAction(() => {
            this.$isOverlay(!this.isOverlay);
          })
        // Pinching and scaling images with two fingers
      ), GestureMask.Normal
    )
  }
}