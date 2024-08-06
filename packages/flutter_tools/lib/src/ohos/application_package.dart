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

import 'package:json5/json5.dart';
import 'package:process/process.dart';

import '../application_package.dart';
import '../base/common.dart';
import '../base/file_system.dart';
import '../base/logger.dart';
import '../base/process.dart';
import '../base/user_messages.dart';
import '../build_info.dart';
import '../globals.dart' as globals;
import '../project.dart';
import 'ohos_plugins_manager.dart';
import 'ohos_sdk.dart';

const String OHOS_ENTRY_DEFAULT = 'entry';
const int OHOS_SDK_INT_DEFAULT = 11;

/// An application package created from an already built Ohos HAP.
class OhosHap extends ApplicationPackage implements PrebuiltApplicationPackage {
  OhosHap({
    required super.id,
    required this.applicationPackage,
    required this.ohosBuildData,
  })  : assert(applicationPackage != null),
        assert(ohosBuildData != null);

  @override
  final FileSystemEntity applicationPackage;

  OhosBuildData ohosBuildData;

  @override
  String? get name => applicationPackage.basename;

  /// Creates a new OhosHap based on the information in the Ohos build-profile.
  static Future<OhosHap?> fromOhosProject(
    OhosProject ohosProject, {
    required HarmonySdk? ohosSdk,
    required ProcessManager processManager,
    required UserMessages userMessages,
    required ProcessUtils processUtils,
    required Logger logger,
    required FileSystem fileSystem,
    BuildInfo? buildInfo,
  }) async {
    /// parse the build data
    final OhosBuildData ohosBuildData =
        OhosBuildData.parseOhosBuildData(ohosProject, logger);
    final String bundleName = ohosBuildData.appInfo!.bundleName;
    return OhosHap(
        id: bundleName,
        applicationPackage: ohosProject.getSignedHapFile(),
        ohosBuildData: ohosBuildData);
  }

  static Future<OhosHap?> fromHap(
    File hap, {
    required HarmonySdk ohosSdk,
    required ProcessManager processManager,
    required UserMessages userMessages,
    required Logger logger,
    required ProcessUtils processUtils,
  }) async {
    // TODO(xc)  parse build data from hap file
    return null;
  }
}

/// OpenHarmony的构建信息
class OhosBuildData {
  OhosBuildData(this.appInfo, this.moduleInfo, this.apiVersion);

  late AppInfo? appInfo;
  late ModuleInfo moduleInfo;
  late int apiVersion;

  bool get hasEntryModule => false;

  List<OhosModule> get harModules {
    return moduleInfo.moduleList
        .where((OhosModule e) => e.type == OhosModuleType.har)
        .toList();
  }

  static OhosBuildData parseOhosBuildData(
      OhosProject ohosProject, Logger? logger) {
    late AppInfo appInfo;
    late ModuleInfo moduleInfo;
    late int apiVersion;
    try {
      final File appJson = ohosProject.getAppJsonFile();
      if (appJson.existsSync()) {
        final String json = appJson.readAsStringSync();
        final dynamic obj = JSON5.parse(json);
        appInfo = AppInfo.getAppInfo(obj);
      } else {
        appInfo = AppInfo('', 0, '');
      }
    } on Exception catch (err) {
      throwToolExit('Parse ohos app.json5 error: $err');
    }

    try {
      moduleInfo = ModuleInfo.getModuleInfo(ohosProject);
    } on Exception catch(err) {
      throwToolExit('Parse ohos module.json5 error: $err');
    }

    try {
      apiVersion = getApiVersion(ohosProject.getBuildProfileFile());
    } on Exception catch(err) {
      throwToolExit('Parse ohos build-profile.json5 error: $err');
    }
    return OhosBuildData(appInfo, moduleInfo, apiVersion);
  }
}

int getApiVersion(File buildProfile) {
  if (!buildProfile.existsSync()) {
    return OHOS_SDK_INT_DEFAULT;
  }
  final String buildProfileConfig = buildProfile.readAsStringSync();
  final dynamic obj = JSON5.parse(buildProfileConfig);
  dynamic sdkObj = obj['app']['compatibleSdkVersion'];
  sdkObj ??= obj['app']['products'][0]['compatibleSdkVersion'];
  if (sdkObj is int) {
    return sdkObj;
  } else if (sdkObj is String && sdkObj != null) { // 4.1.0(11)
    String? str = RegExp(r'\(\d+\)').stringMatch(sdkObj);
    if (str != null) {
      str = str.substring(1, str.length - 1);
      return int.parse(str);
    }
  }
  return OHOS_SDK_INT_DEFAULT;
}

