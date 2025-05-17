/*
* Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd. All rights reserved.
* Use of this source code is governed by a BSD-style license that can be
* found in the LICENSE_KHZG file.
*/

import '../build_info.dart';
import '../globals.dart' as globals;
import '../ohos/hvigor_utils.dart';
import '../ohos/ohos_builder.dart';
import '../project.dart';
import '../runner/flutter_command.dart';
import 'build.dart';

class BuildAppCommand extends BuildSubCommand {
  BuildAppCommand({required super.logger, bool verboseHelp = false})
      : super(verboseHelp: verboseHelp) {
    addTreeShakeIconsFlag();
    usesTargetOption();
    addBuildModeFlags(verboseHelp: verboseHelp);
    usesFlavorOption();
    usesPubOption();
    usesBuildNumberOption();
    usesBuildNameOption();
    addShrinkingFlag(verboseHelp: verboseHelp);
    addSplitDebugInfoOption();
    addDartObfuscationOption();
    usesDartDefineOption();
    usesExtraDartFlagOptions(verboseHelp: verboseHelp);
    addBundleSkSLPathOption(hide: !verboseHelp);
    addEnableExperimentation(hide: !verboseHelp);
    addBuildPerformanceFile(hide: !verboseHelp);
    addNullSafetyModeOptions(hide: !verboseHelp);
    usesAnalyzeSizeFlag();
    addIgnoreDeprecationOption();
    usesTrackWidgetCreation(verboseHelp: verboseHelp);

    argParser.addMultiOption(
      'target-platform',
      defaultsTo: const <String>['ohos-arm64'],
      allowed: <String>['ohos-arm64', 'ohos-arm', 'ohos-x64'],
      help: 'The target platform for which the app is compiled.',
    );
  }

  @override
  final String description = 'Build an Ohos App file from your app.\n\n';

  @override
  String get name => 'app';

  @override
  bool get reportNullSafety => false;

  @override
  Future<Set<DevelopmentArtifact>> get requiredArtifacts async => <DevelopmentArtifact>{
    DevelopmentArtifact.ohosGenSnapshot,
    DevelopmentArtifact.ohosInternalBuild,
  };

  @override
  Future<FlutterCommandResult> runCommand() async {
    if (globals.hmosSdk == null) {
      exitWithNoSdkMessage();
    }
    final BuildInfo buildInfo = await getBuildInfo();
    final OhosBuildInfo ohosBuildInfo = OhosBuildInfo(
      buildInfo,
      targetArchs: stringsArg('target-platform').map<OhosArch>(getOhosArchForName),
    );
    await ohosBuilder?.buildApp(
      project: FlutterProject.current(),
      ohosBuildInfo: ohosBuildInfo,
      target: targetFile,
    );
    return FlutterCommandResult.success();
  }
}
