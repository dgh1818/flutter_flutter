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
