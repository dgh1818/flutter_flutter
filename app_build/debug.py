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
import file_util
import config
import build_dill
import sys

# 拷贝和重命名产物
def copyOut():
    file_util.copyFile(config.dill_out_file, config.out_kernel_blob_bin)
    file_util.copyFile(config.getVmIsolateSnapshotBin(),
                       config.out_vm_snapshot_data)
    file_util.copyFile(config.getIsolateSnapshotBin(),
                       config.out_isolate_snapshot_data)


if not config.checkArgs():
    sys.exit(1)

if not build_dill.buildDill():
    print("编译失败！")
else:
    copyOut()
    print(config.debug_out_desc)
