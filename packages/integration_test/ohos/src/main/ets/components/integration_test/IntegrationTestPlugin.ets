/**
 * Copyright 2014 The Flutter Authors. All rights reserved.
 * Use of this source code is governed by a BSD-style license that can be
 * found in the LICENSE file.
 *
 */
 
import {
  AbilityAware,
  AbilityPluginBinding,
  BinaryMessenger,
  FlutterPlugin,
  FlutterPluginBinding,
  Log,
  MethodCall,
  MethodCallHandler,
  MethodChannel,
  MethodResult,
} from '@ohos/flutter_ohos';
import UIAbility from '@ohos.app.ability.UIAbility';

const TAG = "IntegrationTestPlugin"

export default class IntegrationTestPlugin implements MethodCallHandler, FlutterPlugin, AbilityAware {
  private static CHANNEL: string = "plugins.flutter.io/integration_test";
  private methodChannel: MethodChannel | null = null;
  private flutterAbility: UIAbility | null = null;
  private static testResultsSetter: Set<Map<String, String>>;

  getUniqueClassName(): string {
    return 'IntegrationTestPlugin';
  }

  private methodCall: MethodCallHandler = {
    onMethodCall(call: MethodCall, result: MethodResult) {
      Log.w(TAG, 'flutter onMethodCall: 11 ' + JSON.stringify(call));
      switch (call.method) {
        case "allTestsFinished":
          IntegrationTestPlugin.testResultsSetter.add(call.argument("results"));
          result.success(null);
          return;
        case "captureScreenshot":
        case "convertFlutterSurfaceToImage":
        case "revertFlutterImage":
        default:
          result.notImplemented();
      }
    }
  };

  private attachedToEngine( unusedApplicationContext: Context,  messenger: BinaryMessenger): void {
    Log.w(TAG, 'flutter IntegrationTestPlugin attachedToEngine');
    this.methodChannel = new MethodChannel(messenger, IntegrationTestPlugin.CHANNEL);
    this.methodChannel.setMethodCallHandler(this.methodCall);
  }

  onAttachedToEngine(binding: FlutterPluginBinding) {
    this.attachedToEngine(binding.getApplicationContext(), binding.getBinaryMessenger());
  }

  onMethodCall(call: MethodCall, result: MethodResult) {
    Log.w(TAG, 'flutter onMethodCall:' + JSON.stringify(call));
    switch (call.method) {
      case "allTestsFinished":
        IntegrationTestPlugin.testResultsSetter.add(call.argument("results"));
        result.success(null);
        return;
      case "convertFlutterSurfaceToImage":
      case "revertFlutterImage":
      case "captureScreenshot":
      default:
        result.notImplemented();
    }
  }

  onDetachedFromEngine(binding: FlutterPluginBinding) {
    Log.w(TAG, 'flutter IntegrationTestPlugin onDetachedFromEngine');
    this.methodChannel?.setMethodCallHandler(null);
    this.methodChannel = null;
  }

  onAttachedToAbility(binding: AbilityPluginBinding) {
    Log.w(TAG, 'flutter IntegrationTestPlugin onAttachedToAbility');
    this.flutterAbility = binding.getAbility();
  }

  onDetachedFromAbility() {
    Log.w(TAG, 'flutter IntegrationTestPlugin onDetachedFromAbility');
    this.flutterAbility = null;
  }
}