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
