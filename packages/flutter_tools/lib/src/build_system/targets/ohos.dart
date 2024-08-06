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

import 'package:file/file.dart';

import '../../artifacts.dart';
import '../../base/build.dart';
import '../../base/deferred_component.dart';
import '../../build_info.dart';
import '../../globals.dart' as globals show xcode;
import '../build_system.dart';
import '../depfile.dart';
import '../exceptions.dart';
import 'assets.dart';
import 'common.dart';
import '../tools/shader_compiler.dart';

class DebugOhosApplication extends OhosAssetBundle {
  const DebugOhosApplication();

  @override
  String get name => 'debug_ohos_application';

  @override
  List<Source> get inputs => <Source>[
        ...super.inputs,
        const Source.artifact(Artifact.vmSnapshotData, mode: BuildMode.debug),
        const Source.artifact(Artifact.isolateSnapshotData,
            mode: BuildMode.debug),
      ];

  @override
  List<Source> get outputs => <Source>[
        ...super.outputs,
        const Source.pattern('{OUTPUT_DIR}/flutter_assets/vm_snapshot_data'),
        const Source.pattern(
            '{OUTPUT_DIR}/flutter_assets/isolate_snapshot_data'),
        const Source.pattern('{OUTPUT_DIR}/flutter_assets/kernel_blob.bin'),
      ];
}

/// ohos release targets
const OhosAotBundle ohosArmReleaseBundle = OhosAotBundle(ohosArmRelease);
const OhosAotBundle ohosArm64ReleaseBundle = OhosAotBundle(ohosArm64Release);
const OhosAotBundle ohosX64ReleaseBundle = OhosAotBundle(ohosX64Release);
const OhosAotBundle ohosArmProfileBundle = OhosAotBundle(OhosAot(TargetPlatform.ohos_arm, BuildMode.profile));
const OhosAotBundle ohosArm64ProfileBundle = OhosAotBundle(OhosAot(TargetPlatform.ohos_arm64, BuildMode.profile));
const OhosAotBundle ohosX64ProfileBundle = OhosAotBundle(OhosAot(TargetPlatform.ohos_x64, BuildMode.profile));

List<Target> ohosTargets = <Target>[
  ohosArmReleaseBundle,
  ohosArm64ReleaseBundle,
  ohosX64ReleaseBundle,
  ohosArmProfileBundle,
  ohosArm64ProfileBundle,
  ohosX64ProfileBundle,
  const DebugOhosApplication(),
];

/// A rule paired with [OhosAot] that copies the produced so file and manifest.json (if present) into the output directory.
class OhosAotBundle extends Target {
  /// Create an [OhosAotBundle] implementation for a given [targetPlatform] and [buildMode].
  const OhosAotBundle(this.dependency);

  /// The [OhosAot] instance this bundle rule depends on.
  final OhosAot dependency;

  /// The name of the produced Ohos ABI.
  String get _ohosAbiName {
    return getNameForOhosArch(getOhosArchForName(
        getNameForTargetPlatform(dependency.targetPlatform)));
  }

  @override
  String get name =>
      'ohos_aot_bundle_${dependency.buildMode.cliName}_'
      '${getNameForTargetPlatform(dependency.targetPlatform)}';

  TargetPlatform get targetPlatform => dependency.targetPlatform;

  /// The selected build mode.
  ///
  /// This is restricted to [BuildMode.profile] or [BuildMode.release].
  BuildMode get buildMode => dependency.buildMode;

  @override
  List<Source> get inputs => <Source>[
        Source.pattern('{BUILD_DIR}/$_ohosAbiName/app.so'),
      ];

  // flutter.gradle has been updated to correctly consume it.
  @override
  List<Source> get outputs => <Source>[
        Source.pattern('{OUTPUT_DIR}/$_ohosAbiName/app.so'),
      ];

  @override
  List<String> get depfiles => <String>[
        'flutter_$name.d',
      ];

  @override
  List<Target> get dependencies => <Target>[
        dependency,
        const AotOhosAssetBundle(),
      ];

