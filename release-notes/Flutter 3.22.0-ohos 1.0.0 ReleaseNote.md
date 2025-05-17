## 版本概述
本版本为基于Flutter 3.22.0适配的OpenHarmony版本。本版本支持和完善OpenHarmony平台侧能力，提升稳定性。

## 发布范围
OpenHarmony API16

## 新增特性
- ohos拉起键盘的方法新增参数,传入设备类型
- 使能hwasan内存检查
- Impeller简单遮挡剔除
- Impeller脏区渲染能力支持

## BugFix
- 修复napi和FlutterManager内存泄露问题
- 修复主动收起软键盘，应用失焦后获焦仍会接续软键盘的问题
- 修复同一个engineGroup的多engine场景下，只有一个engine能够正常切换字体问题
- 修复在新机或者恢复出厂设置后的机器上首次切换字体失效问题

## 已知问题
- Impeller简单遮挡剔除功能在某些场景下会导致纯色layer渲染问题
- 外接纹理第一帧自定义背景颜色接口setTextureBackGroundColor参数格式当前为ARGB，应该为ABGR

## 版本发布时间
2025年4月28日

## 版本配套
- ROM: 5.0.0.150
- IDE: DevEco Studio 5.0.11.100
- Flutter SDK: 3.22.0-ohos-1.0.0

## Changelog
- [5.1.0.403](/CHANGELOG.md)

## 赋能文档
- [文档链接](https://gitcode.com/openharmony-sig/flutter_samples/tree/master/ohos/docs)