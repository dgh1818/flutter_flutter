.section .rodata
.type kKernelServiceDill STT_OBJECT
.global kKernelServiceDill
.balign 32
kKernelServiceDill:
.incbin "gen/kernel_service.dill"
.size kKernelServiceDill, .-kKernelServiceDill
.global kKernelServiceDillSize
kKernelServiceDillSize:
.quad 16484104
