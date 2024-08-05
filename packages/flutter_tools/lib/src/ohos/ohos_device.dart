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

import 'dart:async';
import 'dart:math';

import 'package:process/process.dart';

import '../application_package.dart';
import '../base/common.dart';
import '../base/file_system.dart';
import '../base/io.dart';
import '../base/logger.dart';
import '../base/platform.dart';
import '../base/process.dart';
import '../build_info.dart';
import '../convert.dart';
import '../device.dart';
import '../device_port_forwarder.dart';
import '../globals.dart' as globals;
import '../project.dart';
import '../protocol_discovery.dart';
import 'application_package.dart';
import 'hdc_server.dart';
import 'ohos_builder.dart';
import 'ohos_sdk.dart';

class OhosDevice extends Device {
  OhosDevice(
    super.id, {
    this.deviceCodeName,
    required Logger logger,
    required ProcessManager processManager,
    required Platform platform,
    required HarmonySdk ohosSdk,
    required FileSystem fileSystem,
    required String? hdcServer,
  })  : _logger = logger,
        _processManager = processManager,
        _ohosSdk = ohosSdk,
        _platform = platform,
        _fileSystem = fileSystem,
        _processUtils =
            ProcessUtils(logger: logger, processManager: processManager),
        _hdcServer = hdcServer,
        super(
          category: Category.mobile,
          platformType: PlatformType.ohos,
          ephemeral: true,
        );

  final Logger _logger;
  final ProcessManager _processManager;
  final HarmonySdk _ohosSdk;
  final Platform _platform;
  final FileSystem _fileSystem;
  final ProcessUtils _processUtils;
  final String? _hdcServer;
  final String? deviceCodeName;

  @override
  void clearLogs() {
    // clear hilog history
    _processUtils
        .runSync(hdcCommandForDevice(<String>['shell', 'hilog', '-r']));
  }

  @override
  Future<void> dispose() async {
    _logReader?._stop();
    _pastLogReader?._stop();
  }

  @override
  Future<String?> get emulatorId async => id;

  HdcLogReader? _logReader;
  HdcLogReader? _pastLogReader;

  @override
  FutureOr<DeviceLogReader> getLogReader({
    ApplicationPackage? app,
    bool includePastLogs = false,
  }) async {
    if (includePastLogs) {
      return _pastLogReader ??= await HdcLogReader.createLogReader(
        this,
        _processManager,
        includePastLogs: true,
      );
    } else {
      return _logReader ??= await HdcLogReader.createLogReader(
        this,
        _processManager,
      );
    }
  }

  @override
  bool get supportsScreenshot => true;

  @override
  Future<void> takeScreenshot(File outputFile) async {
    const String remotePath = '/data/local/tmp/flutter_screenshot.jpeg';
    await runHdcCheckedAsync(
        <String>['shell', 'snapshot_display', '-f', remotePath]);
    await _processUtils.run(
      hdcCommandForDevice(<String>['file recv', remotePath, outputFile.path]),
      throwOnError: true,
    );
    await runHdcCheckedAsync(<String>['shell', 'rm', remotePath]);
  }

  Future<bool> _installApp(covariant ApplicationPackage app,
      {String? userIdentifier}) async {
    if (app is! OhosHap) {
      throwToolExit('this project or file is not contain(a) Hap file');
    }
    final OhosHap hap = app;
    final File file = globals.fs.file(hap.applicationPackage.path);
    if (!file.existsSync()) {
      throwToolExit('Failed to get the hap file: ${file.path}');
    }

    _logger.printStatus('installing hap. bundleName: ${app.id} ');
    const String targetPath = 'data/local/tmp/flutterInstallTemp';
    final List<List<String>> hspCmds = app.ohosBuildData.moduleInfo.moduleList
        .where((OhosModule module) => module.type == OhosModuleType.shared)
        .map((OhosModule module) => OhosProject.getSignedFile(
              modulePath: module.srcPath,
              moduleName: module.name,
              flavor: module.flavor,
              type: OhosFileType.hsp,
            ))
        .map((File file) => <String>['file', 'send', file.path, targetPath])
        .toList();
    final List<List<String>> cmds = <List<String>>[
      <String>['shell', 'rm', '-rf', targetPath],
      <String>['shell', 'mkdir', targetPath],
      ...hspCmds,
      <String>['file', 'send', hap.applicationPackage.path, targetPath],
      <String>['shell', 'bm', 'install', '-p', targetPath],
      <String>['shell', 'rm', '-rf', targetPath],
    ].map((List<String> cmd) => hdcCommandForDevice(cmd)).toList();

    RunResult? result;
    for (final List<String> cmd in cmds) {
      result = _processUtils.runSync(cmd, throwOnError: true);
      if (result.exitCode != 0 || result.stdout.contains('error')) {
        _logger.printError('_installApp: cmd=$cmd\n  code=${result.exitCode}, stdout=${result.stdout}, stderr=${result.stderr}');
        return false;
      }
    }
    return result != null && result.exitCode == 0;
  }

