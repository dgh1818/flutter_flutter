.section .rodata
.type kPlatformStrongDill STT_OBJECT
.global kPlatformStrongDill
.balign 32
kPlatformStrongDill:
.incbin "/home/dgh18/engine10/src/out/ohos_debug_unopt_arm64/flutter_patched_sdk/platform_strong.dill"
.size kPlatformStrongDill, .-kPlatformStrongDill
.global kPlatformStrongDillSize
kPlatformStrongDillSize:
.quad 9388264
