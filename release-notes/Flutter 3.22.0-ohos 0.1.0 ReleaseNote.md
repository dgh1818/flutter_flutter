## 版本概述
本版本为Flutter OpenHarmony平台0.1.0版本（Beta），基于Flutter 3.22.0版本适配。本版本支持和完善OpenHarmony平台侧能力，提供平台化Channel、外接纹理、云端SDK等特性，并优化性能。

## 发布范围
HarmonyOS NEXT, API13

## 基础特性
- 支持OpenHarmony平台Flutter Channel
- 支持OpenHarmony平台Flutter Engine
- 支持OpenHarmony平台Flutter命令行工具
- 支持外接纹理
- 支持云端SDK
- 官方库&三方库OpenHarmony平台适配

## 新增特性
- 支持impeller渲染引擎并默认使能
- 支持引擎预加载预渲染
- 支持自渲染内容导入Flutter

## 版本发布时间
2024年12月31日

## 版本配套
- ROM: 5.0.0.115
- IDE: DevEco Studio 5.0.5.310
- SDK: HarmonyOS SDK 5.0.5.310，API13
- Flutter SDK: 3.22.0-ohos-0.1.0（由于flutter版本解析规则，为了避免版本比较解析失败，将显示为3.22.1-ohos-0.1.0）

## 赋能文档

- [文档链接](https://gitcode.com/openharmony-sig/flutter_samples/tree/master/ohos/docs)

## 三方库列表

3.22版本与3.7版本共用同一套三方库代码仓，部分三方库依赖已更新3.22版本的，可以在代码仓中找到对应的新分支

- 官方库/三方库：

    [官方库链接](https://gitcode.com/openharmony-sig/flutter_packages)

- 三方库：

    |三方库名称|仓库地址|
    |:----|:----|
    |sqflite|https://gitcode.com/openharmony-sig/flutter_sqflite|
    |permission_handler|https://gitcode.com/openharmony-sig/flutter_permission_handler|
    |fluttertoast|https://gitcode.com/openharmony-sig/flutter_fluttertoast|
    |connectivity_plus|https://gitcode.com/openharmony-sig/flutter_plus_plugins|
    |device_info_plus|https://gitcode.com/openharmony-sig/flutter_plus_plugins|
    |package_info_plus|https://gitcode.com/openharmony-sig/flutter_plus_plugins|
    |connectivity|https://gitcode.com/openharmony-sig/flutter_plus_plugins|
    |package_info|https://gitcode.com/openharmony-sig/flutter_plus_plugins|
    |audio_session|https://gitcode.com/openharmony-sig/flutter_audio_session/|
    |flutter_native_image|https://gitcode.com/openharmony-sig/flutter_native_image|
    |flutter_sound|https://gitcode.com/openharmony-sig/flutter_sound|
    |image_gallery_saver|https://gitcode.com/openharmony-sig/flutter_image_gallery_saver|
    |location|https://gitcode.com/openharmony-sig/flutter_location|
    |power_image|https://gitcode.com/openharmony-sig/flutter_power_image|
    |share_plus|https://gitcode.com/openharmony-sig/flutter_plus_plugins|
    |wakelock|https://gitcode.com/openharmony-sig/flutter_wakelock|
    |flutter_console|https://gitcode.com/openharmony-sig/flutter_console|
    |audioplayers|https://gitcode.com/openharmony-sig/flutter_audioplayers|
    |gpu_image|https://gitcode.com/openharmony-sig/flutter_gpu_image|
    |image_crop|https://gitcode.com/openharmony-sig/flutter_image_crop|
    |bitmap|https://gitcode.com/openharmony-sig/flutter_bitmap|
    |leak_detector|https://gitcode.com/openharmony-sig/flutter_leak_detector|
    |flutter_math_fork|https://gitcode.com/openharmony-sig/flutter_math_fork|
    |flutter_contacts|https://gitcode.com/openharmony-sig/flutter_contacts|
    |flutter_inappwebview|https://gitcode.com/openharmony-sig/flutter_inappwebview|
    |flutter_keyboard_visibility|https://gitcode.com/openharmony-sig/flutter_keyboard_visibility|
    |flutter_widget_from_html|https://gitcode.com/openharmony-sig/flutter_widget_from_html|
    |mobile_scanner|https://gitcode.com/openharmony-sig/fluttertpc_mobile_scanner|
    |device_util|https://gitcode.com/openharmony-sig/fluttertpc_device_util|
    |export_video_frame|https://gitcode.com/openharmony-sig/fluttertpc_export_video_frame|
    |flutter_local_notifications|https://gitcode.com/openharmony-sig/fluttertpc_flutter_local_notifications|
    |flutter_phone_direct_caller|https://gitcode.com/openharmony-sig/fluttertpc_flutter_phone_direct_caller|
    |flutter_screenshot_callback|https://gitcode.com/openharmony-sig/fluttertpc_screenshot_callback|
    |flutter_sms|https://gitcode.com/openharmony-sig/fluttertpc_flutter_sms|
    |media_info|https://gitcode.com/openharmony-sig/fluttertpc_media_info|
    |orientation|https://gitcode.com/openharmony-sig/fluttertpc_orientation|
    |recognition_qrcode|https://gitcode.com/openharmony-sig/fluttertpc_recognition_qrcode|
    |video_compress|https://gitcode.com/openharmony-sig/fluttertpc_video_compress|
    |share_extend|https://gitcode.com/openharmony-sig/fluttertpc_share_extend|
    |catcher|https://gitcode.com/openharmony-sig/fluttertpc_catcher|
    |flutter_mailer|https://gitcode.com/openharmony-sig/fluttertpc_flutter_mailer|
    |gallery_saver|https://gitcode.com/openharmony-sig/fluttertpc_gallery_saver|
    |flutter_localization|https://gitcode.com/openharmony-sig/flutter_localization|
    |keyboard_actions|https://gitcode.com/openharmony-sig/fluttertpc_keyboard_actions|
    |native_device_orientation|https://gitcode.com/openharmony-sig/fluttertpc_native_device_orientation|
    |screen|https://gitcode.com/openharmony-sig/fluttertpc_screen|
    |pdf_render|https://gitcode.com/openharmony-sig/fluttertpc_pdf_render|


## 已知问题
- Macos系统下使用鸿蒙版本SDK编译的Release版本的Macos应用存在闪退现象