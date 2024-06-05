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

import 'dart:io';

import 'package:json5/json5.dart';
import 'package:process/process.dart';

import '../artifacts.dart';
import '../base/common.dart';
import '../base/file_system.dart';
import '../base/logger.dart';
import '../base/os.dart';
import '../base/platform.dart' as base_platform;
import '../base/process.dart';
import '../build_info.dart';
import '../build_system/build_system.dart';
import '../build_system/targets/ohos.dart';
import '../cache.dart';
import '../compile.dart';
import '../convert.dart';
import '../flutter_plugins.dart';
import '../globals.dart' as globals;
import '../platform_plugins.dart';
import '../plugins.dart';
import '../project.dart';
import '../reporting/reporting.dart';
import 'application_package.dart';
import 'hvigor_utils.dart';
import 'ohos_builder.dart';
import 'ohos_plugins_manager.dart';

/// if this constant set true , must config platform environment PUB_HOSTED_URL and FLUTTER_STORAGE_BASE_URL
const bool NEED_PUB_CN = true;

const String OHOS_DTA_FILE_NAME = 'icudtl.dat';

const String FLUTTER_ASSETS_PATH = 'flutter_assets';

const String APP_SO_ORIGIN = 'app.so';

const String APP_SO = 'libapp.so';

const String HAR_FILE_NAME = 'flutter.har';

const String BUILD_INFO_JSON_PATH = 'src/main/resources/base/profile/buildinfo.json5';

final bool isWindows = globals.platform.isWindows;

String getHvigorwFile() => isWindows ? 'hvigorw.bat' : 'hvigorw';

void checkPlatformEnvironment(String environment, Logger? logger) {
  final String? environmentConfig = Platform.environment[environment];
  if (environmentConfig == null) {
    throwToolExit(
        'error:current platform environment $environment have not set');
  } else {
    logger?.printStatus(
        'current platform environment $environment = $environmentConfig');
  }
}

void copyFlutterAssets(String orgPath, String desPath, Logger? logger) {
  logger?.printStatus('copy directory from $orgPath to $desPath');
  final LocalFileSystem localFileSystem = globals.localFileSystem;
  copyDirectory(
      localFileSystem.directory(orgPath), localFileSystem.directory(desPath));
}

Future<void> copyFlutterBuildInfoFile(OhosProject ohosProject) async {
  final String rawfilePath = globals.fs.path.join(ohosProject.flutterModuleDirectory.path,
      'src/main/resources/rawfile');
  final Directory rawfileDirectory = globals.localFileSystem.directory(rawfilePath);
  if (!await rawfileDirectory.exists()) {
    return;
  }

  final String buildinfoFilePath = globals.fs.path.join(ohosProject.flutterModuleDirectory.path, BUILD_INFO_JSON_PATH);
  final File sourceFile = globals.localFileSystem.file(buildinfoFilePath);
  final String fileName = globals.fs.path.basename(buildinfoFilePath);
  final String destinationFilePath = globals.fs.path.join(rawfilePath, fileName);
  final File destinationFile = globals.localFileSystem.file(destinationFilePath);

  if (!await sourceFile.exists()) {
    return;
  }

  if (!await destinationFile.exists()) {
    await sourceFile.copy(destinationFilePath);
  } else {
    return;
  }
  // delete sourceFile
  await sourceFile.delete();
}

/// eg:entry/src/main/resources/rawfile
String getProjectAssetsPath(String ohosRootPath, OhosProject ohosProject) {
  return globals.fs.path.join(ohosProject.flutterModuleDirectory.path,
      'src/main/resources/rawfile', FLUTTER_ASSETS_PATH);
}

/// eg:entry/src/main/resources/rawfile/flutter_assets/
String getDatPath(String ohosRootPath, OhosProject ohosProject) {
  return globals.fs.path.join(
      getProjectAssetsPath(ohosRootPath, ohosProject), OHOS_DTA_FILE_NAME);
}

/// eg:entry/libs/arm64-v8a/libapp.so
String getAppSoPath(String ohosRootPath, OhosArch ohosArch, OhosProject ohosProject) {
  return globals.fs.path.join(ohosProject.flutterModuleDirectory.path, 'libs', getNameForOhosArch(ohosArch), APP_SO);
}

