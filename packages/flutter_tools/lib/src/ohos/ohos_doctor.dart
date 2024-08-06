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

import 'package:process/process.dart';

import '../base/context.dart';
import '../base/file_system.dart';
import '../base/io.dart';
import '../base/logger.dart';
import '../base/os.dart';
import '../base/platform.dart';
import '../base/user_messages.dart';
import '../base/version.dart';
import '../doctor_validator.dart';
import '../globals.dart' as globals;
import 'ohos_sdk.dart';

OhosValidator? get ohosValidator => context.get<OhosValidator>();

/// A combination of version description and parsed version number.
class _VersionInfo {
  /// Constructs a VersionInfo from a version description string.
  ///
  /// This should contain a version number. For example:
  ///     "clang version 9.0.1-6+build1"
  _VersionInfo(this.description) {
    final String? versionString = RegExp(r'[0-9]+\.[0-9]+(?:\.[0-9]+)?')
        .firstMatch(description)
        ?.group(0);
    number = Version.parse(versionString);
  }

  // The full info string reported by the binary.
  String description;

  // The parsed Version.
  Version? number;
}

class OhosValidator extends DoctorValidator {
  OhosValidator({
    required HarmonySdk? ohosSdk,
    required FileSystem fileSystem,
    required Logger logger,
    required Platform platform,
    required ProcessManager processManager,
    required UserMessages userMessages,
  })  : _hosSdk = ohosSdk,
        _fileSystem = fileSystem,
        _logger = logger,
        _operatingSystemUtils = OperatingSystemUtils(
          fileSystem: fileSystem,
          logger: logger,
          platform: platform,
          processManager: processManager,
        ),
        _platform = platform,
        _processManager = processManager,
        _userMessages = userMessages,
        super('HarmonyOS toolchain - develop for HarmonyOS devices');

  final HarmonySdk? _hosSdk;
  final FileSystem _fileSystem;
  final Logger _logger;
  final OperatingSystemUtils _operatingSystemUtils;
  final Platform _platform;
  final ProcessManager _processManager;
  final UserMessages _userMessages;

  final bool isWindows = globals.platform.isWindows;

  @override
  Future<ValidationResult> validate() async {
    ValidationType validationType = ValidationType.success;
    final List<ValidationMessage> messages = <ValidationMessage>[];

    /// check ohos sdk exist and version correct
    if (HarmonySdk.locateHarmonySdk() != null ) {
      messages.add(ValidationMessage(_userMessages.ohosSdkVersion(_hosSdk!)));
    } else {
      validationType = ValidationType.missing;
      if (_hosSdk != null) {
        messages.add(ValidationMessage.error(
            _userMessages.ohosSdkMissing((_hosSdk?.sdkPath) ?? '')));
      }
      messages
          .add(ValidationMessage.error(_userMessages.hosSdkInstallation()));
    }

    /// check ohpm
    final _VersionInfo? ohpmVersion = await _getBinaryVersion(<String>['ohpm', '--version']);
    final String? ohpmVersionString = ohpmVersion?.description;
    if (ohpmVersionString == null) {
      validationType = ValidationType.missing;
      messages.add(ValidationMessage.error(_userMessages.ohpmMissing()));
    } else {
      messages
          .add(ValidationMessage(_userMessages.ohpmVersion(ohpmVersionString)));
    }

    /// check node
    final _VersionInfo? nodeVersion = await _getBinaryVersion(<String>['node', '--version']);
    final String? nodeVersionString = nodeVersion?.description;
    if (nodeVersionString == null) {
      validationType = ValidationType.missing;
      messages.add(ValidationMessage.error(_userMessages.nodeMissing()));
    } else {
      messages
          .add(ValidationMessage(_userMessages.nodeVersion(nodeVersionString)));
    }

    /// check hvigorw
    final _VersionInfo? hvigorPath;
    if (_platform.isWindows) {
      hvigorPath = await _getBinaryVersion(<String>['where', 'hvigorw']);
    } else {
      hvigorPath = await _getBinaryVersion(<String>['which', 'hvigorw']);
    }
    final String? hvigorPathString = hvigorPath?.description;
    if (hvigorPathString == null) {
      validationType = ValidationType.missing;
      messages.add(ValidationMessage.error(_userMessages.hvigorwMissing()));
    } else {
      messages
          .add(ValidationMessage(_userMessages.hvigorwPath(hvigorPathString)));
    }
    return ValidationResult(validationType, messages);
  }

  /// Returns the installed version of [binary], or null if it's not installed.
  ///
  /// Requires tha [binary] take a '--version' flag, and print a version of the
  /// form x.y.z somewhere on the first line of output.
  Future<_VersionInfo?> _getBinaryVersion(List<Object> commands) async {
    ProcessResult? result;
    try {
      result = await _processManager.run(commands);
    } on ArgumentError {
      // ignore error.
    } on ProcessException {
      // ignore error.
    }
    if (result == null || result.exitCode != 0) {
      return null;
    }
    final String firstLine = (result.stdout as String).split('\n').first.trim();
    return _VersionInfo(firstLine);
  }
}
