.text
.type kDartVmSnapshotInstructions STT_FUNC
.global kDartVmSnapshotInstructions
.balign 32
kDartVmSnapshotInstructions:
.incbin "/home/dgh18/engine10/src/out/ohos_debug_unopt_arm64/gen/flutter/lib/snapshot/vm_snapshot_instructions.bin"
.size kDartVmSnapshotInstructions, .-kDartVmSnapshotInstructions