String getHvigorwPath(String ohosRootPath, {bool checkMod = false}) {
  final String hvigorwPath =
      globals.fs.path.join(ohosRootPath, getHvigorwFile());
  if (globals.fs.file(hvigorwPath).existsSync()) {
    if (checkMod) {
      final OperatingSystemUtils operatingSystemUtils = globals.os;
      final File file = globals.localFileSystem.file(hvigorwPath);
      operatingSystemUtils.chmod(file, '755');
    }
    return hvigorwPath;
  } else {
    return 'hvigorw';
  }
}

/// 签名
Future<void> signHap(LocalFileSystem localFileSystem, String unsignedFile,
    String signedOutFile, Logger? logger, String bundleName) async {
  const String PROFILE_TEMPLATE = 'profile_tmp_template.json';
  const String PROFILE_TARGET = 'profile_tmp.json';
  const String BUNDLE_NAME_KEY = '{{ohosId}}';
  final String signToolHome = Platform.environment['SIGN_TOOL_HOME'] ?? '';
  if (signToolHome == '') {
    throwToolExit("can't find environment SIGN_TOOL_HOME");
  }
  //修改HarmonyAppProvision配置文件
  final String provisionTemplatePath =
      globals.fs.path.join(signToolHome, PROFILE_TEMPLATE);
  final File provisionTemplateFile =
      localFileSystem.file(provisionTemplatePath);
  if (!provisionTemplateFile.existsSync()) {
    throwToolExit(
        '$PROFILE_TEMPLATE is not found,Please refer to the readme to create the file.');
  }
  final String provisionTargetPath =
      globals.fs.path.join(signToolHome, PROFILE_TARGET);
  final File provisionTargetFile = localFileSystem.file(provisionTargetPath);
  if (provisionTargetFile.existsSync()) {
    provisionTargetFile.deleteSync();
  }
  replaceKey(
      provisionTemplateFile, provisionTargetFile, BUNDLE_NAME_KEY, bundleName);

  //拷贝待签名文件
  final String desFilePath =
      globals.fs.path.join(signToolHome, 'app1-unsigned.hap');
  final File unsignedHap = localFileSystem.file(unsignedFile);
  final File desFile = localFileSystem.file(desFilePath);
  if (desFile.existsSync()) {
    desFile.deleteSync();
  }
  unsignedHap.copySync(desFilePath);

  //执行create_appcert_sign_profile时，result需要是初始状态，所以备份和管理result
  final Directory result =
      localFileSystem.directory(globals.fs.path.join(signToolHome, 'result'));
  if (!result.existsSync()) {
    throwToolExit('请还原autosign/result目录到初始状态');
  }
  final Directory resultBackup = localFileSystem
      .directory(globals.fs.path.join(signToolHome, 'result.bak'));

  String projectHome = globals.fs.directory(getOhosBuildDirectory()).path;
  final Directory projectSignHistory = localFileSystem
      .directory(globals.fs.path.join(projectHome, 'signature'));

  bool isNeedCopySignHistory = true;
  // 如果result.bak不存在，代表是环境配置完成后第一次签名，拷贝result.bak。
  if (!resultBackup.existsSync()) {
    copyDirectory(result, resultBackup);
  } else if (!projectSignHistory.existsSync()) {
    // 如果projectSignHistory不存在，代表该工程从未进行过签名，此时从 result.bak 还原数据进行签名
    result.deleteSync(recursive: true);
    copyDirectory(resultBackup, result);
  } else {
    // 如果projectSignHistory存在，代表该工程之前进行过签名，此时拷贝历史签名数据进行签名
    isNeedCopySignHistory = false;
    copyDirectory(projectSignHistory, result);
  }

  if (isNeedCopySignHistory) {
    final List<String> cmdCreateCertAndProfile = <String>[];
    if (isWindows) {
      cmdCreateCertAndProfile.add('py');
      cmdCreateCertAndProfile.add('-3');
    } else {
      cmdCreateCertAndProfile.add('python3');
    }
    cmdCreateCertAndProfile
        .add(globals.fs.path.join(signToolHome, 'autosign.py'));
    cmdCreateCertAndProfile.add('createAppCertAndProfile');

    await invokeCmd(
        command: cmdCreateCertAndProfile,
        workDirectory: signToolHome,
        processManager: globals.processManager,
        logger: logger);
    copyDirectory(result, projectSignHistory);
  }

  final List<String> cmdSignHap = <String>[];
  if (isWindows) {
    cmdSignHap.add('py');
    cmdSignHap.add('-3');
  } else {
    cmdSignHap.add('python3');
  }
  cmdSignHap.add(globals.fs.path.join(signToolHome, 'autosign.py'));
  cmdSignHap.add('signHap');

  await invokeCmd(
      command: cmdSignHap,
      workDirectory: signToolHome,
      processManager: globals.processManager,
      logger: logger);
  final String signedFile =
      globals.fs.path.join(signToolHome, 'result', 'app1-signed.hap');
  // 拷贝到目标files
  final File signedHap = globals.localFileSystem.file(signedFile);
  signedHap.copySync(signedOutFile);
}

