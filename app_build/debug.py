# Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE_KHZG file.

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