  @override
  Future<bool> isAppInstalled(covariant ApplicationPackage app,
      {String? userIdentifier}) async {
    final String bundleName = app.id;
    final List<String> propCommand =
        hdcCommandForDevice(<String>['shell', '"bm dump -n $bundleName"']);
    _logger.printTrace(propCommand.join(' '));
    final RunResult result = _processUtils.runSync(propCommand);
    if (result.exitCode == 0) {
      final String cmdResult = result.stdout;
      if (cmdResult.contains(bundleName)) {
        return true;
      } else if (cmdResult.contains('error: failed to get information')) {
        return false;
      } else {
        throw ToolExit('unknown result for bm dump.');
      }
    }
    return false;
  }

  @override
  Future<bool> isLatestBuildInstalled(covariant ApplicationPackage app) async {
    return false;
  }

  @override
  late final Future<bool> isLocalEmulator = () async {
    return false;
  }();

  @override
  bool isSupported() {
    return true;
  }

  @override
  bool isSupportedForProject(FlutterProject flutterProject) {
    return flutterProject.ohos.existsSync();
  }

  @override
  String get name => deviceCodeName ?? 'unknown';

  @override
  late final DevicePortForwarder? portForwarder = () {
    final String? hdcPath = _ohosSdk.hdcPath;
    if (hdcPath == null) {
      return null;
    }
    return OhosDevicePortForwarder(
      processManager: _processManager,
      logger: _logger,
      deviceId: id,
      hdcPath: hdcPath,
      ohosDevice: this,
    );
  }();

  @override
  Future<String> get sdkNameAndVersion async =>
      'Ohos ${await _sdkVersion} (API ${await apiVersion})';

  Future<String?> get _sdkVersion => _getProperty('const.ohos.fullname');

  Future<String?> get apiVersion => _getProperty('const.ohos.apiversion');

  OhosHap? _package;

