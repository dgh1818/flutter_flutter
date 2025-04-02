# Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE_KHZG file.

#!/usr/bin/python
import shutil
import os


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
