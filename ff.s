	.set	fd_stdin, 0
	.set	fd_stdout, 1

	.set	system_call_exit, 1
	.set	system_call_read, 3
	.set	system_call_write, 4

	.data
moji:
	.string "hoge\n"
io_buffer:
	.skip	512
io_buffer_size = . - io_buffer

input_buffer:
	.skip	1024
input_buffer_size = . - input_buffer

	.text
	.global	_start

syscall:
	svc	#0
	bx	lr

readline:
	mov	r8, #0	// init read size
readline_read:
	mov	r0, #fd_stdout
	ldr	r1, =moji
	mov	r2, #5
	mov	r7, #system_call_write
	bl	syscall
	
	mov	r0, #fd_stdin
	ldr	r1, =io_buffer
	ldr	r1, [r1, r8]
	mov	r2, #io_buffer_size
	mov	r7, #system_call_read
	bl	syscall

	cmp	r0, #0
        moveq	r0, r8
	bxeq	lr

	add	r9, r0, r8
	cmp	r9, #input_buffer_size
	movgt	r0, r9
	bxgt	lr

	mov	r8, r9
	// copy from iobuffer to input_buffer
	b	readline_read

_start:
	bl	readline

	mov	r0, #0
	mov	r7, #system_call_exit
	bl	syscall