String getAbsolutePath(FlutterProject flutterProject, String path) {
  if (globals.fs.path.isRelative(path)) {
    return globals.fs.path.join(flutterProject.directory.path, path);
  }
  return path;
}

Future<void> invokeCmd(
    {required List<String> command,
    required String workDirectory,
    required ProcessManager processManager,
    Logger? logger}) async {
  final String cmd = command.join(' ');
  logger?.printTrace(cmd);
  final Process server =
      await processManager.start(command, workingDirectory: workDirectory);

  server.stderr.transform<String>(utf8.decoder).listen(logger?.printError);
  server.stdout
      .transform<String>(utf8.decoder)
      .transform<String>(const LineSplitter())
      .listen((String line) {
    if (line.contains('error')) {
      throwToolExit('command {$command} invoke error!:$line');
    } else {
      logger?.printStatus(line);
    }
  });
  final int exitCode = await server.exitCode;
  if (exitCode == 0) {
    logger?.printStatus('$cmd invoke success.');
  } else {
    logger?.printError('$cmd invoke error.');
  }
  return;
}

/// ohpm should init first
Future<void> ohpmInstall(
    {required ProcessManager processManager,
    required String workingDirectory,
    Logger? logger}) async {
  final List<String> command = <String>[
    'ohpm',
    'install',
    '--all',
  ];
  logger?.printTrace('invoke at:$workingDirectory ,command: ${command.join(' ')}');
  final Process server =
      await processManager.start(command, workingDirectory: workingDirectory);

  server.stderr.transform<String>(utf8.decoder).listen(logger?.printError);
  final StdoutHandler stdoutHandler =
      StdoutHandler(logger: logger!, fileSystem: globals.localFileSystem);
  server.stdout
      .transform<String>(utf8.decoder)
      .transform<String>(const LineSplitter())
      .listen(stdoutHandler.handler);
  final int exitCode = await server.exitCode;
  if (exitCode == 0) {
    logger.printStatus('ohpm install success.');
  } else {
    logger.printError('ohpm install error.');
  }
  return;
}

/// 根据来源，替换关键字，输出target文件
void replaceKey(File file, File target, String key, String value) {
  String content = file.readAsStringSync();
  content = content.replaceAll(key, value);
  target.writeAsStringSync(content);
}

///hvigorw任务
Future<int> hvigorwTask(List<String> taskCommand,
    {required ProcessManager processManager,
    required String workPath,
    required String hvigorwPath,
    Logger? logger}) async {
  final String taskStr = taskCommand.join(' ');
  logger?.printTrace('invoke hvigorw task: $taskStr');
  final Process server =
      await processManager.start(taskCommand, workingDirectory: workPath);
  server.stderr.transform<String>(utf8.decoder).listen(logger?.printError);
  final StdoutHandler stdoutHandler =
      StdoutHandler(logger: logger!, fileSystem: globals.localFileSystem);
  server.stdout
      .transform<String>(utf8.decoder)
      .transform<String>(const LineSplitter())
      .listen(stdoutHandler.handler);
  final int exitCode = await server.exitCode;
  if (exitCode == 0) {
    logger.printStatus('success! when invoke: $taskStr.');
  } else {
    logger.printError('error! when invoke: $taskStr ,exitCode = $exitCode. ');
  }
  return exitCode;
}