  @override
  Future<void> build(Environment environment) async {
    final Directory buildDir =
        environment.buildDir.childDirectory(_ohosAbiName);
    final Directory outputDirectory =
        environment.outputDir.childDirectory(_ohosAbiName);
    if (!outputDirectory.existsSync()) {
      outputDirectory.createSync(recursive: true);
    }
    final File outputLibFile = buildDir.childFile('app.so');
    outputLibFile.copySync(outputDirectory.childFile('app.so').path);

    final List<File> inputs = <File>[];
    final List<File> outputs = <File>[];
    final File manifestFile = buildDir.childFile('manifest.json');
    if (manifestFile.existsSync()) {
      final File destinationFile = outputDirectory.childFile('manifest.json');
      manifestFile.copySync(destinationFile.path);
      inputs.add(manifestFile);
      outputs.add(destinationFile);
    }
    final DepfileService depfileService = DepfileService(
      fileSystem: environment.fileSystem,
      logger: environment.logger,
    );
    depfileService.writeToFile(
      Depfile(inputs, outputs),
      environment.buildDir.childFile('flutter_$name.d'),
      writeEmpty: true,
    );
  }
}

const OhosAot ohosArmRelease =
    OhosAot(TargetPlatform.ohos_arm, BuildMode.release);
const OhosAot ohosArm64Release =
    OhosAot(TargetPlatform.ohos_arm64, BuildMode.release);
const OhosAot ohosX64Release =
    OhosAot(TargetPlatform.ohos_x64, BuildMode.release);

class OhosAot extends AotElfBase {
  /// Create an [OhosAot] implementation for a given [targetPlatform] and [buildMode].
  const OhosAot(this.targetPlatform, this.buildMode);

  /// The name of the produced Ohos ABI.
  String get _ohosAbiName {
    return getNameForOhosArch(
        getOhosArchForName(getNameForTargetPlatform(targetPlatform)));
  }

  @override
  String get name => 'ohos_aot_${buildMode.cliName}_'
      '${getNameForTargetPlatform(targetPlatform)}';

  /// The specific Ohos ABI we are building for.
  final TargetPlatform targetPlatform;

  /// The selected build mode.
  ///
  /// Build mode is restricted to [BuildMode.profile] or [BuildMode.release] for AOT builds.
  final BuildMode buildMode;

  @override
  List<Source> get inputs => <Source>[
        const Source.pattern(
            '{FLUTTER_ROOT}/packages/flutter_tools/lib/src/build_system/targets/ohos.dart'),
        const Source.pattern('{BUILD_DIR}/app.dill'),
        const Source.artifact(Artifact.skyEnginePath),
        Source.artifact(
          Artifact.genSnapshot,
          mode: buildMode,
          platform: targetPlatform,
        ),
      ];

  @override
  List<Source> get outputs => <Source>[
        Source.pattern('{BUILD_DIR}/$_ohosAbiName/app.so'),
      ];

  @override
  List<String> get depfiles => <String>[
        'flutter_$name.d',
      ];

  @override
  List<Target> get dependencies => const <Target>[
        KernelSnapshot(),
      ];

  @override
  Future<void> build(Environment environment) async {
    final AOTSnapshotter snapshotter = AOTSnapshotter(
      fileSystem: environment.fileSystem,
      logger: environment.logger,
      xcode: globals.xcode!,
      processManager: environment.processManager,
      artifacts: environment.artifacts,
    );
    final Directory output = environment.buildDir.childDirectory(_ohosAbiName);
    final String? buildModeEnvironment = environment.defines[kBuildMode];
    if (buildModeEnvironment == null) {
      throw MissingDefineException(kBuildMode, 'aot_elf');
    }
    if (!output.existsSync()) {
      output.createSync(recursive: true);
    }
    final List<String> extraGenSnapshotOptions =
        decodeCommaSeparated(environment.defines, kExtraGenSnapshotOptions);
    final List<File> outputs = <File>[]; // outputs for the depfile
    final String manifestPath =
        '${output.path}${environment.platform.pathSeparator}manifest.json';
    if (environment.defines[kDeferredComponents] == 'true') {
      extraGenSnapshotOptions.add('--loading_unit_manifest=$manifestPath');
      outputs.add(environment.fileSystem.file(manifestPath));
    }
    final BuildMode buildMode = BuildMode.fromCliName(buildModeEnvironment);
    final bool dartObfuscation =
        environment.defines[kDartObfuscation] == 'true';
    final String? codeSizeDirectory = environment.defines[kCodeSizeDirectory];

    if (codeSizeDirectory != null) {
      final File codeSizeFile = environment.fileSystem
          .directory(codeSizeDirectory)
          .childFile('snapshot.$_ohosAbiName.json');
      final File precompilerTraceFile = environment.fileSystem
          .directory(codeSizeDirectory)
          .childFile('trace.$_ohosAbiName.json');
      extraGenSnapshotOptions
          .add('--write-v8-snapshot-profile-to=${codeSizeFile.path}');
      extraGenSnapshotOptions
          .add('--trace-precompiler-to=${precompilerTraceFile.path}');
    }

    final String? splitDebugInfo = environment.defines[kSplitDebugInfo];
    final int snapshotExitCode = await snapshotter.build(
      platform: targetPlatform,
      buildMode: buildMode,
      mainPath: environment.buildDir.childFile('app.dill').path,
      outputPath: output.path,
      extraGenSnapshotOptions: extraGenSnapshotOptions,
      splitDebugInfo: splitDebugInfo,
      dartObfuscation: dartObfuscation,
    );
    if (snapshotExitCode != 0) {
      throw Exception('AOT snapshotter exited with code $snapshotExitCode');
    }
    if (environment.defines[kDeferredComponents] == 'true') {
      // Parse the manifest for .so paths
      final List<LoadingUnit> loadingUnits =
          LoadingUnit.parseLoadingUnitManifest(
              environment.fileSystem.file(manifestPath), environment.logger);
      for (final LoadingUnit unit in loadingUnits) {
        outputs.add(environment.fileSystem.file(unit.path));
      }
    }
    final DepfileService depfileService = DepfileService(
      fileSystem: environment.fileSystem,
      logger: environment.logger,
    );
    depfileService.writeToFile(
      Depfile(<File>[], outputs),
      environment.buildDir.childFile('flutter_$name.d'),
      writeEmpty: true,
    );
  }
}