class AppInfo {
  AppInfo(this.bundleName, this.versionCode, this.versionName);

  late String bundleName;
  late int versionCode;
  late String versionName;

  static AppInfo getAppInfo(dynamic app) {
    final String bundleName = app['app']['bundleName'] as String;
    final int versionCode = app['app']['versionCode'] as int;
    final String versionName = app['app']['versionName'] as String;
    return AppInfo(bundleName, versionCode, versionName);
  }
}

class ModuleInfo {
  ModuleInfo(this.moduleList);

  List<OhosModule> moduleList;

  bool get hasEntryModule =>
      moduleList.any((OhosModule element) => element.isEntry);

  OhosModule? get entryModule => hasEntryModule
      ? moduleList.firstWhere((OhosModule element) => element.isEntry)
      : null;

  String? get mainElement => entryModule?.mainElement;

  /// 获取主要的module名，如果存在entry，返回entry类型的module，否则返回第一个module
  String get mainModuleName =>
      entryModule?.name ??
      (moduleList.isNotEmpty ? moduleList.first.name : OHOS_ENTRY_DEFAULT);

  /// 获取主要的module路径，如果存在entry，返回entry类型的module，否则返回第一个module
  String get mainModuleSrcPath =>
      entryModule?.srcPath ??
      (moduleList.isNotEmpty ? moduleList.first.srcPath : OHOS_ENTRY_DEFAULT);

  static ModuleInfo getModuleInfo(OhosProject ohosProject) {
    return ModuleInfo(OhosModule.fromOhosProject(ohosProject));
  }
}

enum OhosModuleType {
  entry,
  har,
  shared,
  unknown;

  static OhosModuleType fromName(String name) {
    return OhosModuleType.values.firstWhere(
        (OhosModuleType element) => element.name == name,
        orElse: () => OhosModuleType.unknown);
  }
}

class OhosModule {
  OhosModule({
    required this.name,
    required this.srcPath,
    required this.isEntry,
    required this.mainElement,
    required this.type,
  });

  final String name;
  final bool isEntry;
  final String? mainElement;
  final OhosModuleType type;
  final String srcPath;

  static List<OhosModule> fromOhosProject(OhosProject ohosProject) {
    final File buildProfileFile = ohosProject.ohosRoot.childFile('build-profile.json5');
    if (!buildProfileFile.existsSync()) {
      return <OhosModule>[];
    }
    final Map<String, dynamic> buildProfile = JSON5.parse(buildProfileFile.readAsStringSync()) as Map<String, dynamic>;
    final List<dynamic> modules = buildProfile['modules'] as List<dynamic>;
    return modules.map((dynamic e) {
      final Map<String, dynamic> module = e as Map<String, dynamic>;
      final String srcPath = module['srcPath'] as String;
      return OhosModule._fromModulePath(ohosProject, globals.fs.path.join(ohosProject.ohosRoot.path, srcPath));
    }).toList();
  }

  static OhosModule _fromModulePath(OhosProject ohosProject, String srcPath) {
    final String moduleJsonPath = globals.fs.path.join(srcPath, 'src', 'main', 'module.json5');
    final File moduleJsonFile = globals.fs.file(moduleJsonPath);
    if (!moduleJsonFile.existsSync()) {
      throwToolExit('Can not found module.json5 at $moduleJsonPath . \n'
        '  You need to update the Flutter plugin project structure. \n'
        '  See https://gitee.com/openharmony-sig/flutter_samples/tree/master/ohos/docs/09_specifications/update_flutter_plugin_structure.md');
    }
    try {
      final Map<String, dynamic> moduleJson = JSON5.parse(moduleJsonFile.readAsStringSync()) as Map<String, dynamic>;
      final Map<String, dynamic> module = (moduleJson['module'] as Map<dynamic, dynamic>).cast();
      final String name = module['name'] as String;
      final String type = module['type'] as String;
      final bool isEntry = type == OhosModuleType.entry.name;
      return OhosModule(
          name: name,
          srcPath: srcPath,
          isEntry: isEntry,
          mainElement: isEntry ? module['mainElement'] as String : null,
          type: OhosModuleType.fromName(type));
    } on Exception catch (e) {
      throwToolExit('parse module.json5 error , $moduleJsonPath . error: $e');
    }
  }
}
