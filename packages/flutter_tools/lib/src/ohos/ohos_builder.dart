/*
* Copyright 2014 The Flutter Authors. All rights reserved.
* Use of this source code is governed by a BSD-style license that can be
* found in the LICENSE file.
*
*/

import '../base/context.dart';
import '../build_info.dart';
import '../project.dart';

/// The builder in the current context.
OhosBuilder? get ohosBuilder {
  return context.get<OhosBuilder>();
}

abstract class OhosBuilder {
  const OhosBuilder();

  /// build hap
  Future<void> buildHap({
    required FlutterProject project,
    required OhosBuildInfo ohosBuildInfo,
    required String target,
  });

  /// build har
  Future<void> buildHar({
    required FlutterProject project,
    required OhosBuildInfo ohosBuildInfo,
    required String target,
  });

  /// build app
  Future<void> buildApp({
    required FlutterProject project,
    required OhosBuildInfo ohosBuildInfo,
    required String target,
  });

  /// build hsp
  Future<void> buildHsp({
    required FlutterProject project,
    required OhosBuildInfo ohosBuildInfo,
    required String target,
  });
}