/// An implementation of [OhosAssetBundle] that only includes assets.
class AotOhosAssetBundle extends OhosAssetBundle {
  const AotOhosAssetBundle();

  @override
  String get name => 'aot_ohos_asset_bundle';
}

/// Prepares the asset bundle in the format expected by flutter.gradle.
///
/// The vm_snapshot_data, isolate_snapshot_data, and kernel_blob.bin are
/// expected to be in the root output directory.
///
/// All assets and manifests are included from flutter_assets/**.
abstract class OhosAssetBundle extends Target {
  const OhosAssetBundle();

  @override
  List<Source> get inputs => const <Source>[
        Source.pattern('{BUILD_DIR}/app.dill'),
        // ...IconTreeShaker.inputs,
      ];

  @override
  List<Source> get outputs => const <Source>[];

  @override
  List<String> get depfiles => <String>[
        'flutter_assets.d',
      ];

  @override
  Future<void> build(Environment environment) async {
    final String? buildModeEnvironment = environment.defines[kBuildMode];
    if (buildModeEnvironment == null) {
      throw MissingDefineException(kBuildMode, name);
    }
    final BuildMode buildMode = BuildMode.fromCliName(buildModeEnvironment);
    final Directory outputDirectory = environment.outputDir
        .childDirectory('flutter_assets')
      ..createSync(recursive: true);

    // Only copy the prebuilt runtimes and kernel blob in debug mode.
    if (buildMode == BuildMode.debug) {
      final String vmSnapshotData = environment.artifacts
          .getArtifactPath(Artifact.vmSnapshotData, mode: BuildMode.debug);
      final String isolateSnapshotData = environment.artifacts
          .getArtifactPath(Artifact.isolateSnapshotData, mode: BuildMode.debug);
      environment.buildDir
          .childFile('app.dill')
          .copySync(outputDirectory.childFile('kernel_blob.bin').path);
      environment.fileSystem
          .file(vmSnapshotData)
          .copySync(outputDirectory.childFile('vm_snapshot_data').path);
      environment.fileSystem
          .file(isolateSnapshotData)
          .copySync(outputDirectory.childFile('isolate_snapshot_data').path);
    }
    final Depfile assetDepfile = await copyAssets(
      environment,
      outputDirectory,
      targetPlatform: TargetPlatform.ohos,
      buildMode: buildMode,
      flavor: environment.defines[kFlavor],
    );
    final DepfileService depfileService = DepfileService(
      fileSystem: environment.fileSystem,
      logger: environment.logger,
    );
    depfileService.writeToFile(
      assetDepfile,
      environment.buildDir.childFile('flutter_assets.d'),
    );
  }

  @override
  List<Target> get dependencies => const <Target>[
        KernelSnapshot(),
      ];
}