  @override
  Future<LaunchResult> startApp(covariant ApplicationPackage? package,
      {String? mainPath,
      String? route,
      required DebuggingOptions debuggingOptions,
      Map<String, Object?> platformArgs = const <String, Object>{},
      bool prebuiltApplication = false,
      bool ipv6 = false,
      String? userIdentifier}) async {
    ///
    /// 1. check build status
    /// 2. build or not
    /// 3. install or not
    /// 4. start app command
    ///

    final TargetPlatform devicePlatform = await targetPlatform;
    OhosHap? builtPackage = package as OhosHap?;
    OhosArch ohosArch;
    switch (devicePlatform) {
      case TargetPlatform.ohos_arm64:
        ohosArch = OhosArch.arm64_v8a;
      case TargetPlatform.ohos_arm:
        ohosArch = OhosArch.armeabi_v7a;
      case TargetPlatform.ohos_x64:
        ohosArch = OhosArch.x86_64;
      case TargetPlatform.ohos:
      case TargetPlatform.android:
      case TargetPlatform.darwin:
      case TargetPlatform.fuchsia_arm64:
      case TargetPlatform.fuchsia_x64:
      case TargetPlatform.ios:
      case TargetPlatform.linux_arm64:
      case TargetPlatform.linux_x64:
      case TargetPlatform.tester:
      case TargetPlatform.web_javascript:
      case TargetPlatform.windows_x64:
      case TargetPlatform.android_arm:
      case TargetPlatform.android_arm64:
      case TargetPlatform.android_x64:
      case TargetPlatform.android_x86:
      case TargetPlatform.windows_arm64:
        _logger.printError('Ohos platforms are only supported.');
        return LaunchResult.failed();
    }

    if (!prebuiltApplication) {
      _logger.printTrace('Building Hap');
      final FlutterProject project = FlutterProject.current();
      await ohosBuilder?.buildHap(
        project: project,
        ohosBuildInfo: OhosBuildInfo(
          debuggingOptions.buildInfo,
          targetArchs: <OhosArch>[ohosArch],
        ),
        target: mainPath ?? 'lib/main.dart',
      );

      builtPackage = await ApplicationPackageFactory.instance!
          .getPackageForPlatform(devicePlatform,
              buildInfo: debuggingOptions.buildInfo) as OhosHap?;
    }
    // There was a failure parsing the android project information.
    if (builtPackage == null) {
      throwToolExit('Problem building Ohos application: see above error(s).');
    }

    _logger.printTrace("Stopping app '${builtPackage.name}' on $name.");
    await stopApp(builtPackage, userIdentifier: userIdentifier);

    if (!await installApp(builtPackage, userIdentifier: userIdentifier)) {
      return LaunchResult.failed();
    }

    final bool traceStartup = platformArgs['trace-startup'] as bool? ?? false;
    ProtocolDiscovery? observatoryDiscovery;

    if (debuggingOptions.debuggingEnabled) {
      observatoryDiscovery = ProtocolDiscovery.vmService(
        // Avoid using getLogReader, which returns a singleton instance, because the
        // observatory discovery will dipose at the end. creating a new logger here allows
        // logs to be surfaced normally during `flutter drive`.
        await HdcLogReader.createLogReader(
          this,
          _processManager,
        ),
        portForwarder: portForwarder,
        hostPort: debuggingOptions.hostVmServicePort,
        devicePort: debuggingOptions.deviceVmServicePort,
        ipv6: ipv6,
        logger: _logger,
      );
    }
    final List<String> cmd = <String>[
      'shell',
      'aa',
      'start',
      '-a',
      builtPackage.ohosBuildData.moduleInfo.mainElement!,
      '-b',
      builtPackage.ohosBuildData.appInfo!.bundleName,
    ];
    final String result = (await runHdcCheckedAsync(cmd)).stdout;
    // This invocation returns 0 even when it fails.
    if (result.toLowerCase().contains('error')) {
      _logger.printError(result.trim(), wrap: false);
      return LaunchResult.failed();
    }

    _package = builtPackage;
    if (!debuggingOptions.debuggingEnabled) {
      return LaunchResult.succeeded();
    }

    // Wait for the service protocol port here. This will complete once the
    // device has printed "Observatory is listening on...".
    _logger.printTrace('Waiting for observatory port to be available...');
    try {
      Uri? observatoryUri;
      if (debuggingOptions.buildInfo.isDebug ||
          debuggingOptions.buildInfo.isProfile) {
        observatoryUri = await observatoryDiscovery?.uri;
        _logger.printWarning('waiting for a debug connection: $observatoryUri');
        if (observatoryUri == null) {
          _logger.printError(
            'Error waiting for a debug connection: '
            'The log reader stopped unexpectedly',
          );
          return LaunchResult.failed();
        }
      }
      return LaunchResult.succeeded(observatoryUri: observatoryUri);
    } on Exception catch (error) {
      _logger.printError('Error waiting for a debug connection: $error');
      return LaunchResult.failed();
    } finally {
      await observatoryDiscovery?.cancel();
    }
  }

