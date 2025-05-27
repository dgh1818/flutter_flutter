## Version Overview
This version is the Flutter OpenHarmony platform version 0.1.0 (Beta), based on the Flutter 3.22.0. This version supports and improves the capabilities of the OpenHarmony platform, provides platform-based channels, external texture, cloud SDKs and other features, and optimizes performance.

## Release Scope
HarmonyOS NEXT, API13

## Basic Features
- Support OpenHarmony platform Flutter Channel
- Support OpenHarmony platform Flutter Engine
- Support OpenHarmony platform Flutter Command line tool
- Support OpenHarmony platform External Texture
- Support OpenHarmony platform SDK
- Official library & Third-party library OpenHarmony platform adaptation

## New Features
- Support for the Impeller rendering engine, enabled by default
- Support for engine preloading and pre-rendering
- Support for importing self-rendered content into Flutter

## Release Date
December 31, 2024

## Version Compatibility
- ROM: 5.0.0.115
- IDE: DevEco Studio 5.0.5.310
- SDK: HarmonyOS SDK 5.0.5.310, API13
- Flutter SDK: 3.22.0-ohos-0.1.0 (Due to Flutter version parsing rules, to avoid version comparison failures, it will display as 3.22.1-ohos-0.1.0)

## Enabling Documentation

- [Documentation Link](https://gitcode.com/openharmony-sig/flutter_samples/tree/master/ohos/docs)

## Third-Party Library List

The 3.22 version shares the same set of third-party library repositories as the 3.7 version. Some dependencies have been updated to the 3.22 version, and the corresponding new branches can be found in the repositories.

- Official Library:

    [Official Library Link](https://gitcode.com/openharmony-sig/flutter_packages)

- Third-Party Libraries:

    | Library Name | Repository Link |
    |:-------------|:----------------|
    | sqflite | https://gitcode.com/openharmony-sig/flutter_sqflite |
    | permission_handler | https://gitcode.com/openharmony-sig/flutter_permission_handler |
    | fluttertoast | https://gitcode.com/openharmony-sig/flutter_fluttertoast |
    | connectivity_plus | https://gitcode.com/openharmony-sig/flutter_plus_plugins |
    | device_info_plus | https://gitcode.com/openharmony-sig/flutter_plus_plugins |
    | package_info_plus | https://gitcode.com/openharmony-sig/flutter_plus_plugins |
    | connectivity | https://gitcode.com/openharmony-sig/flutter_plus_plugins |
    | package_info | https://gitcode.com/openharmony-sig/flutter_plus_plugins |
    | audio_session | https://gitcode.com/openharmony-sig/flutter_audio_session/ |
    | flutter_native_image | https://gitcode.com/openharmony-sig/flutter_native_image |
    | flutter_sound | https://gitcode.com/openharmony-sig/flutter_sound |
    | image_gallery_saver | https://gitcode.com/openharmony-sig/flutter_image_gallery_saver |
    | location | https://gitcode.com/openharmony-sig/flutter_location |
    | power_image | https://gitcode.com/openharmony-sig/flutter_power_image |
    | share_plus | https://gitcode.com/openharmony-sig/flutter_plus_plugins |
    | wakelock | https://gitcode.com/openharmony-sig/flutter_wakelock |
    | flutter_console | https://gitcode.com/openharmony-sig/flutter_console |
    | audioplayers | https://gitcode.com/openharmony-sig/flutter_audioplayers |
    | gpu_image | https://gitcode.com/openharmony-sig/flutter_gpu_image |
    | image_crop | https://gitcode.com/openharmony-sig/flutter_image_crop |
    | bitmap | https://gitcode.com/openharmony-sig/flutter_bitmap |
    | leak_detector | https://gitcode.com/openharmony-sig/flutter_leak_detector |
    | flutter_math_fork | https://gitcode.com/openharmony-sig/flutter_math_fork |
    | flutter_contacts | https://gitcode.com/openharmony-sig/flutter_contacts |
    | flutter_inappwebview | https://gitcode.com/openharmony-sig/flutter_inappwebview |
    | flutter_keyboard_visibility | https://gitcode.com/openharmony-sig/flutter_keyboard_visibility |
    | flutter_widget_from_html | https://gitcode.com/openharmony-sig/flutter_widget_from_html |
    | mobile_scanner | https://gitcode.com/openharmony-sig/fluttertpc_mobile_scanner |
    | device_util | https://gitcode.com/openharmony-sig/fluttertpc_device_util |
    | export_video_frame | https://gitcode.com/openharmony-sig/fluttertpc_export_video_frame |
    | flutter_local_notifications | https://gitcode.com/openharmony-sig/fluttertpc_flutter_local_notifications |
    | flutter_phone_direct_caller | https://gitcode.com/openharmony-sig/fluttertpc_flutter_phone_direct_caller |
    | flutter_screenshot_callback | https://gitcode.com/openharmony-sig/fluttertpc_screenshot_callback |
    | flutter_sms | https://gitcode.com/openharmony-sig/fluttertpc_flutter_sms |
    | media_info | https://gitcode.com/openharmony-sig/fluttertpc_media_info |
    | orientation | https://gitcode.com/openharmony-sig/fluttertpc_orientation |
    | recognition_qrcode | https://gitcode.com/openharmony-sig/fluttertpc_recognition_qrcode |
    | video_compress | https://gitcode.com/openharmony-sig/fluttertpc_video_compress |
    | share_extend | https://gitcode.com/openharmony-sig/fluttertpc_share_extend |
    | catcher | https://gitcode.com/openharmony-sig/fluttertpc_catcher |
    | flutter_mailer | https://gitcode.com/openharmony-sig/fluttertpc_flutter_mailer |
    | gallery_saver | https://gitcode.com/openharmony-sig/fluttertpc_gallery_saver |
    | flutter_localization | https://gitcode.com/openharmony-sig/flutter_localization |
    | keyboard_actions | https://gitcode.com/openharmony-sig/fluttertpc_keyboard_actions |
    | native_device_orientation | https://gitcode.com/openharmony-sig/fluttertpc_native_device_orientation |
    | screen | https://gitcode.com/openharmony-sig/fluttertpc_screen |
    | pdf_render | https://gitcode.com/openharmony-sig/fluttertpc_pdf_render |

## Known Issues
- MacOS applications compiled with the HarmonyOS version of the SDK may crash when running the Release version on MacOS.