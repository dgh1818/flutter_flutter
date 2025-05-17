# Copyright (c) 2023 Hunan OpenValley Digital Industry Development Co., Ltd. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE_KHZG file.

import subprocess
from datetime import datetime

# 执行字符串命令行
def excute(cmdStr, path="."):
    if (path != "."):
        print("下个指令执行目录："+path)
    # 创建子进程
    proc = subprocess.Popen(cmdStr, cwd=path, shell=True,
                            stdout=subprocess.PIPE, text=True)
    return excuteProgress(cmdStr, proc)

# 执行数组命令
def excuteArr(cmdArr):
    # 创建子进程
    proc = subprocess.Popen(cmdArr, stdout=subprocess.PIPE, text=True)
    str = ' '.join(cmdArr)
    return excuteProgress(str, proc)


def getDateStr(date):
    hour = date.hour
    minute = date.minute
    second = date.second
    return "{}时{}分{}秒".format(hour, minute, second)


def excuteProgress(cmdStr, proc):
    start_time = datetime.now()
    print("开始执行命令：{} ，开始时间：{}".format(cmdStr, getDateStr(start_time)))
    result = ""
    # 逐行读取输出结果
    for line in proc.stdout:
        data = line.strip()
        print(data)
        result += data
    # 等待子进程结束
    proc.wait()
    end_time = datetime.now()
    print("执行命令结束：{} ，结束时间：{} ，任务耗时: {}".format(
        cmdStr, getDateStr(end_time), end_time - start_time))
    return result


# 测试代码
def testExcuteStr():
    cmdStr = "ls"
    excute(cmdStr, path="/")


def testExcuteArr():
    cmdArr = ["ping", "baidu.com"]
    excuteArr(cmdArr)

# testExcuteStr()
# testExcuteArr()