  @override
  Future<bool> installApp(covariant ApplicationPackage app,
      {String? userIdentifier}) async {
    final bool wasInstalled =
        await isAppInstalled(app, userIdentifier: userIdentifier);
    _logger.printTrace('Installing Hap.');
    if (await _installApp(app, userIdentifier: userIdentifier)) {
      return true;
    }
    _logger.printTrace('Warning: Failed to install Hap.');
    if (!wasInstalled) {
      return false;
    }
    _logger.printStatus('Uninstalling old version...');
    if (!await uninstallApp(app, userIdentifier: userIdentifier)) {
      _logger.printError('Error: Uninstalling old version failed.');
      return false;
    }
    if (!await _installApp(app, userIdentifier: userIdentifier)) {
      _logger.printError('Error: Failed to install Hap again.');
      return false;
    }
    return true;
  }

  @override
  Future<bool> stopApp(covariant ApplicationPackage? app,
      {String? userIdentifier}) async {
    if (app == null) {
      return false;
    }
    final RunResult result = _processUtils.runSync(
      hdcCommandForDevice(<String>['shell', 'aa', 'force-stop', app.id]),
    );
    return result.exitCode == 0;
  }

  @override
  late final Future<TargetPlatform> targetPlatform = () async {
    // const.product.cpu.abilist = arm64-v8a
    final String? abilist = await _getProperty('const.product.cpu.abilist');
    if (abilist == null) {
      return TargetPlatform.ohos_arm64;
    } else if (abilist.contains('arm64-v8a')) {
      return TargetPlatform.ohos_arm64;
    } else if (abilist.contains('x64')) {
      return TargetPlatform.ohos_x64;
    } else {
      return TargetPlatform.ohos_arm64;
    }
  }();

  @override
  Future<bool> uninstallApp(covariant ApplicationPackage app,
      {String? userIdentifier}) async {
    final List<String> uninstallCommand =
        hdcCommandForDevice(<String>['uninstall', app.id]);
    final RunResult result =
        _processUtils.runSync(uninstallCommand, throwOnError: true);
    return result.exitCode == 0;
  }

  Future<String?> _getProperty(String name) async {
    return (await _properties)[name];
  }

  List<String> hdcCommandForDevice(List<String> args) {
    return getHdcCommandCompat(_ohosSdk, id, args);
  }

  Future<RunResult> runHdcCheckedAsync(
    List<String> params, {
    String? workingDirectory,
    bool allowReentrantFlutter = false,
  }) async {
    return _processUtils.run(
      hdcCommandForDevice(params),
      throwOnError: true,
      workingDirectory: workingDirectory,
      allowReentrantFlutter: allowReentrantFlutter,
    );
  }

  late final Future<Map<String, String>> _properties = () async {
    Map<String, String> properties = <String, String>{};

    final List<String> propCommand =
        hdcCommandForDevice(<String>['shell', 'param', 'get']);
    _logger.printTrace(propCommand.join(' '));
    final RunResult result =
        _processUtils.runSync(propCommand, throwOnError: true);

    if (result.exitCode == 0) {
      properties = parseHdcDeviceProperties(result.stdout);
    }
    return properties;
  }();

  Map<String, String> parseHdcDeviceProperties(String str) {
    final Map<String, String> properties = <String, String>{};
    final List<String> split = str.split('\r\n');
    for (final String line in split) {
      // some properties value may contain '=' char,but key not
      final int indexOf = line.indexOf('=');
      if (indexOf == -1) {
        continue;
      }
      final String key = line.substring(0, indexOf).trim();
      final String value = line.substring(indexOf + 1).trim();
      properties[key] = value;
    }
    return properties;
  }
}

/// A [DevicePortForwarder] implemented for Ohos devices that uses hdc.
class OhosDevicePortForwarder extends DevicePortForwarder {
  OhosDevicePortForwarder({
    required ProcessManager processManager,
    required Logger logger,
    required String deviceId,
    required String hdcPath,
    required OhosDevice ohosDevice,
  })  : _deviceId = deviceId,
        _hdcPath = hdcPath,
        _logger = logger,
        _processUtils =
            ProcessUtils(logger: logger, processManager: processManager),
        _ohosDevice = ohosDevice;

  final String _deviceId;
  final String _hdcPath;
  final Logger _logger;
  final ProcessUtils _processUtils;
  final OhosDevice _ohosDevice;

