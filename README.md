Flutter SDK 仓库
==============

原始仓来源：https://github.com/flutter/flutter

## 仓库说明
本仓库是基于Flutter SDK对于OpenHarmony平台的兼容拓展，可支持IDE或者终端使用Flutter Tools指令编译和构建OpenHarmony应用程序。

## 环境依赖

* 开发系统

  Flutter Tools指令目前已支持在Linux、Mac和Windows下使用。

* 环境配置
   **请优先从[鸿蒙套件列表](https://developer.harmonyos.com/deveco-developer-suite/enabling/kit?currentPage=1&pageSize=100)下载配套开发工具，暂不支持非该渠道下载的套件**
   *下列环境变量配置，类Unix系统（Linux、Mac），下可直接参照配置，Windows下环境变量配置请在‘编辑系统环境变量’中设置*

  1. 配置HarmonyOS SDK和环境变量
   * API12, deveco-studio-5.0.3.300 或 command-line-tools-5.0.3.300
   * 配置 Java17
   * 配置环境变量 (SDK, node, ohpm, hvigor)

      ```sh
      export TOOL_HOME=/Applications/DevEco-Studio-5.0.3.300.app/Contents # mac环境
      export DEVECO_SDK_HOME=$TOOL_HOME/sdk # command-line-tools/sdk
      export PATH=$TOOL_HOME/tools/ohpm/bin:$PATH # command-line-tools/ohpm/bin
      export PATH=$TOOL_HOME/tools/hvigor/bin:$PATH # command-line-tools/hvigor/bin
      export PATH=$TOOL_HOME/tools/node/bin:$PATH # command-line-tools/tool/node/bin
      ```

  2. 通过代码工具下载当前仓库代码`git clone https://gitee.com/openharmony-sig/flutter_flutter.git`，指定dev或master分支，并配置环境

     ```sh
     export PATH=<flutter_flutter path>/bin:$PATH
     export PUB_HOSTED_URL=https://pub.flutter-io.cn
     export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
     ```

   3. 应用构建依赖flutter engine构建产物与engine host，均在 `src/out` 路径下。不同构建类型的产物分别在 `ohos_debug_unopt_arm64`、 `ohos_release_arm64` 和 `ohos_profile_arm64` 目录下。engine host 的构建类型也有三种，分别在 `host_debug_unopt` 、`host_release` 与 `host_profile` 目录中。构建需要根据不同的构建类型来指定不同的目录。

      ```sh
      # 国内镜像
      export PUB_HOSTED_URL=https://pub.flutter-io.cn
      export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

      # 拉取下来的flutter_flutter/bin目录
      export PATH=/home/<user>/ohos/flutter_flutter/bin:$PATH

      # HamonyOS SDK
      export TOOL_HOME=/Applications/DevEco-Studio-5.0.3.300.app/Contents # mac环境
      export DEVECO_SDK_HOME=$TOOL_HOME/sdk # command-line-tools/sdk
      export PATH=$TOOL_HOME/tools/ohpm/bin:$PATH # command-line-tools/ohpm/bin
      export PATH=$TOOL_HOME/tools/hvigor/bin:$PATH # command-line-tools/hvigor/bin
      export PATH=$TOOL_HOME/tools/node/bin:$PATH # command-line-tools/tool/node/bin
      ```
   4. Flutter 默认使用自己sdk中的har包，不会使用flutter engine中的har包，如果需要使用flutter engine的har包，需要手工将flutter engine中的 `src/out/ohos_<build_type>_arm64/har/flutter.har` 复制到flutter sdk路径下的 `packages/flutter_tools/templates/app_shared/ohos.tmpl/har/har_product.tmpl/` 并加上构建类型与HarmonyOS SDK版本的后缀，如 `flutter.har.release.12`。

## 构建步骤

1. 运行 `flutter doctor -v` 检查环境变量配置是否正确，**Futter**与**OpenHarmony**应都为ok标识，若两处提示缺少环境，按提示补上相应环境即可。

2. 创建工程与编译命令，编译产物在\<projectName\>/ohos/entry/build/default/outputs/default/entry-default-signed.hap下。

   ```
   # 创建工程
   flutter create --platforms ohos <projectName>

   # 进入工程根目录编译
   # 示例：flutter build hap [--target-platform ohos-arm64] [--local-engine=<DIR>/src/out/ohos_release_arm64] --release
   flutter build hap --target-platform ohos-arm64 --<debug|release|profile> [--local-engine=src/out/<engine产物目录> --local-engine-host=src/out/<engine host目录>/]
   ```
   2.1 创建工程并打开impeller开关
   当前Flutter ohos平台中支持impeller-vulkan渲染模式，可通过开关控制是否打开。
   开关位于`buildinfo.json5`文件中，如果选择关闭impeller渲染，可将json文件中的value改为false。下一次运行时即可关闭。
   文件路径：`ohos/entry/src/main/resources/rawfile/buildinfo.json5`
   文件内容：
   ```json
   {
      "string": [
         {
            "name": "enable_impeller",
            "value": "true"
         }
      ]
   }
   ```
   新建工程默认打开impeller选项。
   对于旧工程，可将以上buildinfo.json5文件复制到工程目录的对应路径下，并修改value值即可实现开关功能。如果不添加开关，则默认打开enable-impeller。

3. 通过`flutter devices`指令发现ohos设备之后，使用 `hdc -t <deviceId> install <hap file path>`进行安装。

4. 也可直接使用下列指令运行：
```
   # 示例：flutter run --local-engine=<DIR>/src/out/ohos_debug_unopt_arm64 -d <device-id>
   flutter run --debug [--local-engine=/home/user/engine_make/src/out/ohos_debug_unopt_arm64 -d <device-id> --local-engine-host=src/out/<engine host目录>/]
```

5. 构建app包命令：
```
   # 示例：flutter build app --release [--local-engine=<DIR>/src/out/ohos_release_arm64]  local-engine为可选项
   flutter build app --release
```


## 已兼容OpenHarmony开发的指令列表
| 指令名称 | 指令描述 | 使用说明                                                              |
| ------- | ------- |-------------------------------------------------------------------|
| doctor | 环境检测 | flutter doctor                                                    |
| config | 环境配置 | flutter config --\<key\> \<value\>                                |
| create | 创建新项目 | flutter create --platforms ohos,android,ios --org \<org\> \<appName\> |
| create | 创建module模板 | flutter create -t module \<module_name\> |
| create | 创建plugin模板 | flutter create -t plugin --platforms ohos,android,ios \<plugin_name\> |
| create | 创建plugin_ffi模板 | flutter create -t plugin_ffi --platforms ohos,android,ios \<plugin_name\> |
| devices | 已连接设备查找 | flutter devices                                                   |
| install | 应用安装 | flutter install -t \<deviceId\> \<hap文件路径\>                                                   |
| assemble | 资源打包 | flutter assemble                                                  |
| build  | 测试应用构建 | flutter build hap --debug [--target-platform ohos-arm64] [--local-engine=\<兼容ohos的debug engine产物路径\>]       |
| build  | 正式应用构建 | flutter build hap --release [--target-platform ohos-arm64] [--local-engine=\<兼容ohos的release engine产物路径\>]   |
| run    | 应用运行 | flutter run [--local-engine=\<兼容ohos的engine产物路径\>]                |
| attach | 调试模式 | flutter attach                                                    |
| screenshot | 截屏 | flutter screenshot                                                 |

附：[Flutter三方库适配计划](https://docs.qq.com/sheet/DVVJDWWt1V09zUFN2)


## 常见问题

1. 切换FLUTTER_STORAGE_BASE_URL后需删除\<flutter\>/bin/cache 目录，并在项目中执行flutter clean后再运行

2. 若出现报错：`The SDK license agreement is not accepted`，参考执行以下命令后再次编译：

   ```
   ./ohsdkmgr install ets:9 js:9 native:9 previewer:9 toolchains:9 --sdk-directory='/home/xc/code/sdk/ohos-sdk/' --accept-license
   ```

3. 如果你使用的是DevEco Studio的Beta版本，编译工程时遇到“must have required property 'compatibleSdkVersion', location: demo/ohos/build-profile.json5:17:11"错误，请参考《DevEco Studio环境配置指导.docx》中的‘6 创建工程和运行Hello World’【配置插件】章节修改 hvigor/hvigor-config.json5文件。

4. 若提示安装报错：`fail to verify pkcs7 file` 请执行指令

   ```
   hdc shell param set persist.bms.ohCert.verify true
   ```
5. linux虚拟机通过hdc无法直接发现OpenHarmony设备

   解决方案：在windows宿主机中，开启hdc server，具体指令如下：
   ```
   hdc kill
   hdc -s serverIP:8710 -m
   ```
   在linux中配置环境变量：
   ```
   HDC_SERVER=<serverIP>
   HDC_SERVER_PORT=8710
   ```

   配置完成后flutter sdk可以通过hdc server完成设备连接，也可参考[官方指导](https://docs.openharmony.cn/pages/v4.0/zh-cn/device-dev/subsystems/subsys-toolchain-hdc-guide.md/#hdc-client%E5%A6%82%E4%BD%95%E8%BF%9C%E7%A8%8B%E8%AE%BF%E9%97%AEhdc-server)。

6. 构建Hap任务时报错：Error: The hvigor depends on the npmrc file. Configure the npmrc file first.


   请在用户目录`~`下创建文件`.npmrc`，该配置也可参考[DevEco Studio官方文档](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/environment_config-0000001052902427-V3)，编辑内容如下：

   ```
   registry=https://repo.huaweicloud.com/repository/npm/
   @ohos:registry=https://repo.harmonyos.com/npm/
   ```

7. 查日志时，存在日志丢失现象。
    解决方案：关闭全局日志，只打开自己领域的日志

    ```
    步骤一：关闭所有领域的日志打印（部分特殊日志无法关闭）
    hdc shell hilog -b X
    步骤二：只打开自己领域的日志
    hdc shell hilog <level> -D <domain>
    其中<level>为日志打印的级别：D/I/W/E/F,<domain>为Tag前面的数字
    举例：
    打印A00000/XComFlutterOHOS_Native的日志，需要设置hdc shell hilog -b D -D A00000
    注：上面的设置在机器重启后会失效，如果要继续使用，需要重新设置。
    ```
8. 若Api11 Beta1版本的机器上无法启动debug签名的应用，可以通过将签名换成正式签名，或在手机端打开开发者模式解决（步骤：设置->通用->开发者模式）

9. 如果报`Invalid CEN header (invalid zip64 extra data field size)`异常，请更换Jdk版本，参见[JDK-8313765](https://bugs.openjdk.org/browse/JDK-8313765)

10. 运行debug版本的flutter应用用到鸿蒙设备后报错（release和profile版本正常）
    1. 报错信息: `Error while initializing the Dart VM: Wrong full snapshot version, expected '8af474944053df1f0a3be6e6165fa7cf' found 'adb4292f3ec25074ca70abcd2d5c7251'`
    2. 解决方案: 依次执行以下操作
        1. 设置环境变量 `export FLUTTER_STORAGE_BASE_URL=https://flutter-ohos.obs.cn-south-1.myhuaweicloud.com`
        2. 删除 <flutter>/bin/cache 目录下的缓存
        3. 执行 `flutter clean`，清除项目编译缓存
        4. 运行 `flutter run -d $DEVICE --debug`
    3. 补充信息: 运行android或ios出现类似错误，也可以尝试还原环境变量 FLUTTER_STORAGE_BASE_URL ，清除缓存后重新运行。

