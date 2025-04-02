.section .rodata
.type kDartIsolateSnapshotData STT_OBJECT
.global kDartIsolateSnapshotData
.balign 32
kDartIsolateSnapshotData:
.incbin "/home/dgh18/engine10/src/out/ohos_debug_unopt_arm64/gen/flutter/lib/snapshot/isolate_snapshot.bin"
.size kDartIsolateSnapshotData, .-kDartIsolateSnapshotData
