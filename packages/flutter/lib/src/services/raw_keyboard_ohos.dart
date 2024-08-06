/*
* Copyright (c) 2024 Hunan OpenValley Digital Industry Development Co., Ltd.
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

import 'keyboard_maps.g.dart';
import 'raw_keyboard.dart';

/// 左Alt
const int KEYCODE_ALT_LEFT = 2045;

/// 右Alt
const int KEYCODE_ALT_RIGHT = 2046;

/// 左shift
const int KEYCODE_SHIFT_LEFT = 2047;

/// 右shift
const int KEYCODE_SHIFT_RIGHT = 2048;

/// 左ctrl
const int KEYCODE_CTRL_LEFT = 2072;

/// 右ctrl
const int KEYCODE_CTRL_RIGHT = 2073;

/// 功能键
const int KEYCODE_FUNCTION = 2078;

/// 滚动键锁定
const int KEYCODE_SCROLL_LOCK = 2075;

/// 大小写锁定
const int KEYCODE_CAPS_LOCK = 2074;

/// 小键盘锁
const int KEYCODE_NUM_LOCK = 2102;

/// mate left
const int KEYCODE_MATE_LEFT = 2076;

/// mate right
const int KEYCODE_MATE_RIGHT = 2077;

/// 按键类型
enum KeyType {
  /// 按键松开
  keyup,

  /// 按键按下
  keydown
}

/// RawKeyEventData for OpenHarmony platform
class RawKeyEventDataOhos extends RawKeyEventData {
  /// Constructor
  const RawKeyEventDataOhos(
      this._type, this._keyCode, this._deviceId, this._character);

  //按键类型，keyup/keydown
  final String _type;

  // 按键编号
  final int _keyCode;

  // 设备id
  final int _deviceId;

  // 按键键值
  final String _character;

  bool get _isKeyDown => _type == KeyType.keydown.toString();

  @override
  KeyboardSide? getModifierSide(ModifierKey key) {
    KeyboardSide? findSide(int leftMask, int rightMask) {
      if (_keyCode == leftMask) {
        return KeyboardSide.left;
      } else if (_keyCode == rightMask) {
        return KeyboardSide.right;
      }
      return KeyboardSide.all;
    }

    switch (key) {
      case ModifierKey.controlModifier:
        return findSide(KEYCODE_CTRL_LEFT, KEYCODE_CTRL_RIGHT);
      case ModifierKey.shiftModifier:
        return findSide(KEYCODE_SHIFT_LEFT, KEYCODE_SHIFT_RIGHT);
      case ModifierKey.altModifier:
        return findSide(KEYCODE_ALT_LEFT, KEYCODE_ALT_RIGHT);
      case ModifierKey.metaModifier:
        return findSide(KEYCODE_MATE_LEFT, KEYCODE_MATE_RIGHT);
      case ModifierKey.capsLockModifier:
        return (_keyCode == KEYCODE_CAPS_LOCK) ? KeyboardSide.all : null;
      case ModifierKey.numLockModifier:
      case ModifierKey.scrollLockModifier:
      case ModifierKey.functionModifier:
      case ModifierKey.symbolModifier:
        return KeyboardSide.all;
    }
  }

  @override
  bool isModifierPressed(ModifierKey key,
      {KeyboardSide side = KeyboardSide.any}) {
    if (!_isKeyDown) {
      return false;
    }
    switch (key) {
      case ModifierKey.controlModifier:
        return _keyCode == KEYCODE_CTRL_LEFT || _keyCode == KEYCODE_CTRL_RIGHT;
      case ModifierKey.shiftModifier:
        return _keyCode == KEYCODE_SHIFT_LEFT ||
            _keyCode == KEYCODE_SHIFT_RIGHT;
      case ModifierKey.altModifier:
        return _keyCode == KEYCODE_ALT_LEFT || _keyCode == KEYCODE_ALT_RIGHT;
      case ModifierKey.metaModifier:
        return _keyCode == KEYCODE_MATE_LEFT || _keyCode == KEYCODE_MATE_RIGHT;
      case ModifierKey.capsLockModifier:
        return _keyCode == KEYCODE_CAPS_LOCK;
      case ModifierKey.numLockModifier:
        return _keyCode == KEYCODE_NUM_LOCK;
      case ModifierKey.scrollLockModifier:
        return _keyCode == KEYCODE_SCROLL_LOCK;
      case ModifierKey.functionModifier:
        return _keyCode == KEYCODE_FUNCTION;
      case ModifierKey.symbolModifier:
        return false;
    }
  }

  @override
  String get keyLabel => _character;

  @override
  LogicalKeyboardKey get logicalKey {
    if (kOhosToLogicalKey.containsKey(_keyCode)) {
      return kOhosToLogicalKey[_keyCode]!;
    }
    return LogicalKeyboardKey(_keyCode | LogicalKeyboardKey.ohosPlane);
  }

  @override
  PhysicalKeyboardKey get physicalKey {
    if (kOhosToPhysicalKey.containsKey(_keyCode)) {
      return kOhosToPhysicalKey[_keyCode]!;
    }
    return PhysicalKeyboardKey(_keyCode + LogicalKeyboardKey.ohosPlane);
  }
}
