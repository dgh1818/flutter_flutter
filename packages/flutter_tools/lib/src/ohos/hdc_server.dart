/*
* Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd. All rights reserved.
* Use of this source code is governed by a BSD-style license that can be
* found in the LICENSE_KHZG file.
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