Future<int> assembleHap(
    {required ProcessManager processManager,
    required String ohosRootPath,
    required String hvigorwPath,
    Logger? logger}) async {
  final List<String> command = <String>[
    hvigorwPath,
    // 'clean',
    'assembleHap',
    '--no-daemon',
  ];
  return hvigorwTask(command,
      processManager: processManager,
      workPath: ohosRootPath,
      hvigorwPath: hvigorwPath,
      logger: logger);
}

Future<int> assembleApp(
    {required ProcessManager processManager,
    required String ohosRootPath,
    required String hvigorwPath,
    Logger? logger}) async {
  final List<String> command = <String>[
    hvigorwPath,
    // 'clean',
    'assembleApp',
    '--no-daemon',
  ];
  return hvigorwTask(command,
      processManager: processManager,
      workPath: ohosRootPath,
      hvigorwPath: hvigorwPath,
      logger: logger);
}


Future<int> assembleHar(
    {required ProcessManager processManager,
    required String workPath,
    required String hvigorwPath,
    required String moduleName,
    Logger? logger}) async {
  final List<String> command = <String>[
    hvigorwPath,
    // 'clean',
    '--mode',
    'module',
    '-p',
    'module=$moduleName@default',
    '-p',
    'product=default',
    'assembleHar',
    '--no-daemon',
  ];
  return hvigorwTask(command,
      processManager: processManager,
      workPath: workPath,
      hvigorwPath: hvigorwPath,
      logger: logger);
}

/// 检查环境变量配置
void checkFlutterEnv(Logger? logger) {
  logger?.printStatus('check platform environment');
  if (NEED_PUB_CN) {
    checkPlatformEnvironment('PUB_HOSTED_URL', logger);
    checkPlatformEnvironment('FLUTTER_STORAGE_BASE_URL', logger);
  }
}

/// flutter构建
Future<String> flutterAssemble(FlutterProject flutterProject, OhosBuildInfo ohosBuildInfo, String targetFile) async {
  late String targetName;
  if (ohosBuildInfo.buildInfo.isDebug) {
    targetName = 'debug_ohos_application';
  } else if (ohosBuildInfo.buildInfo.isProfile) {
    // eg:ohos_aot_bundle_profile_ohos-arm64
    targetName =
        'ohos_aot_bundle_profile_${getPlatformNameForOhosArch(ohosBuildInfo.targetArchs.first)}';
  } else {
    // eg:ohos_aot_bundle_release_ohos-arm64
    targetName =
        'ohos_aot_bundle_release_${getPlatformNameForOhosArch(ohosBuildInfo.targetArchs.first)}';
  }
  final List<Target> selectTarget =
      ohosTargets.where((Target e) => targetName == e.name).toList();
  if (selectTarget.isEmpty) {
    throwToolExit('do not found compare target.');
  } else if (selectTarget.length > 1) {
    throwToolExit('more than one target match.');
  }
  final Target target = selectTarget[0];

  final Status status =
      globals.logger.startProgress('Compiling $targetName for the Ohos...');
  String output = globals.fs.directory(getOhosBuildDirectory()).path;
  // If path is relative, make it absolute from flutter project.
  output = getAbsolutePath(flutterProject, output);
  try {
    final BuildResult result = await globals.buildSystem.build(
        target,
        Environment(
          projectDir: globals.fs.currentDirectory,
          outputDir: globals.fs.directory(output),
          buildDir: flutterProject.directory
              .childDirectory('.dart_tool')
              .childDirectory('flutter_build'),
          defines: <String, String>{
            ...ohosBuildInfo.buildInfo.toBuildSystemEnvironment(),
            kTargetFile: targetFile,
            kTargetPlatform: getNameForTargetPlatform(TargetPlatform.ohos),
          },
          artifacts: globals.artifacts!,
          fileSystem: globals.fs,
          logger: globals.logger,
          processManager: globals.processManager,
          analytics: globals.analytics,
          platform: globals.platform,
          usage: globals.flutterUsage,
          cacheDir: globals.cache.getRoot(),
          engineVersion: globals.artifacts!.isLocalEngine
              ? null
              : globals.flutterVersion.engineRevision,
          flutterRootDir: globals.fs.directory(Cache.flutterRoot),
          generateDartPluginRegistry: true,
        ));
    if (!result.success) {
      for (final ExceptionMeasurement measurement in result.exceptions.values) {
        globals.printError(
          'Target ${measurement.target} failed: ${measurement.exception}',
          stackTrace: measurement.fatal ? measurement.stackTrace : null,
        );
      }
      throwToolExit('Failed to compile application for the Ohos.');
    } else {
      return output;
    }
  } on Exception catch (err) {
    throwToolExit(err.toString());
  } finally {
    status.stop();
  }
}

