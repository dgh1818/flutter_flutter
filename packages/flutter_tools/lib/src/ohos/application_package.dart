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
import 'hvigor_utils.dart';
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
    final String flavor = getFlavor(ohosProject.getBuildProfileFile(), buildInfo?.flavor);
    String bundleName = ohosBuildData.appInfo!.bundleName;
    final List<dynamic>? products = ohosBuildData.products;
    if (products != null) {
      for (final dynamic item in products) {
        final Map<String, dynamic> productItem = item as Map<String, dynamic>;
        if (flavor == productItem['name'] && productItem['bundleName'] != null) {
          bundleName = productItem['bundleName'] as String;
          ohosBuildData.appInfo!.bundleName = bundleName;
          break;
        }
      }
    }
    for (final OhosModule element in ohosBuildData.moduleInfo.moduleList) {
      element.flavor = flavor;
    }
    return OhosHap(
        id: bundleName,
        applicationPackage: ohosProject.getSignedHapFile(flavor),
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
  OhosBuildData(this.appInfo, this.moduleInfo, this.apiVersion, this.products);

  late AppInfo? appInfo;
  late ModuleInfo moduleInfo;
  late int apiVersion;
  List<dynamic>? products;

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
    List<dynamic>? products;
    try {
      final File appJson = ohosProject.getAppJsonFile();
      if (appJson.existsSync()) {
        final String json = appJson.readAsStringSync();
        final dynamic obj = JSON5.parse(json);
        appInfo = AppInfo.getAppInfo(obj);
      } else {
        appInfo = AppInfo('', 1, '');
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
      final File buildProfileFile = ohosProject.getBuildProfileFile();
      if (buildProfileFile.existsSync()) {
        final String buildProfileConfig = buildProfileFile.readAsStringSync();
        final dynamic obj = JSON5.parse(buildProfileConfig);
        apiVersion = getApiVersion(obj);
        // ignore: avoid_dynamic_calls
        if (obj['app'] != null && obj['app']['products'] != null) {
          // ignore: avoid_dynamic_calls
          products = obj['app']['products'] as List<dynamic>;
        }
      } else {
        apiVersion = OHOS_SDK_INT_DEFAULT;
      }
    } on Exception catch (err) {
      throwToolExit('Parse ohos build-profile.json5 error: $err');
    }
    return OhosBuildData(appInfo, moduleInfo, apiVersion, products);
  }
}

int getApiVersion(dynamic obj) {
  // ignore: avoid_dynamic_calls
  dynamic sdkObj = obj['app']?['compatibleSdkVersion'];
  // ignore: avoid_dynamic_calls
  sdkObj ??= obj['app']?['products'][0]['compatibleSdkVersion'];
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
    required this.flavor,
  });

  final String name;
  final bool isEntry;
  final String? mainElement;
  final OhosModuleType type;
  final String srcPath;
  String flavor;

  static List<OhosModule> fromOhosProject(OhosProject ohosProject) {
    final File buildProfileFile = ohosProject.ohosRoot.childFile('build-profile.json5');
    if (!buildProfileFile.existsSync()) {
      return <OhosModule>[];
    }
    final Map<String, dynamic> buildProfile = JSON5.parse(buildProfileFile.readAsStringSync()) as Map<String, dynamic>;
    if (!buildProfile.containsKey('modules')) {
      return <OhosModule>[];
    }
    final List<dynamic> modules = buildProfile['modules'] as List<dynamic>;
    return modules.map((dynamic e) {
      final Map<String, dynamic> module = e as Map<String, dynamic>;
      final String srcPath = module['srcPath'] as String;
      return OhosModule.fromModulePath(
        modulePath: globals.fs.path.join(ohosProject.ohosRoot.path, srcPath));
    }).toList();
  }

  static OhosModule fromModulePath({
    required String modulePath,
    String? flavor,
  }) {
    final String moduleJsonPath = globals.fs.path.join(modulePath, 'src', 'main', 'module.json5');
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
          srcPath: modulePath,
          isEntry: isEntry,
          mainElement: isEntry ? module['mainElement'] as String : null,
          type: OhosModuleType.fromName(type),
          flavor: flavor ?? FLAVOR_DEFAULT);

    } on Exception catch (e) {
      throwToolExit('parse module.json5 error , $moduleJsonPath . error: $e');
    }
  }
}
