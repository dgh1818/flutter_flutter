# Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd.
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

#!/usr/bin/python
import sys
import platform

ARCH=platform.machine()

if (ARCH=='x86_64'):
    ARCH='x64'

# 请在release.py或者debug.py第一个命令行参数中，定义
project_root = "not defined"

def checkArgs():
    # 获取命令行参数列表
    args = sys.argv
    # 打印传递的参数
    if len(args) <= 1:
        print("没有在命令行传递要编译项目的根目录参数，请检查")
        return False
    else:
        global project_root
        project_root = args[1]
        print("当前正编译的项目路径为：{}".format(project_root))
        return True

# debug engin产物
debug_out_root = "../../src/out/ohos_debug_unopt_arm64"
# release engine产物
release_out_root = "../../src/out/ohos_release_arm64"



host_out_root = release_out_root + "/clang_" + ARCH
gen_snapshot = 	host_out_root + "/gen_snapshot"


def getOutRoot(isDebug=True):
    return debug_out_root if isDebug else release_out_root


def getFrontendServerDartSnapshot(isDebug=True):
    return getOutRoot(isDebug) + "/dart-sdk/bin/snapshots/frontend_server.dart.snapshot"


def getFlutterPatchedSdkProduct(isDebug=True):
    return getOutRoot(isDebug) + "/flutter_patched_sdk"


def getVmIsolateSnapshotBin(isDebug=True):
    return getOutRoot(isDebug) + "/gen/flutter/lib/snapshot/vm_isolate_snapshot.bin"


def getIsolateSnapshotBin(isDebug=True):
    return getOutRoot(isDebug) + "/gen/flutter/lib/snapshot/isolate_snapshot.bin"


def getMainPath():
    return project_root + "/lib/main.dart"


# Flutter根目录
flutter_root = ".."

dart_sdk_path = '../bin/cache/dart-sdk'
resource_sdk_path_debug = './resource/dart-sdk-debug'
resource_sdk_path_release = './resource/dart-sdk-release'

# 下面是构建所需文件
dart_path = "../../src/out/ohos_release_arm64/clang_" + ARCH + "/dart"

flutter_path = flutter_root + "/bin/flutter"

# package，和project_root相关的路径，都要临时获取
def getDarkToolPath():
    return project_root + "/.dart_tool"
def getPackagePath():
    return getDarkToolPath() + "/package_config.json"


# debug产出目录
out_path = "./debug_out/"
dill_name = "app.dill"

debug_out_desc = "Debug编译完成！产物路径:flutter/app_build/debug_out，资源请拷贝：flutter/app_build/flutter_assets"
release_out_desc = "Release编译完成！产物路径:flutter/app_build/release_out，资源请拷贝：flutter/app_build/flutter_assets"

dill_out_file = out_path + dill_name
out_kernel_blob_bin = out_path + "kernel_blob.bin"
out_vm_snapshot_data = out_path + "vm_snapshot_data"
out_isolate_snapshot_data = out_path + "isolate_snapshot_data"

# release产出目录
release_out_path = "./release_out/"
release_dill_out_file = release_out_path + dill_name

# 缓存目录，在flutter的外层目录，因为 Cannot create a project within the Flutter SDK. Target directory '/home/xuchang/code/flutter/app_build/cache/hello_world' is within the Flutter SDK at '/home/xuchang/code/flutter'.
cache_dir = "../../.cache/"
cache_project_name = "hello_world"
cache_project_path = cache_dir + cache_project_name
cache_project_dart_tool = cache_project_path + "/.dart_tool"

def getFlutterAssetsPath():
    return  project_root + "/build/flutter_assets"
flutter_assets_target_path = "./flutter_assets"