  static int? _extractPort(String portString) {
    return int.tryParse(portString.trim());
  }

  @override
  List<ForwardedPort> get forwardedPorts {
    final List<ForwardedPort> ports = <ForwardedPort>[];

    String stdout;
    try {
      stdout = _processUtils
          .runSync(
            _ohosDevice.hdcCommandForDevice(<String>[
              'fport',
              'ls',
            ]),
            throwOnError: true,
          )
          .stdout
          .trim();
    } on ProcessException catch (error) {
      _logger.printError('Failed to list forwarded ports: $error.');
      return ports;
    }

    final List<String> lines = LineSplitter.split(stdout).toList();
    for (final String line in lines) {
      if (!line.startsWith(_deviceId)) {
        continue;
      }
      final List<String> splitLine = line.split('tcp:');

      // Sanity check splitLine.
      if (splitLine.length != 3) {
        continue;
      }

      // Attempt to extract ports.
      final int? hostPort = _extractPort(splitLine[1]);
      final int? devicePort = _extractPort(splitLine[2]);

      // Failed, skip.
      if (hostPort == null || devicePort == null) {
        continue;
      }

      ports.add(ForwardedPort(hostPort, devicePort));
    }

    return ports;
  }

  /// return one random port num , between [50000 ~ 65535]
  int getOneRandomPort() {
    const int min = 50000;
    const int max = 65535;
    return min + Random().nextInt(max - min);
  }

  @override
  Future<int> forward(int devicePort, {int? hostPort}) async {
    /// if host port == 0 , hdc will tip '[Fail]Forward parament failed' , so give a random port
    hostPort ??= getOneRandomPort();

    final RunResult process = await _processUtils.run(
      _ohosDevice.hdcCommandForDevice(<String>[
        'fport',
        'tcp:$hostPort',
        'tcp:$devicePort',
      ]),
      throwOnError: true,
    );

    if (process.stderr.isNotEmpty) {
      process.throwException('hdc returned error:\n${process.stderr}');
    }

    if (process.exitCode != 0) {
      if (process.stdout.isNotEmpty) {
        process.throwException('hdc returned error:\n${process.stdout}');
      }
      process.throwException('hdc failed without a message');
    }

    if (hostPort == 0) {
      if (process.stdout.isEmpty) {
        process.throwException('hdc did not report forwarded port');
      }
      hostPort = int.tryParse(process.stdout);
      if (hostPort == null) {
        process.throwException('hdc forward error:\n${process.stdout}');
      }
    } else {
      if (process.stdout.isNotEmpty && !process.stdout.trim().contains('OK')) {
        process.throwException('hdc returned error:\n${process.stdout}');
      }
    }

    return hostPort!;
  }

  @override
  Future<void> unforward(ForwardedPort forwardedPort) async {
    final RunResult runResult = await _processUtils.run(
      _ohosDevice.hdcCommandForDevice(<String>[
        'fport',
        'rm',
        'tcp:${forwardedPort.hostPort}',
        'tcp:${forwardedPort.devicePort}',
      ]),
    );
    if (runResult.exitCode == 0) {
      return;
    }
    _logger.printError('Failed to unforward port: $runResult');
  }

  @override
  Future<void> dispose() async {
    for (final ForwardedPort port in forwardedPorts) {
      await unforward(port);
    }
  }
}

/// A log reader that logs from `hdc hilog`.
class HdcLogReader extends DeviceLogReader {
  HdcLogReader._(this._hdcProcess, this.name);

  /// Create a new [HdcLogReader] from an [OhosDevice] instance.
  static Future<HdcLogReader> createLogReader(
    OhosDevice device,
    ProcessManager processManager, {
    bool includePastLogs = false,
  }) async {
    final List<String> args = <String>[
      'shell',
      'hilog',
    ];

    // If past logs are included then filter for 'flutter' logs only.
    if (includePastLogs) {
      args.addAll(<String>['-T', 'flutter']);
    } else {
      // if not includePastLogs, execute clear log.
      device.clearLogs();
    }
    final Process process =
        await processManager.start(device.hdcCommandForDevice(args));
    return HdcLogReader._(process, device.name);
  }

