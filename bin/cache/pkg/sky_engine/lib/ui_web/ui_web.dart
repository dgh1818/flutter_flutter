// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

// This library defines the web-specific additions that go along with dart:ui
//
// The web_sdk/sdk_rewriter.dart uses this directive.
// ignore: unnecessary_library_directive
@JS()
library dart.ui_web;

import 'dart:async';
import 'dart:collection';
import 'dart:convert' hide Codec;
import 'dart:developer' as developer;
import 'dart:js_util' as js_util;
import 'dart:_js_annotations';
import 'dart:js_interop' hide JS;
import 'dart:js_interop_unsafe';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:_skwasm_impl' if (dart.library.html) 'dart:_skwasm_stub';
import 'dart:_engine';
import 'dart:_web_unicode';
import 'dart:_web_test_fonts';
import 'dart:_web_locale_keymap' as locale_keymap;


part 'ui_web/asset_manager.dart';
part 'ui_web/benchmarks.dart';
part 'ui_web/browser_detection.dart';
part 'ui_web/flutter_views_proxy.dart';
part 'ui_web/images.dart';
part 'ui_web/initialization.dart';
part 'ui_web/navigation/platform_location.dart';
part 'ui_web/navigation/url_strategy.dart';
part 'ui_web/platform_view_registry.dart';
part 'ui_web/plugins.dart';
part 'ui_web/testing.dart';