/// 清理和拷贝flutter产物和资源
void cleanAndCopyFlutterAsset(
    OhosProject ohosProject,
    OhosBuildInfo ohosBuildInfo,
    Logger? logger,
    String ohosRootPath,
    String output) {
  logger?.printStatus('copy flutter assets to project start');
  // clean flutter assets
  final String desFlutterAssetsPath =
      getProjectAssetsPath(ohosRootPath, ohosProject);
  final Directory desAssets = globals.fs.directory(desFlutterAssetsPath);
  if (desAssets.existsSync()) {
    desAssets.deleteSync(recursive: true);
  }

  /// copy flutter assets
  copyFlutterAssets(globals.fs.path.join(output, FLUTTER_ASSETS_PATH), desFlutterAssetsPath, logger);
  copyFlutterBuildInfoFile(ohosProject);

  final String desAppSoPath = getAppSoPath(ohosRootPath, ohosBuildInfo.targetArchs.first, ohosProject);
  if (ohosBuildInfo.buildInfo.isRelease || ohosBuildInfo.buildInfo.isProfile) {
    // copy app.so
    final String appSoPath = globals.fs.path.join(output, getNameForOhosArch(ohosBuildInfo.targetArchs.first), APP_SO_ORIGIN);
    final File appSoFile = globals.localFileSystem.file(appSoPath);
    ensureParentExists(desAppSoPath);
    appSoFile.copySync(desAppSoPath);
  } else {
    final File appSo = globals.fs.file(desAppSoPath);
    if (appSo.existsSync()) {
      appSo.deleteSync();
    }
  }
  logger?.printStatus('copy flutter assets to project end');
}

/// 清理和拷贝flutter运行时
void cleanAndCopyFlutterRuntime(
    OhosProject ohosProject,
    OhosBuildInfo ohosBuildInfo,
    Logger? logger,
    String ohosRootPath,
    OhosBuildData ohosBuildData) {
  logger?.printStatus('copy flutter runtime to project start');
  // copy ohos font-family support
  final String flutterSdk = Cache.flutterRoot!;
  final File ohosDta = globals.localFileSystem.file(globals.fs.path.join(
      flutterSdk,
      'packages',
      'flutter_tools',
      'templates',
      'app_shared',
      'ohos.tmpl',
      'dta',
      OHOS_DTA_FILE_NAME));
  final String copyDes = getDatPath(ohosRootPath, ohosProject);
  ohosDta.copySync(copyDes);

  // 复制 flutter.har
  String? localEngineHarPath = globals.artifacts?.getArtifactPath(
      Artifact.flutterEngineHar,
      platform: getTargetPlatformForName(getPlatformNameForOhosArch(ohosBuildInfo.targetArchs.first)),
      mode: ohosBuildInfo.buildInfo.mode);

  if (!globals.fs.file(localEngineHarPath).existsSync()) {
    // 如果不存在缓存也不存在localengine, 使用模板预置har
    localEngineHarPath = getOriginHarPath(ohosBuildInfo.buildInfo, ohosBuildData);
  }

  String desHarPath = '';
  if (ohosProject.isModule) {
    desHarPath = globals.fs.path.join(ohosRootPath, 'har', HAR_FILE_NAME);
  } else {
    desHarPath = globals.fs.path.join(ohosRootPath, 'har', HAR_FILE_NAME);
  }
  ensureParentExists(desHarPath);
  final File originHarFile = globals.localFileSystem.file(localEngineHarPath);
  originHarFile.copySync(desHarPath);
  logger?.printStatus('copy from: $localEngineHarPath to $desHarPath');
  logger?.printStatus('copy flutter runtime to project end');
}

