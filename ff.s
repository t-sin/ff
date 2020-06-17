	.text
	.global _start

sys_exit:
	mov	r7, #1	// sys_exit
	svc	#0

_start:
	mov	r0, #0
	bl	sys_exit
