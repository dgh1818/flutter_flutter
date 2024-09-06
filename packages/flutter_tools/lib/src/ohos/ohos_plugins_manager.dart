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
import '../flutter_plugins.dart';
import '../globals.dart' as globals;
import '../platform_plugins.dart';
import '../plugins.dart';
import '../project.dart';

/// 检查 ohos plugin 依赖
Future<void> checkOhosPluginsDependencies(FlutterProject flutterProject) async {
  final List<Plugin> plugins = (await findPlugins(flutterProject))
      .where((Plugin p) => p.platforms.containsKey(OhosPlugin.kConfigKey))
      .toList();
  final File packageFile = flutterProject.ohos.flutterModulePackageFile;
  if (!packageFile.existsSync()) {
    globals.logger.printTrace('check if oh-package.json5 file:($packageFile) exist ?');
    return;
  }

  final String packageConfig = packageFile.readAsStringSync();
  final Map<String, dynamic> config = JSON5.parse(packageConfig) as Map<String, dynamic>;
  final Map<String, dynamic> dependencies =
      config['dependencies'] as Map<String, dynamic>;
  final List<String> removeList = <String>[];
  for (final Plugin plugin in plugins) {
    for (final String key in dependencies.keys) {
      if (key.startsWith('@ohos') && key.contains(plugin.name)) {
        removeList.add(key);
      }
    }
    final String absolutePath = globals.fs.path.join(flutterProject.ohos.ohosRoot.path, 'har/${plugin.name}.har');
    if (flutterProject.isModule) {
      dependencies[plugin.name] = 'file:$absolutePath';
    } else {
      final String relativePath = _relative(absolutePath, from: globals.fs.path.dirname(packageFile.path));
      dependencies[plugin.name] = 'file:$relativePath';
    }
  }
  for (final String key in removeList) {
    globals.printStatus(
        'OhosDependenciesManager: deprecated plugin dependencies "$key" has been removed.');
    dependencies.remove(key);
  }
  final String configNew = const JsonEncoder.withIndent('  ').convert(config);
  packageFile.writeAsStringSync(configNew, flush: true);
}

/// 添加到工程级 build-profile.json5 的 modules 中
Future<void> addPluginsModules(FlutterProject flutterProject) async {
  final List<Plugin> plugins = (await findPlugins(flutterProject))
      .where((Plugin p) => p.platforms.containsKey(OhosPlugin.kConfigKey))
      .toList();
  if (plugins.isEmpty) {
    return;
  }
  final File buildProfileFile = flutterProject.ohos.getBuildProfileFile();
  if (!buildProfileFile.existsSync()) {
    throwToolExit('check if build-profile.json5 file:($buildProfileFile) exist ?');
  }
  final String packageConfig = buildProfileFile.readAsStringSync();
  final Map<String, dynamic> buildProfile = JSON5.parse(packageConfig) as Map<String, dynamic>;
  final List<Map<dynamic, dynamic>> modules = (buildProfile['modules'] as List<dynamic>).cast();
  final Map<String, dynamic> modulesMap = Map<String, dynamic>.fromEntries(modules.map((e) => MapEntry(e['name'] as String, e)));
  for (final Plugin plugin in plugins) {
    if (modulesMap.containsKey(plugin.name)) {
      continue;
    }
    modules.add(<String, dynamic>{
      'name': plugin.name,
      'srcPath': _relative(
        globals.fs.path.join(plugin.path, OhosPlugin.kConfigKey),
        from: flutterProject.ohos.ohosRoot.path,
      ),
      'targets': <Map<String, dynamic>>[
        <String, dynamic>{
          'name': 'default',
          'applyToProducts': <dynamic>['default']
        }
      ],
    });
  }
  final String buildProfileNew = const JsonEncoder.withIndent('  ').convert(buildProfile);
  buildProfileFile.writeAsStringSync(buildProfileNew, flush: true);
}