void ensureParentExists(String path) {
  final Directory directory = globals.localFileSystem.file(path).parent;
  if (!directory.existsSync()) {
    directory.createSync(recursive: true);
  }
}

String getEmbeddingHarFileSuffix(
    BuildInfo buildInfo, OhosBuildData ohosBuildData) {
  final int apiVersion = ohosBuildData.apiVersion;
  return '${buildInfo.isDebug ? 'debug' : buildInfo.isProfile ? 'profile' : 'release'}.$apiVersion';
}


String? getLocalEnginePath() {
  final Artifacts artifacts = globals.artifacts!;
  final LocalEngineInfo? localEngineInfo = artifacts.localEngineInfo;
  if (artifacts.isLocalEngine && localEngineInfo != null) {
    return localEngineInfo.targetOutPath;
  }
  return null;
}

String getTmplPath() {
  final String flutterSdk = Cache.flutterRoot!;
  final String path = globals.fs.path.join(
      flutterSdk,
      'packages',
      'flutter_tools',
      'templates',
      'app_shared',
      'ohos.tmpl',
      'har',
      'har_product.tmpl');
  return path;
}

String getOriginHarPath(BuildInfo buildInfo, OhosBuildData ohosBuildData) {
  final String suffix = getEmbeddingHarFileSuffix(buildInfo, ohosBuildData);
  final String target =
      globals.fs.path.join(getTmplPath(), '$HAR_FILE_NAME.$suffix');
  if (globals.fs.file(target).existsSync()) {
    return target;
  }

  throwToolExit('File $HAR_FILE_NAME not found in [$target]');
}

class OhosHvigorBuilder implements OhosBuilder {
  OhosHvigorBuilder({
    required Logger logger,
    required ProcessManager processManager,
    required FileSystem fileSystem,
    required Artifacts artifacts,
    required Usage usage,
    required HvigorUtils hvigorUtils,
    required base_platform.Platform platform,
  })  : _logger = logger,
        _fileSystem = fileSystem,
        _artifacts = artifacts,
        _usage = usage,
        _hvigorUtils = hvigorUtils,
        _fileSystemUtils =
            FileSystemUtils(fileSystem: fileSystem, platform: platform),
        _processUtils =
            ProcessUtils(logger: logger, processManager: processManager);

  final Logger _logger;
  final ProcessUtils _processUtils;
  final FileSystem _fileSystem;
  final Artifacts _artifacts;
  final Usage _usage;
  final HvigorUtils _hvigorUtils;
  final FileSystemUtils _fileSystemUtils;

  late OhosProject ohosProject;
  late String ohosRootPath;
  late OhosBuildData ohosBuildData;

  void parseData(FlutterProject flutterProject, Logger? logger) {
    ohosProject = flutterProject.ohos;
    ohosRootPath = ohosProject.ohosRoot.path;
    ohosBuildData = OhosBuildData.parseOhosBuildData(ohosProject, logger);
  }

