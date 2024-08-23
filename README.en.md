Flutter SDK repository
==============

Original warehouse source: https://github.com/flutter/flutter

## Warehouse description
This repository is a compatible extension of Flutter SDK for the OpenHarmony platform, and can support IDE or terminal use of Flutter Tools instructions to compile and build OpenHarmony applications.

## Development document
[Docs](https://gitee.com/openharmony-sig/flutter_samples/tree/master/ohos/docs)

## Environment dependencies

* development system

   Flutter Tools commands are currently supported on Linux, Mac and Windows.

* Environment configuration

    **Please download the supporting development tool from [OpenHarmony SDK](https://developer.huawei.com/consumer/cn/develop)**
    *The following environment variable configuration is for Unix-like systems (Linux, Mac). You can directly refer to the configuration below. For environment variable configuration under Windows, please set it in ‘Edit System Environment Variables’*

   1. Configure the HarmonyOS SDK and environment variables
    * API12, deveco-studio-5.0 or command-line-tools-5.0
    * Configure Java17
    * Configure environment variables (SDK, node, ohpm, hvigor)

       ```sh
        export TOOL_HOME=/Applications/DevEco-Studio.app/Contents # For mac
        export DEVECO_SDK_HOME=$TOOL_HOME/sdk # command-line-tools/sdk
        export PATH=$TOOL_HOME/tools/ohpm/bin:$PATH # command-line-tools/ohpm/bin
        export PATH=$TOOL_HOME/tools/hvigor/bin:$PATH # command-line-tools/hvigor/bin
        export PATH=$TOOL_HOME/tools/node/bin:$PATH # command-line-tools/tool/node/bin
       ```

   2. Download the current warehouse code `git clone https://gitee.com/openharmony-sig/flutter_flutter.git` Specify the dev or master branch and configure the environment

      ```sh
       export PATH=<flutter_flutter path>/bin:$PATH
       export PUB_CACHE=D:/PUB
      # Domestic mirror
       export PUB_HOSTED_URL=https://pub.flutter-io.cn
       export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn
      ```

    3. becomes an optional parameter and may not be passed.
       - Usage example: `--local-engine=src/out/<engine产物目录\>`
       - You can download [compiled product](https://docs.qq.com/sheet/DUnljRVBYUWZKZEtF?tab=BB08J2) from this path.
       - The engine path points to the directory that needs to be accompanied by 'src/out'.

       For the configuration of all the above environment variables (for environment variable configuration under Windows, please set it in 'Edit System Environment Variables'), you can refer to the following example (please replace user and specific code path with the actual path):

       ```sh
        # Dependent cache
        export PUB_CACHE=D:/PUB(Custom path)

        # Domestic mirror
        export PUB_HOSTED_URL=https://pub.flutter-io.cn
        export FLUTTER_STORAGE_BASE_URL=https://storage.flutter-io.cn

        # The flutter_flutter directory pulled from Gitee
        export PATH=/home/<user>/ohos/flutter_flutter/bin:$PATH

        # HarmonyOS SDK
        export TOOL_HOME=/Applications/DevEco-Studio.app/Contents # For mac
        export DEVECO_SDK_HOME=$TOOL_HOME/sdk # command-line-tools/sdk
        export PATH=$TOOL_HOME/tools/ohpm/bin:$PATH # command-line-tools/ohpm/bin
        export PATH=$TOOL_HOME/tools/hvigor/bin:$PATH # command-line-tools/hvigor/bin
        export PATH=$TOOL_HOME/tools/node/bin:$PATH # command-line-tools/tool/node/bin
       ```
    4. Flutter uses `flutter.har` in its own sdk and will not use the one under flutter engine build. If the `flutter.har` in the engine build directory is needed, one needs to copy `src/out/ohos_<build_type>_arm64/har/flutter.har` to flutter sdk path `packages/flutter_tools/templates/app_shared/ohos.tmpl/har/har_product.tmpl/` and add build type with HarmonyOS sdk version suffix such as `flutter.har.release.12`.

## Build steps

1. Run `flutter doctor -v` to check whether the environment variable configuration is correct. **Futter** and **OpenHarmony** should both be ok. If the two prompts indicate that the environment is missing, just follow the prompts to fill in the corresponding environment.

2. Create the project and compile the command. The compiled product is under \<projectName\>/ohos/entry/build/default/outputs/default/entry-default-signed.hap.

    ```
     # Create project
     flutter create --platforms ohos <projectName>

     # Go to the project root directory for compilation
     # Example: flutter build hap [--target-platform ohos-arm64] [--local-engine=<DIR>/src/out/ohos_release_arm64] --release
     flutter build hap --release
    ```
    # Enter the project root directory to compile
    # Example: flutter build hap [--target-platform ohos-arm64] --local-engine=<DIR>/src/out/ohos_release_arm64 --release
    flutter build hap --target-platform ohos-arm64 --<debug|release|profile> --local-engine=<DIR>/src/out/<engine> --local-engine-host=src/out/<engine_host>/
    ```
    2.1 Create a Project and Enable the Impeller
    Currently, the Flutter OHOS platform supports the impeller-vulkan rendering mode, which can be controlled via a switch. The switch is located in the 'buildinfo.json5' file. If you choose to disable the Impeller rendering, you can change the value in the JSON file to false. The next time you run the project, the Impeller will be disabled.
    File path: `ohos/entry/src/main/resources/rawfile/buildinfo.json5`
    File content:
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
    By default, the Impeller option is enabled in new projects.
    For existing projects, you can copy the above buildinfo.json5 file to the corresponding directory in your project and modify the value to enable or disable the switch. If the switch does not exist, then will set enable-impeller by default.

3. After discovering the ohos device through the `flutter devices` command, use `hdc -t <deviceId> install <hap file path>` to install it.

4. You can also directly use the following command to run:
    ```
     # Example: flutter run [--local-engine=<DIR>/src/out/ohos_debug_unopt_arm64] -d <device-id>
     flutter run --debug -d <device-id>
    ```

5. Build app package command:
    ```
     # Example: flutter build app --release [--local-engine=<DIR>/src/out/ohos_release_arm64]  local-engine(is optional)
     flutter build app --release
    ```
    ```
    # Example: flutter run --local-engine=<DIR>/src/out/ohos_debug_unopt_arm64 -d <device-id>
    flutter run  --debug --local-engine=/home/user/engine_make/src/out/ohos_debug_unopt_arm64 -d <device-id> --local-engine-host=src/out/<engine_host>/
    ```


## Compatible command list developed by OpenHarmony

| Command name | Command description | Instructions for use                                                              |
| ------- | ------- |-------------------------------------------------------------------|
| doctor | environment detection | flutter doctor                                                    |
| config | environment configuration | flutter config --\<key\> \<value\>                                |
| create | Create a new project | flutter create --platforms ohos,android,ios --org \<org\> \<appName\> |
| create | Create module template | flutter create -t module \<module_name\> |
| create | Create plugin template | flutter create -t plugin --platforms ohos,android,ios \<plugin_name\> |
| create | Create plugin_ffi template | flutter create -t plugin_ffi --platforms ohos,android,ios \<plugin_name\> |
| devices | Connected device discovery | flutter devices                                                   |
| install | application installation | flutter install -t \<deviceId\> \<hap file path\>                                                   |
| assemble | resource packaging | flutter assemble                                                  |
| build | Test application build | flutter build hap --debug [--target-platform ohos-arm64] [--local-engine=\<debug engine product path compatible with ohos\>]         |
| build | Formal application build | flutter build hap --release [--target-platform ohos-arm64] [--local-engine=\<release engine product path compatible with ohos\>]         |
| run | application run | flutter run [--local-engine=\<engine product path compatible with ohos\>]                  |
| attach | debug mode | flutter attach                                                    |
| screenshot | screenshot | flutter screenshot                                                 |

Attachment: [Flutter third-party library adaptation plan](https://docs.qq.com/sheet/DVVJDWWt1V09zUFN2)

## Common Problem

1. After switching to FLUTTER_STORAGE_BASE_URL, you need to delete the \<flutter\>/bin/cache directory and execute Flutter clean in the project before running it again.

2. If an error message appears: `The SDK license agreement is not accepted`, please execute the following command and compile again:

    ```
     ./ohsdkmgr install ets:9 js:9 native:9 previewer:9 toolchains:9 --sdk-directory='/home/xc/code/sdk/ohos-sdk/' --accept-license
    ```

3. If you are using the Beta version of DevEco Studio and encounter the error "must have required property 'compatibleSdkVersion', location: demo/ohos/build-profile.json5:17:11" when compiling the project, Modify the hvigor/hvigor-config.json5 file by referring to section ‘6 Create the project and run Hello World’ [Configuration Plug-in] in《DevEco Studio Environment configuration guide.docx》.

4. If you are prompted with an installation error: `fail to verify pkcs7 file`, please execute the command

    ```
     hdc shell param set persist.bms.ohCert.verify true
    ```
5. Linux virtual machine cannot directly discover OpenHarmony devices through hdc

    Solution: In the Windows host, open the hdc server. The specific instructions are as follows:
    ```
     hdc kill
     hdc -s serverIP:8710 -m
    ```
     Configure environment variables in linux:
    ```
     HDC_SERVER=<serverIP>
     HDC_SERVER_PORT=8710
    ```

    After the configuration is completed, the flutter sdk can complete the device connection through the hdc server. You can also refer to [official guidance](https://docs.openharmony.cn/pages/v4.0/zh-cn/device-dev/subsystems/subsys-toolchain -hdc-guide.md/#hdc-client%E5%A6%82%E4%BD%95%E8%BF%9C%E7%A8%8B%E8%AE%BF%E9%97%AEhdc-server) .

6. An error occurred when building the Hap task: Error: The hvigor depends on the npmrc file. Configure the npmrc file first.


    Please create the file `.npmrc` in the user directory `~`. For this configuration, please refer to [DevEco Studio official documentation](https://developer.harmonyos.com/cn/docs/documentation/doc-guides-V3/environment_config -0000001052902427-V3), the edited content is as follows:

    ```
     registry=https://repo.huaweicloud.com/repository/npm/
     @ohos:registry=https://repo.harmonyos.com/npm/
    ```
7. Symptom Logs are lost during log query。
    Solution：Disable global logs and enable only logs in your domain

    ```
     Step one：Disable log printing for all fields（Some special logs cannot be closed）
     hdc shell hilog -b X
     Step two：Open logs for your domain only
     hdc shell hilog <level> -D <domain>
     <level> indicates the level of log printing：D/I/W/E/F,<domain>is the number before the Tag
     Example:
     To print logs about 'A00000/XComFlutterOHOS_Native', set 'hdc shell hilog -b D -D A00000'
     annotation:The above Settings will be invalid after the machine is restarted, and you need to reset them if you want to continue using them
    ```
8. If the debug signature application cannot be started on API 11BETA1, it can be resolved by changing the signature to an official signature or opening the developer mode on the mobile terminal (steps: Settings -> General -> Developer mode).

9. If `Invalid CEN header (invalid zip64 extra data field size)` is abnormal, please replace the JDK version, see [JDK-8313765]

10. An error occurs when running a debug version of the Flutter application on a HarmonyOS device (release and profile versions are normal)
    1. Error message: `Error while initializing the Dart VM: Wrong full snapshot version, expected '8af474944053df1f0a3be6e6165fa7cf' found 'adb4292f3ec25074ca70abcd2d5c7251'`
    2. Solution: Perform the following actions in sequence
        1. Set environment variables `export FLUTTER_STORAGE_BASE_URL=https://flutter-ohos.obs.cn-south-1.myhuaweicloud.com`
        1. Delete the cache in the<Flutter>/bin/cache directory
        2. Execute `fluent clean` to clear the project compilation cache
        3. Execute `flutter run -d $DEVICE --debug`
    3. Additional information: If a similar error occurs while running Android or iOS, you can also try restoring the environment variable FLUTTER_STORAGE_BASE_URL , clearing the cache, and then running again.

11. After the ROM update of Beta 2 version, it no longer supports requesting anonymous memory with execution permission, resulting in debug crashing.
    1. Solution: Update flutter_flutter to a version after a44b8a6d (2024-07-25).
    2. Key logs:

   ```
    #20 at attachToNative (oh_modules/.ohpm/@ohos+flutter_ohos@g8zhdaqwu8gotysbmqcstpfpcpy=/oh_modules/@ohos/flutter_ohos/src/main/ets/embedding/engine/FlutterNapi.ets:78:32)
    #21 at attachToNapi (oh_modules/.ohpm/@ohos+flutter_ohos@g8zhdaqwu8gotysbmqcstpfpcpy=/oh_modules/@ohos/flutter_ohos/src/main/ets/embedding/engine/FlutterEngine.ets:144:5)
    #22 at init (oh_modules/.ohpm/@ohos+flutter_ohos@g8zhdaqwu8gotysbmqcstpfpcpy=/oh_modules/@ohos/flutter_ohos/src/main/ets/embedding/engine/FlutterEngine.ets:133:7)
   ```

12. Build Hap command directly execute `flutter build hap`, no longer need `--local-engine` parameter, directly from the cloud to obtain the compilation product

13. After the environment is configured, the system crashes when the flutter command is executed。
    1. Solution：Add git environment variable configuration in windows environment。
    ```
     export PATH=<git path>/cmd:$PATH
    ```

14. If `flutter pub cache clean` is executed normally, `flutter clean` will report an error. If update command is executed according to the error message, it has no effect。
    1. Solution：To avoid this problem, comment out the configuration in the build.json5 file。
    2. Error message:
    ```
     #Parse ohos module. json5 error: Exception: Can not found module.json5 at
     #D:\pub_cache\git\flutter_packages-b00939bb44d018f0710d1b080d91dcf4c34ed06\packages\video_player\video_player_ohos\ohossrc\main\module.json5.
     #You need to update the Flutter plugin project structure.
     #See
     #https://gitee.com/openharmony-sig/flutter_samples/tree/master/ohos/docs/09_specifications/update_flutter_plugin_structure.md
    ```

15. An error message indicating path verification occurs when `flutter build hap` is executed。
    1. Solution：
      · Open the ohos-project-build-profile-schema.json file in deveco installation path D:\DevEco Studio\tools\hvigor\hvigor-ohos-plugin\res\schemas。
      · Find the line containing: "pattern": "^(\\./|\\.\\./)[\\s\\S]+$" in the file and delete it。
    2. Error message:
    ```
     #hvigor  ERROR: Schema validate failed.
     #        Detail: Please check the following fields.
     #instancePath: 'modules[1].scrPath',
     #keyword: 'pattern'
     #params: { pattern:'^(\\./|\\.\\./)[\\s\\S]+$' },
     #message: 'must match pattern "^(\\./|\\.\\./)[\\s\\S]+$"',
     #location: 'D:/work/videoplayerdemo/video_cannot_stop_at_background/ohos/build-profile.json:42:146'
    ```

16. Execute `flutter build hap` report an error。
    1. Solution：Open the core-module-model-impl.js file in deveco installation path D:\DevEco Studio\tools\hvigor\hvigor-ohos-plugin\src\model\module。,
       Modify the findBelongProjectPath method (requires administrator rights, can be saved as and replaced)
       ```
        findBelongProjectPath(e) {
          if (e === path_1.default.dirname(e)) {
             return this.parentProject.getProjectDir()
          }
        }
       ```
    2. Error message:
      ```
       # hvigor  ERROR: Cannot find belonging project path for module at D:\.
       # hvigor  ERROR:  BUILD FAILED in 2s 556ms.
       #Running Hvigor task assembleHap...
       #Oops; flutter has exited unexpectedly: "ProcessException: The command failed
       #  <Command: hvigorw --mode module -p module=video_player_ohos@default -p product=default assmbleHar --no-daemon"
       #A crash report has been written to D:\work\videoplayerdemo\video_cannot_stop_at_background\flutter_03.log.
      ```

13. DevEco-Studio(5.0.3.600 Beta3)，windows版本编译flutter应用报错
    1. Solution: Update flutter_flutter to a version after c6fbac2b (2024-08-09).
    2. Key logs:

   ```
   hvigor ERROR: Schema validate failed.
      Detail: Please check the following fields.
      {
         instancePath: 'modules[2].srcPath',
         keyword: 'pattern',
         params: { pattern: '^(\\./|\\.\\./)[\\s\\S]+$' },
         message: 'must match pattern "^(\\./|\\.\\./)[\\s\\S]+$"',
      }
   ```

[More FAQ](https://gitee.com/openharmony-sig/flutter_samples/blob/master/ohos/docs/08_FAQ/README.md)
