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

import 'ohos_sdk.dart';

const String HDC_SERVER_KEY = 'HDC_SERVER';
const String HDC_SERVER_PORT_KEY = 'HDC_SERVER_PORT';

///
/// return the hdc server config in environment , like 192.168.18.67:8710
///
String? getHdcServer() {
  final String? hdcServer = Platform.environment[HDC_SERVER_KEY];
  if (hdcServer == null) {
    return null;
  }
  final String? hdcServerPort = Platform.environment[HDC_SERVER_PORT_KEY];
  if (hdcServerPort == null) {
    return null;
  }
  return '$hdcServer:$hdcServerPort';
}

String? getHdcServerHost() {
  final String? hdcServer = Platform.environment[HDC_SERVER_KEY];
  if (hdcServer == null) {
    return null;
  }
  return hdcServer;
}

String? getHdcServerPort() {
  final String? hdcServerPort = Platform.environment[HDC_SERVER_PORT_KEY];
  if (hdcServerPort == null) {
    return null;
  }
  return hdcServerPort;
}

List<String> getHdcCommandCompat(
    HarmonySdk ohosSdk, String id, List<String> args) {
  final String? hdcServer = getHdcServer();
  final List<String> hdcServerCommand =
      hdcServer == null ? <String>['-t', id] : <String>['-s', hdcServer];
  return <String>[ohosSdk.hdcPath!, ...hdcServerCommand, ...args];
}