  /// build hap
  @override
  Future<void> buildHap({
    required FlutterProject project,
    required OhosBuildInfo ohosBuildInfo,
    required String target,
  }) async {
    _logger.printStatus('start hap build...');

    if (!project.ohos.ohosBuildData.moduleInfo.hasEntryModule) {
      throwToolExit(
          "this ohos project don't have a entry module, can't build to a hap file.");
    }
    await addPluginsModules(project);
    await addFlutterModuleAndPluginsSrcOverrides(project);

    await buildApplicationPipeLine(project, ohosBuildInfo, target: target);

    /// 生成所有 plugin 的 har
    final String hvigorwPath = getHvigorwPath(ohosRootPath, checkMod: true);
    final List<Plugin> plugins = (await findPlugins(project))
        .where((Plugin p) => p.platforms.containsKey(OhosPlugin.kConfigKey))
        .toList();
    if (plugins.isNotEmpty) {
      final int errorCode = await assembleHar(
          processManager: globals.processManager,
          workPath: ohosRootPath,
          hvigorwPath: hvigorwPath,
          moduleName: plugins.map((Plugin e) => e.name).join(','),
          logger: _logger);
      if (errorCode != 0) {
        throwToolExit('assembleHar error! please check log.');
      }

      for (final Plugin plugin in plugins) {
        final String desHarPath = globals.fs.path.join(ohosRootPath, 'har', '${plugin.name}.har');
        final File originHar = globals.fs
            .directory(globals.fs.path.join(ohosRootPath,
                globals.fs.path.join(plugin.path, OhosPlugin.kConfigKey)))
            .childDirectory('build')
            .childDirectory('default')
            .childDirectory('outputs')
            .childDirectory('default')
            .childFile('${plugin.name}.har');
        if (!originHar.existsSync()) {
          throwToolExit('Oops! Failed to find: ${originHar.path}');
        }
        ensureParentExists(desHarPath);
        originHar.copySync(desHarPath);
      }
    }
    await removePluginsModules(project);
    await addFlutterModuleAndPluginsOverrides(project);
    // ohosProject.deleteOhModulesCache();
    await ohpmInstall(
      processManager: globals.processManager,
      workingDirectory: ohosRootPath,
      logger: _logger,
    );

    /// invoke hvigow task generate hap file.
    final int errorCode1 = await assembleHap(
        processManager: globals.processManager,
        ohosRootPath: ohosRootPath,
        hvigorwPath: hvigorwPath,
        logger: _logger);
    if (errorCode1 != 0) {
      throwToolExit('assembleHap error! please check log.');
    }

    final File buildProfile = project.ohos.getBuildProfileFile();
    final String buildProfileConfig = buildProfile.readAsStringSync();
    final dynamic obj = JSON5.parse(buildProfileConfig);
    dynamic signingConfigs = obj['app']?['signingConfigs'];
    if (signingConfigs is List && signingConfigs.isEmpty) {
      _logger.printError(
          '请通过DevEco Studio打开ohos工程后配置调试签名(File -> Project Structure -> Signing Configs 勾选Automatically generate signature)');
    }
  }

  Future<void> flutterBuildPre(FlutterProject flutterProject, OhosBuildInfo ohosBuildInfo, String target) async {
    /**
     * 0. checkEnv
     * 1. execute flutter assemble
     * 2. copy flutter asset to flutter module
     * 3. copy flutter runtime
     * 4. ohpm install
     */
    checkFlutterEnv(_logger);

    final String output = await flutterAssemble(flutterProject, ohosBuildInfo, target);

    cleanAndCopyFlutterAsset(ohosProject, ohosBuildInfo, _logger, ohosRootPath, output);

    cleanAndCopyFlutterRuntime(ohosProject, ohosBuildInfo, _logger, ohosRootPath, ohosBuildData);

    // ohpm install for all modules
    // ohosProject.deleteOhModulesCache();
    await ohpmInstall(
      processManager: globals.processManager,
      workingDirectory: ohosRootPath,
      logger: _logger,
    );
  }

  @override
  Future<void> buildHar({
    required FlutterProject project,
    required OhosBuildInfo ohosBuildInfo,
    required String target,
  }) async {
    if (!project.isModule ||
        !project.ohos.flutterModuleDirectory.existsSync()) {
      throwToolExit('current project is not module or has not pub get');
    }
    await addPluginsModules(project);
    await addFlutterModuleAndPluginsSrcOverrides(project);

    parseData(project, _logger);

    await flutterBuildPre(project, ohosBuildInfo, target);

    final String hvigorwPath = getHvigorwPath(ohosRootPath, checkMod: true);
    final List<OhosModule> harModules = ohosBuildData.harModules;

    /// 生成 module 和所有 plugin 的 har
    final int errorCode = await assembleHar(
        processManager: globals.processManager,
        workPath: ohosRootPath,
        hvigorwPath: hvigorwPath,
        moduleName: harModules.map((OhosModule e) => e.name).join(','),
        logger: _logger);
    if (errorCode != 0) {
      throwToolExit('assembleHar error! please check log.');
    }
    for (final OhosModule module in harModules) {
      final String desHarPath = globals.fs.path.join(ohosRootPath, 'har', '${module.name}.har');
      final File originHar = globals.fs.directory(globals.fs.path.join(ohosRootPath, module.srcPath))
          .childDirectory('build')
          .childDirectory('default')
          .childDirectory('outputs')
          .childDirectory('default')
          .childFile('${module.name}.har');
      if (!originHar.existsSync()) {
        throwToolExit('Oops! Failed to find: ${originHar.path}');
      }
      ensureParentExists(desHarPath);
      originHar.copySync(desHarPath);
    }
    await removePluginsModules(project);
    await addFlutterModuleAndPluginsOverrides(project);
    printHowToConsumeHar(logger: _logger);
  }


