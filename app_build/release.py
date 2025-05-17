# Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE_KHZG file.

#!/usr/bin/python
import config
import build_dill
import excute_util
import sys

def buildAot():
    cmd = config.gen_snapshot
    cmd += " --deterministic "
    cmd += " --snapshot_kind=app-aot-elf "
    cmd += " --elf={}libapp.so".format(config.release_out_path)
    cmd += " --strip "
    cmd += config.release_dill_out_file
    excute_util.excute(cmd)



if not config.checkArgs():
    sys.exit(1)

if not build_dill.buildDill(False):
    print("编译失败！")
else:
    buildAot()
    print(config.release_out_desc)