  final Process _hdcProcess;

  @override
  final String name;

  late final StreamController<String> _linesController =
      StreamController<String>.broadcast(
    onListen: _start,
    onCancel: _stop,
  );

  @override
  Stream<String> get logLines => _linesController.stream;

  void _start() {
    const Utf8Decoder decoder = Utf8Decoder(reportErrors: false);
    _hdcProcess.stdout
        .transform<String>(decoder)
        .transform<String>(const LineSplitter())
        .listen(_onLine);
    _hdcProcess.stderr
        .transform<String>(decoder)
        .transform<String>(const LineSplitter())
        .listen(_onLine);
    unawaited(_hdcProcess.exitCode.whenComplete(() {
      if (_linesController.hasListener) {
        _linesController.close();
      }
    }));
  }

  // 10-27 19:57:53.779  1195  2885 I Thread:528202332952  [INFO:ohos_main.cpp(140)] flutter The Dart VM service is listening on http://0.0.0.0:34063/nBIFd7ZPwk0=/
  static final RegExp _logFormat = RegExp(r'^[\d-:. ]{30,40}[VDIWEF][^:]+:');

  static final List<RegExp> _allowedTags = <RegExp>[
    RegExp(r'^[\d-:. ]{30,40}[VDIWEF]\s[^:]+Flutter[^:]+:\sflutter\s'),
    RegExp(r'^[\d-:. ]{30,40}[IE].*Dart VM\s+'),
    RegExp(r'^[WEF]\/System\.err:\s+'),
    RegExp(r'^[F]\/[\S^:]+:\s+'),
  ];

  // 'F/libc(pid): Fatal signal 11'
  static final RegExp _fatalLog =
      RegExp(r'^F\/libc\s*\(\s*\d+\):\sFatal signal (\d+)');

  // 'I/DEBUG(pid): ...'
  static final RegExp _tombstoneLine =
      RegExp(r'^[IF]\/DEBUG\s*\(\s*\d+\):\s(.+)$');

  // 'I/DEBUG(pid): Tombstone written to: '
  static final RegExp _tombstoneTerminator =
      RegExp(r'^Tombstone written to:\s');

  // we default to true in case none of the log lines match
  bool _acceptedLastLine = true;

  // Whether a fatal crash is happening or not.
  // During a fatal crash only lines from the crash are accepted, the rest are
  // dropped.
  bool _fatalCrash = false;

  // The format of the line is controlled by the '-v' parameter passed to
  // adb logcat. We are currently passing 'time', which has the format:
  // mm-dd hh:mm:ss.milliseconds Priority/Tag( PID): ....
  void _onLine(String line) {
    // This line might be processed after the subscription is closed but before
    // adb stops streaming logs.
    if (_linesController.isClosed) {
      return;
    }
    final Match? logMatch = _logFormat.firstMatch(line);
    if (logMatch != null) {
      bool acceptLine = false;

      if (_fatalCrash) {
        // While a fatal crash is going on, only accept lines from the crash
        // Otherwise the crash log in the console may get interrupted
        final Match? fatalMatch = _tombstoneLine.firstMatch(line);

        if (fatalMatch != null) {
          acceptLine = true;

          line = fatalMatch[1]!;

          if (_tombstoneTerminator.hasMatch(line)) {
            // Hit crash terminator, stop logging the crash info
            _fatalCrash = false;
          }
        }
      } else {
        // Filter on approved names and levels.
        acceptLine = _allowedTags.any((RegExp re) => re.hasMatch(line));
      }

      if (acceptLine) {
        _acceptedLastLine = true;
        _linesController.add(line);
        return;
      }
      _acceptedLastLine = false;
    } else if (line == '--------- beginning of system' ||
        line == '--------- beginning of main') {
      _acceptedLastLine = false;
    } else {
      if (_acceptedLastLine) {
        _linesController.add(line);
        return;
      }
    }
  }

  void _stop() {
    _linesController.close();
    _hdcProcess.kill();
  }

  @override
  void dispose() {
    _stop();
  }
}
