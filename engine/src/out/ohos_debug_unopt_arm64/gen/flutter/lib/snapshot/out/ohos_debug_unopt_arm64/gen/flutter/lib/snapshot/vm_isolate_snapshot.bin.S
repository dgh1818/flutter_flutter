.section .rodata
.type kDartVmSnapshotData STT_OBJECT
.global kDartVmSnapshotData
.balign 32
kDartVmSnapshotData:
.incbin "/home/dgh18/engine10/src/out/ohos_debug_unopt_arm64/gen/flutter/lib/snapshot/vm_isolate_snapshot.bin"
.size kDartVmSnapshotData, .-kDartVmSnapshotData
