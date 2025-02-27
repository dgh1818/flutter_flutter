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

import '../build_info.dart';
import '../globals.dart' as globals;
import '../ohos/hvigor_utils.dart';
import '../ohos/ohos_builder.dart';
import '../project.dart';
import '../runner/flutter_command.dart';
import 'build.dart';

class BuildHapCommand extends BuildSubCommand {
  BuildHapCommand({required super.logger, bool verboseHelp = false})
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
      allowed: <String>['ohos-arm64', 'ohos-arm', 'ohos-x86'],
      help: 'The target platform for which the app is compiled.',
    );
  }

  @override
  final String description = 'Build an Ohos Hap file from your app.\n\n';

  @override
  String get name => 'hap';

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
    await ohosBuilder?.buildHap(
      project: FlutterProject.current(),
      ohosBuildInfo: ohosBuildInfo,
      target: targetFile,
    );
    return FlutterCommandResult.success();
  }
}
