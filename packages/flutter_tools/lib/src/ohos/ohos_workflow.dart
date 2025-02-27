/*
* Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
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
