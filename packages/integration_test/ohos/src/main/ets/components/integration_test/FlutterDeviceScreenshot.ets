/**
 * Copyright (c) 2023 Huawei Device Co., Ltd.
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
import {
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import UIAbility from '@ohos.app.ability.UIAbility';

/**
 * FlutterDeviceScreenshot is a utility class that allows to capture a screenshot
 * that includes both Ohos views and the Flutter UI.
 *
 * To take screenshots, the rendering surface must be changed to {@code FlutterImageView},
 * since surfaces like {@code FlutterSurfaceView} and {@code FlutterTextureView} are opaque
 * when the view hierarchy is rendered to a bitmap.
 *
 * It's also necessary to ask the framework to schedule a frame, and then add a listener
 * that waits for that frame to be presented by the Ohos framework.
 */
export class FlutterDeviceScreenshot {

  /**
   * Whether the app is run with instrumentation.
   *
   * @return true if the app is running with instrumentation.
   */
  static hasInstrumentation(): boolean {
    // TODO(egarciad): InstrumentationRegistry requires the uiautomator dependency.
    // However, Flutter adds test dependencies to release builds.
    // As a result, disable screenshots with instrumentation until the issue is fixed.
    // https://github.com/flutter/flutter/issues/56591
    return false;
  }

  // static flutterSurfaceConvertedToImageb = false;

  // Whether the flutter surface is already converted to an image.
  private static flutterSurfaceConvertedToImage: boolean = false;

  /**
   * Converts the Flutter surface to an image view.
   * This allows to render the view hierarchy to a bitmap since
   * {@code FlutterSurfaceView} and {@code FlutterTextureView} cannot be rendered to a bitmap.
   *
   * @param activity typically {@code FlutterActivity}.
   */
  static convertFlutterSurfaceToImage(ability: UIAbility): void {
  }

  /**
   * Restores the original Flutter surface.
   * The new surface will either be {@code FlutterSurfaceView} or {@code FlutterTextureView}.
   *
   * @param activity typically {@code FlutterActivity}.
   * @param onDone callback called once the surface has been restored.
   */
  static revertFlutterImage(ability: UIAbility): void {
  }

  /**
   * Captures a screenshot by drawing the view to a Canvas.
   *
   * <p> {@code convertFlutterSurfaceToImage} must be called prior to capturing the view,
   * otherwise the result is an error.
   *
   * @param activity this is {@link FlutterActivity}.
   * @param methodChannel the method channel to call into Dart.
   * @param result the result for the method channel that will contain the byte array.
   */
  static captureView(ability: UIAbility, methodChannel: MethodChannel, result: MethodResult): void {
  }
}