  /// Prints how to consume the har from a host app.
  void printHowToConsumeHar({
    Logger? logger,
  }) {

    logger?.printStatus('\nConsuming the Module', emphasis: true);
    logger?.printStatus('''
    1. Open ${globals.fs.path.join('<host project>', 'oh-package.json5')}
    2. Add flutter_module to the dependencies list:

      "dependencies": {
        "@ohos/flutter_module": "file:path/to/har/flutter_module.har"
      }

    3. Override flutter and plugins dependencies:

      "overrides" {
        "@ohos/flutter_ohos": "file:path/to/har/flutter.har",
        "plugin_xxx":'file:path/to/har/plugin_xxx.har',
      }
  ''');
  }

  @override
  Future<void> buildHsp({
    required FlutterProject project,
    required OhosBuildInfo ohosBuildInfo,
    required String target,
  }) {
    // TODO: implement buildHsp
    throw UnimplementedError();
  }

  @override
  Future<void> buildApp({
    required FlutterProject project,
    required OhosBuildInfo ohosBuildInfo,
    required String target,
  }) async {

    await buildApplicationPipeLine(project, ohosBuildInfo, target: target);

    final String hvigorwPath = getHvigorwPath(ohosRootPath,       checkMod: true);

    /// invoke hvigow task generate hap file.
    final int errorCode1 = await assembleApp(
        processManager: globals.processManager,
        ohosRootPath: ohosRootPath,
        hvigorwPath: hvigorwPath,
        logger: _logger);
    if (errorCode1 != 0) {
      throwToolExit('assembleHap error! please check log.');
    }
  }

  Future<void> buildApplicationPipeLine(FlutterProject flutterProject, OhosBuildInfo ohosBuildInfo, {required String target}) async {
    if (!flutterProject.ohos.ohosBuildData.moduleInfo.hasEntryModule) {
      throwToolExit(
          "this ohos project don't have a entry module , can't build to a application.");
    }

    parseData(flutterProject, _logger);

    /// 检查plugin的har构建
    await checkOhosPluginsDependencies(flutterProject);

    await flutterBuildPre(flutterProject, ohosBuildInfo, target);

    if (ohosProject.isRunWithModuleHar) {
      final String hvigorwPath =
          getHvigorwPath(ohosProject.ephemeralDirectory.path, checkMod: true);
      final int errorCode0 = await assembleHar(
          processManager: globals.processManager,
          workPath: ohosProject.ephemeralDirectory.path,
          moduleName: ohosProject.flutterModuleName,
          hvigorwPath: hvigorwPath,
          logger: _logger);
      if (errorCode0 != 0) {
        throwToolExit('assemble error! please check log.');
      }

      final File originHar = ohosProject.flutterModuleDirectory
          .childDirectory('build')
          .childDirectory('default')
          .childDirectory('outputs')
          .childDirectory('default')
          .childFile('${ohosProject.flutterModuleName}.har');
      if (!originHar.existsSync()) {
        throwToolExit('Oops! Failed to find: ${originHar.path}');
      }
      final String desPath = globals.fs.path
          .join(ohosRootPath, 'har', '${ohosProject.flutterModuleName}.har');
      ensureParentExists(desPath);
      originHar.copySync(desPath);

      /// har文件拷贝后，需要重新install
      // ohosProject.deleteOhModulesCache();
      await ohpmInstall(
          processManager: globals.processManager,
          workingDirectory: ohosProject.mainModuleDirectory.path,
          logger: _logger);
    }
  }
}