/// 在工程级的的oh-package.json5里添加flutter_module以及plugins的配置
Future<void> addFlutterModuleAndPluginsSrcOverrides(FlutterProject flutterProject) async {
  final List<Plugin> plugins = (await findPlugins(flutterProject))
      .where((Plugin p) => p.platforms.containsKey(OhosPlugin.kConfigKey))
      .toList();
  if (plugins.isEmpty) {
    return;
  }
  final File packageFile = flutterProject.ohos.ohosRoot.childFile('oh-package.json5');
  if (!packageFile.existsSync()) {
    globals.logger.printTrace('check if oh-package.json5 file:($packageFile) exist ?');
    return;
  }
  final String packageConfig = packageFile.readAsStringSync();
  final Map<String, dynamic> config = JSON5.parse(packageConfig) as Map<String, dynamic>;
  final Map<String, dynamic> overrides = config['overrides'] as Map<String, dynamic>? ?? <String, dynamic>{};

  for (final Plugin plugin in plugins) {
    overrides[plugin.name] = _relative(
      globals.fs.path.join(plugin.path, OhosPlugin.kConfigKey),
      from: flutterProject.ohos.ohosRoot.path,
    );
  }
  final String relativePath = _relative(flutterProject.ohos.flutterModuleDirectory.path, from: flutterProject.ohos.ohosRoot.path);
  overrides['@ohos/flutter_module'] = 'file:./$relativePath';
  overrides['@ohos/flutter_ohos'] = 'file:./har/flutter.har';
  final String configNew = const JsonEncoder.withIndent('  ').convert(config);
  packageFile.writeAsStringSync(configNew, flush: true);
}

/// 添加到工程级 build-profile.json5 的 modules 中
Future<void> removePluginsModules(FlutterProject flutterProject) async {
  final List<Plugin> plugins = (await findPlugins(flutterProject))
      .where((Plugin p) => p.platforms.containsKey(OhosPlugin.kConfigKey))
      .toList();
  if (plugins.isEmpty) {
    return;
  }
  final Map<String, Plugin> pluginsMap = Map<String, Plugin>.fromEntries(
    plugins.map((Plugin e) => MapEntry<String, Plugin>(e.name, e))
  );
  final File buildProfileFile = flutterProject.ohos.getBuildProfileFile();
  if (!buildProfileFile.existsSync()) {
    globals.logger.printTrace('check if build-profile.json5 file:($buildProfileFile) exist ?');
    return;
  }
  final String packageConfig = buildProfileFile.readAsStringSync();
  final Map<String, dynamic> buildProfile = JSON5.parse(packageConfig) as Map<String, dynamic>;
  final List<Map<dynamic, dynamic>> modules = (buildProfile['modules'] as List<dynamic>).cast();
  final List<Map<dynamic, dynamic>> newModules = <Map<dynamic, dynamic>>[];

  for (final Map<dynamic, dynamic> module in modules) {
    if (pluginsMap.containsKey(module['name'])) {
      continue;
    } else {
      newModules.add(module);
    }
  }
  buildProfile['modules'] = newModules;
  final String buildProfileNew = const JsonEncoder.withIndent('  ').convert(buildProfile);
  buildProfileFile.writeAsStringSync(buildProfileNew, flush: true);
}

/// 把flutter_module跟plugins的依赖写入工程级oh-package.json5里的overrides
Future<void> addFlutterModuleAndPluginsOverrides(FlutterProject flutterProject) async {
  final List<Plugin> plugins = (await findPlugins(flutterProject))
      .where((Plugin p) => p.platforms.containsKey(OhosPlugin.kConfigKey))
      .toList();
  if (plugins.isEmpty) {
    return;
  }
  final File packageFile = flutterProject.ohos.ohosRoot.childFile('oh-package.json5');
  if (!packageFile.existsSync()) {
    globals.logger.printTrace('check if oh-package.json5 file:($packageFile) exist ?');
    return;
  }
  final String packageConfig = packageFile.readAsStringSync();
  final Map<String, dynamic> config = JSON5.parse(packageConfig) as Map<String, dynamic>;
  final Map<String, dynamic> overrides = config['overrides'] as Map<String, dynamic>? ?? <String, dynamic>{};

  for (final Plugin plugin in plugins) {
    final String absolutePath = globals.fs.path.join(flutterProject.ohos.ohosRoot.path, 'har/${plugin.name}.har');
    if (flutterProject.isModule) {
      overrides[plugin.name] = 'file:$absolutePath';
    } else {
      overrides[plugin.name] = 'file:./har/${plugin.name}.har';
    }
  }
  final String configNew = const JsonEncoder.withIndent('  ').convert(config);
  packageFile.writeAsStringSync(configNew, flush: true);
}

String _relative(String path, {String? from}) {
  return globals.fs.path.relative(path, from: from).replaceAll(r'\', '/');
}
