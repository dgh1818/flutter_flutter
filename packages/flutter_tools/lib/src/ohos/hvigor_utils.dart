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
import 'dart:convert';

import 'package:json5/json5.dart';

import '../base/common.dart';
import '../base/file_system.dart';

import '../base/logger.dart';
import '../base/os.dart';
import '../base/platform.dart';
import '../base/utils.dart';
import '../base/version.dart';
import '../build_info.dart';
import '../cache.dart';
import '../globals.dart' as globals;
import '../project.dart';
import '../reporting/reporting.dart';
import 'ohos_sdk.dart';

const String FLAVOR_DEFAULT = 'default';
const String BUILD_NUMBER_DEFAULT = '1000000';
const String BUILD_NAME_DEFAULT = '1.0.0';

class HvigorUtils {}

/// Overwrite local.properties in the specified Flutter project's Harmony
/// sub-project, if needed.
///
/// If [requireHarmonySdk] is true (the default) and no Harmony SDK is found,
/// this will fail with a [ToolExit].
void updateLocalProperties({
  required FlutterProject project,
  BuildInfo? buildInfo,
  bool requireHarmonySdk = true,
}) {
  if (requireHarmonySdk && globals.hmosSdk == null) {
    exitWithNoSdkMessage();
  }
  final File localProperties = project.ohos.localPropertiesFile;
  bool changed = false;

  SettingsFile settings;
  if (localProperties.existsSync()) {
    settings = SettingsFile.parseFromFile(localProperties);
  } else {
    settings = SettingsFile();
    changed = true;
  }

  void changeIfNecessary(String key, String? value) {
    if (settings.values[key] == value) {
      return;
    }
    if (value == null) {
      settings.values.remove(key);
    } else {
      settings.values[key] = value;
    }
    changed = true;
  }

  final HmosSdk? hmosSdk = globals.hmosSdk;
  if (hmosSdk != null) {
    changeIfNecessary('hwsdk.dir', globals.fsUtils.escapePath(hmosSdk.sdkPath));
  }
  final String? nodeHome = globals.platform.environment['NODE_HOME'];
  if (nodeHome != null) {
    changeIfNecessary('nodejs.dir', globals.fsUtils.escapePath(nodeHome));
  }

  if (changed) {
    settings.writeContents(localProperties);
  }
  if (project.ohos.isRunWithModuleHar) {
    settings.writeContents(project.ohos.ephemeralLocalPropertiesFile);
  }
}

/// Writes standard Ohos local properties to the specified [properties] file.
///
/// Writes the path to the Ohos SDK, if known.
void writeLocalProperties(File properties) {
  final SettingsFile settings = SettingsFile();
  final HmosSdk? hmosSdk = globals.hmosSdk;
  if (hmosSdk != null) {
    settings.values['hwsdk.dir'] = globals.fsUtils.escapePath(hmosSdk.sdkPath);
  }
  final String? nodeHome = globals.platform.environment['NODE_HOME'];
  if (nodeHome != null) {
    settings.values['nodejs.dir'] = nodeHome;
  }
  settings.writeContents(properties);
}

void exitWithNoSdkMessage() {
  BuildEvent('unsupported-project',
          type: 'hvigor',
          eventError: 'hos-sdk-not-found',
          flutterUsage: globals.flutterUsage)
      .send();
  throwToolExit('${globals.logger.terminal.warningMark} No Hmos SDK found. '
      'Try setting the HOS_SDK_HOME environment variable.');
}

String getFlavor(File buildProfileFile, String? flavor) {
  if (flavor == null) {
    return FLAVOR_DEFAULT;
  }
  if (buildProfileFile.existsSync()) {
    final Map<String, dynamic> config = JSON5
        .parse(buildProfileFile.readAsStringSync()) as Map<String, dynamic>;
    final List<dynamic> targetList;
    // ignore: avoid_dynamic_calls
    if (config['app'] != null && config['app']['products'] != null) {
      // ohos/build-profile.json5
      // ignore: avoid_dynamic_calls
      targetList = config['app']['products'] as List<dynamic>;
    } else if (config['targets'] != null) {
      // ohos/entry/build-profile.json5
      targetList = config['targets'] as List<dynamic>;
    } else {
      // ignore: always_specify_types
      targetList = [];
    }
    for (final dynamic item in targetList) {
      final Map<String, dynamic> map = item as Map<String, dynamic>;
      if (flavor == (map['name'] as String)) {
        return flavor;
      }
    }
  }
  globals.logger.printWarning(
      'Flavor "$flavor" not exists in file ${buildProfileFile.path}, use "$FLAVOR_DEFAULT" instead.');
  return FLAVOR_DEFAULT;
}

void updateProjectVersion(FlutterProject project, BuildInfo? buildInfo) {
  final File targetFile = project.ohos.getAppJsonFile();
  if (targetFile.existsSync() && buildInfo != null) {
    final String? buildNumber = validatedBuildNumberForPlatform(
      TargetPlatform.ohos_arm,
      buildInfo.buildNumber,
      globals.logger,
    );
    final String? buildName = validatedBuildNameForPlatform(
      TargetPlatform.ohos_arm,
      buildInfo.buildName,
      globals.logger,
    );

    final Map<String, dynamic> config =
        JSON5.parse(targetFile.readAsStringSync()) as Map<String, dynamic>;
    if (config['app'] != null) {
      final Map<String, dynamic> map = config['app'] as Map<String, dynamic>;
      if (buildNumber != null) {
        map['versionCode'] = int.parse(buildNumber);
      }
      if (buildName != null) {
        map['versionName'] = buildName;
      }
      final String configNew =
          const JsonEncoder.withIndent('  ').convert(config);
      targetFile.writeAsStringSync(configNew, flush: true);
    }
  }
}
