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
import excute_util
import shutil
import os
import config
import env_util

hasInit = False

# 执行命令行


def excute(cmd, path="."):
    return excute_util.excute(cmd, path)


def checkExists(file):
    if not os.path.exists(file):
        print("该文件{}不存在，请检查环境".format(file))
        return False
    return True

# 检查环境


def checkEnv(isDebug=True):
    if not checkExists(config.getOutRoot(isDebug)):
        return False
    if not checkExists(config.getFrontendServerDartSnapshot(isDebug)):
        return False
    if not checkExists(config.getFlutterPatchedSdkProduct(isDebug)):
        return False
    if not checkExists(config.getVmIsolateSnapshotBin(isDebug)):
        return False
    if not checkExists(config.getIsolateSnapshotBin(isDebug)):
        return False
    if not checkExists(config.getMainPath()):
        return False
    if not checkExists(config.project_root):
        return False
    global hasInit
    hasInit = os.path.exists(config.dart_sdk_path)
    print("flutter是否已初始化："+str(hasInit))
    env_util.setEnv("PUB_HOSTED_URL", "https://pub.flutter-io.cn")
    env_util.setEnv("FLUTTER_STORAGE_BASE_URL",
                    "https://storage.flutter-io.cn")
    return True

# flutter初始化，执行flutter指令，会缓存dark环境到/bin/cache/..
def flutterInit():
    if not hasInit:
        print('执行首次flutter初始化，时间会比较长')
        excute('../bin/flutter')

# 拷贝resource/darkSdk替换当前flutter darkSdk，因为默认darkSdk，会校验 sdk_hash，而resource/darkSdk下的已经修改 verify_sdk_hash = false
def copyDarkSdk(isDebug=True):
    source = config.resource_sdk_path_debug if isDebug else config.resource_sdk_path_release
    if os.path.exists(config.dart_sdk_path):
        shutil.rmtree(config.dart_sdk_path)
    shutil.copytree(source, config.dart_sdk_path)
    print('dark_sdk替换结束')

# 构建dill命令
def build(isDebug=True):
    out_path = config.out_path if isDebug else config.release_out_path
    if not os.path.exists(out_path):
        os.makedirs(out_path)
    cmd = config.dart_path
    cmd += " --disable-dart-dev "
    cmd += config.getFrontendServerDartSnapshot(isDebug)
    cmd += " --sdk-root "
    cmd += config.getFlutterPatchedSdkProduct(isDebug)
    cmd += " --target=flutter"
    cmd += " --packages "
    cmd += config.getPackagePath()
    cmd += " --no-print-incremental-dependencies "
    cmd += " --output-dill "
    if isDebug:
        cmd += config.dill_out_file
    else:
        cmd += config.release_dill_out_file
        cmd += " -Ddart.vm.profile=false "
        cmd += " -Ddart.vm.product=true "
        cmd += " --aot"
        cmd += " --tfa "
    cmd += " --verbose "
    cmd += config.getMainPath()
    result = excute(cmd)
    return result.find("Error: ") == -1


def copyFile(sourceFile, targetFile):
    if os.path.exists(targetFile):
        os.remove(targetFile)
    shutil.copy(sourceFile, targetFile)
    print("拷贝从{}到{}结束。".format(sourceFile, targetFile))


def copyFiles(sourceFiles, targetFiles):
    if os.path.exists(targetFiles):
        shutil.rmtree(targetFiles)
    shutil.copytree(sourceFiles, targetFiles)
    print("拷贝从{}到{}结束。".format(sourceFiles, targetFiles))


# 用flutter指令创建一个helloWorld工程，然后把.dart_tools拷贝到当前目录
def mkDartTool():
    if os.path.exists(config.dart_tool_path):
        print(config.dart_tool_path+"已存在，无需生成。")
        return
    if not os.path.exists(config.cache_dir):
        os.mkdir(config.cache_dir)
    if not os.path.exists(config.cache_project_dart_tool):
        cmd = "../flutter/bin/flutter"
        cmd += " create "+config.cache_project_name
        excute(cmd, config.cache_dir)  # 这个执行目录，是在cachedir
    copyFiles(config.cache_project_dart_tool, config.dart_tool_path)
    # 拷贝完后，删除缓存
    shutil.rmtree(config.cache_project_path)

# 获取flutter程序的绝对路径，请确保在app_build目录下执行
def getAbsoluteFlutterPath():
    app_build_path = excute("pwd")
    return app_build_path.replace("app_build", "bin/flutter")


# 可以在目标项目，创建.dart_tool和flutter_asset文件
def buildBundle():
    cmd = getAbsoluteFlutterPath()
    cmd += " build bundle"
    # 在项目目录中，执行flutter build bundle
    excute(cmd, config.project_root)


def copyFlutterAssets():
    copyFiles(config.getFlutterAssetsPath(), config.flutter_assets_target_path)


def buildDill(isDebug=True):
    # 检查环境和产物
    if not checkEnv(isDebug):
        return False
    # 任务开始
    flutterInit()
    # 执行flutter build bundle，创造.dart_tools和flutter_assets
    buildBundle()
    # 拷贝资源
    copyFlutterAssets()
    # 构建指令
    return build(isDebug)
