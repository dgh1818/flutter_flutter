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

import '../base/common.dart';
import '../base/file_system.dart';
import '../base/io.dart';
import '../base/logger.dart';
import '../base/platform.dart';
import '../base/process.dart';
import '../base/user_messages.dart';
import '../device.dart';
import 'hdc_server.dart';
import 'ohos_device.dart';
import 'ohos_sdk.dart';
import 'ohos_workflow.dart';

class OhosDevices extends PollingDeviceDiscovery {
  OhosDevices({
    required OhosWorkflow ohosWorkflow,
    required ProcessManager processManager,
    required Logger logger,
    HarmonySdk? ohosSdk,
    required FileSystem fileSystem,
    required Platform platform,
    required UserMessages userMessages,
  })  : _ohosWorkflow = ohosWorkflow,
        _processUtils = ProcessUtils(
          logger: logger,
          processManager: processManager,
        ),
        _ohosSdk = ohosSdk,
        _processManager = processManager,
        _logger = logger,
        _fileSystem = fileSystem,
        _platform = platform,
        _userMessages = userMessages,
        super('HarmonyOS devices');

  final OhosWorkflow _ohosWorkflow;
  final ProcessUtils _processUtils;
  final ProcessManager _processManager;
  final Logger _logger;
  final FileSystem _fileSystem;
  final Platform _platform;
  final UserMessages _userMessages;
  final HarmonySdk? _ohosSdk;

  bool _doesNotHaveHdc() {
    return _ohosSdk == null ||
        _ohosSdk?.hdcPath == null ||
        !_processManager.canRun(_ohosSdk!.hdcPath);
  }

  @override
  Future<List<Device>> pollingGetDevices({Duration? timeout}) async {
    if (_doesNotHaveHdc()) {
      return <OhosDevice>[];
    }
    String text;

    final List<String> cmd = getHdcCommandCompat(_ohosSdk!, '', <String>['list', 'targets']);

    try {
      text = (await _processUtils.run(
        cmd,
        throwOnError: true,
      ))
          .stdout
          .trim();
      // _logger.printStatus('hdc list result:\n$text');
    } on ProcessException catch (exception) {
      throwToolExit(
        'Unable to run "hdc", check your Ohos SDK installation and '
        '$kOhosSdkRoot environment variable: ${exception.executable}',
      );
    }
    final List<OhosDevice> devices = <OhosDevice>[];
    _parseHdcDeviceOutput(
      text,
      devices: devices,
    );
    return devices;
  }

  @override
  bool get supportsPlatform => _ohosWorkflow.appliesToHostPlatform;

  @override
  bool get canListAnything => _ohosWorkflow.canListDevices;

  void _parseHdcDeviceOutput(
    String text, {
    List<OhosDevice>? devices,
    List<String>? diagnostics,
    String? hdcServer,
  }) {
    // return empty if do not discovery any devices
    if (text.contains('[Empty]') || text.contains('connect failed')) {
      diagnostics?.add(text);
      return;
    }

    for (final String line in text.trim().split('\n')) {
      final String deviceId = line.trim();
      devices?.add(OhosDevice(
        deviceId,
        deviceCodeName: deviceId,
        ohosSdk: _ohosSdk!,
        fileSystem: _fileSystem,
        logger: _logger,
        platform: _platform,
        processManager: _processManager,
        hdcServer: hdcServer,
      ));
    }
  }

  @override
  List<String> get wellKnownIds => const <String>[];
}
