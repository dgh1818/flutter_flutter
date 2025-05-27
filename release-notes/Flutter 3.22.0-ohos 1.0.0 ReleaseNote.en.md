## Version Overview
This version is an OpenHarmony version based on Flutter 3.22.0. This version supports and improves the capabilities of the OpenHarmony platform and improves stability.

## Release Scope
OpenHarmony API16

## New Features
- Add a parameter to the method of ohos pulling up the keyboard and pass in the device type
- Enable hwasan memory checking
- Impeller simple occlusion culling
- Impeller dirty area rendering capability support

## BugFix
- Fixed the memory leak issue of napi and FlutterManager
- Fixed the issue that if the soft keyboard was actively stowed away, the focus would still continue after the application was out of focus
- Fixed the issue that only one engine could switch fonts in the multi-engine scenario of the same enginegroup
- Fixed the issue that switching fonts for the first time on a new or factory reset machine would not work

## Known issues
- Impeller's simple occlusion culling feature can cause solid color layer rendering issues in some scenes
- The function of the setTextureBackGroundColor interface is to set the custom background color of the first frame of the external texture, and its parameter format should be ABGR, which is currently ARGB

## Version Release Time
April 28, 2025

## Version Support
- ROM: 5.0.0.150
- IDE: DevEco Studio 5.0.11.100
- Flutter SDK: 3.22.0-ohos-1.0.0

## Changelog
- [5.1.0.403](/CHANGELOG.md)

## Enablement Documents
- [Document Link](https://gitcode.com/openharmony-sig/flutter_samples/tree/master/ohos/docs)
