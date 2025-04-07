# Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE_KHZG file.

#!/usr/bin/python
import os
# import excute_util


def setEnv(key, value):
    os.environ[key] = value
    print("修改环境变量{}值为{}".format(key, value))


def getEnv(key):
    return os.environ.get(key)


# setEnv("PUB_HOSTED_URL", "123")
# print(getEnv("PUB_HOSTED_URL"))
# excute_util.excute("echo $PUB_HOSTED_URL")
