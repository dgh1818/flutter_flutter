# Changelog

## 5.1.0.403
- 修复showModalBottomSheet动画失效 (3.7:[2c88beb6](https://gitcode.com/openharmony-sig/flutter_engine/commit/2c88beb69bf674f72c82cc7807e15acbe2fb5776?ref=fix-accessibility&prId=789))
- 处理napi和FlutterManager内存泄露 (3.7:[b4b203ad](https://gitcode.com/openharmony-sig/flutter_engine/commit/b4b203adf1ecc6365566086b5276263446b98f10?ref=memory_leak&prId=756), 3.22:[cfb5db39](https://gitcode.com/openharmony-sig/flutter_engine/commit/cfb5db397efe61624c33a26b549a90720938fcd0?ref=memory_leak_3.22&prId=771))
- 在flutternapi的析构函数中执行napi_reference_unref，取消在nativeDestroy中的napi_delete_reference,避免destroy后又调用napi方法导致的crash (3.7:[4497b0f2](https://gitcode.com/openharmony-sig/flutter_engine/commit/4497b0f225e8b1bbc547b02a933ebb8db2deb4cd?ref=napi_delete_ref&prId=779), 3.22:[4b93ec64](https://gitcode.com/openharmony-sig/flutter_engine/commit/4b93ec64841de11b473f39046604a65f9a2d8035?ref=napi_delete_ref_3.22&prId=780))
- 修复FlutterView中display回调函数使用错误，避免内存泄露 (3.7:[10b86945](https://gitcode.com/openharmony-sig/flutter_engine/commit/10b869450bea782f9ccc15cf7d1a145066e7aed9?ref=memory_leak&prId=756))
- 修复主动收起软键盘，应用失焦后获焦仍会接续软键盘的问题 (3.7:[fd53890c](https://gitcode.com/openharmony-sig/flutter_engine/commit/fd53890c0b4478bd1ccdb7132d41dd67df11f57f?ref=dev), 3.22:[c9dca75d](https://gitcode.com/openharmony-sig/flutter_engine/commit/c9dca75d571c657bd4fc675b187ecbc683a76dfe?ref=oh-3.22.0&prId=766))
- 支持输入法输入成对符号时，光标自动调整到成对符号中间（3.7:[1bf1640f](https://gitcode.com/openharmony-sig/flutter_engine/commit/1bf1640f7765ebb17b410f6f1a14afeae64774a4?ref=dev&prId=778)）
- ohos拉起键盘的方法新增参数,传入设备类型 (3.7:[3a6cb970](https://gitcode.com/openharmony-sig/flutter_engine/commit/3a6cb97069d405f6e3037d6645399881c17e5318?ref=feature-input&prId=765), 3.22:[19caf253](https://gitcode.com/openharmony-sig/flutter_engine/commit/19caf253a8b79cfcdda331815f675678fa05d25a?ref=feature-input-3.22&prId=768))
- 使能hwasan内存检查 (3.22:[7c6a33d8](https://gitcode.com/openharmony-sig/flutter_engine/commit/7c6a33d8e469ad2393b2cd9a4978ef191d7598c4?ref=enable-hwasan&prId=767))
- 修复同一个engineGroup的多engine场景下，只有一个engine能够正常切换字体问题 (3.22:[db7512c6](https://gitcode.com/openharmony-sig/flutter_engine/commit/db7512c6eaf9990eddc9bef9977df9d7511a66f9?ref=oh-3.22.0&prId=760))
- 修复在新机或者恢复出厂设置后的机器上首次切换字体失效问题 (3.22:[91a1b950](https://gitcode.com/openharmony-sig/flutter_engine/commit/91a1b95081eace16f2a797d0173aaae76dd68249?ref=oh-3.22.0&prId=757))
- Impeller简单遮挡剔除 (3.22:[f0905a86](https://gitcode.com/openharmony-sig/flutter_engine/commit/f0905a86a5dadefd00a0538fbd47bdd922e3b9cc?ref=occlusion_culling&prId=754))
- Impeller脏区渲染能力支持 (3.22:[d5b896c1](https://gitcode.com/openharmony-sig/flutter_engine/commit/d5b896c1a111bc1e1a28a52248ae4b83e4f4ea86?ref=oh-3.22.0))