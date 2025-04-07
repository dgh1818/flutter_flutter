/*
* Copyright 2014 The Flutter Authors. All rights reserved.
* Use of this source code is governed by a BSD-style license that can be
* found in the LICENSE file.
*/

import '../base/context.dart';
import '../doctor_validator.dart';
import '../features.dart';
import 'ohos_sdk.dart';

OhosWorkflow? get ohosWorkflow => context.get<OhosWorkflow>();

class OhosWorkflow implements Workflow {
  OhosWorkflow({
    required HarmonySdk? ohosSdk,
    required FeatureFlags featureFlags,
  })  : _ohosSdk = ohosSdk,
        _featureFlags = featureFlags;

  final HarmonySdk? _ohosSdk;
  final FeatureFlags _featureFlags;

  @override
  bool get appliesToHostPlatform => _featureFlags.isOhosEnabled;

  @override
  bool get canListDevices =>
      appliesToHostPlatform && _ohosSdk != null && _ohosSdk?.hdcPath != null;

  @override
  bool get canLaunchDevices =>
      appliesToHostPlatform && _ohosSdk != null && _ohosSdk?.hdcPath != null;

  @override
  bool get canListEmulators => canListDevices;
      //&& _ohosSdk?.emulatorPath != null;
}
