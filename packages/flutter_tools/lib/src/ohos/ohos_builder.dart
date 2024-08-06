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
