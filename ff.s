	.set	fd_stdin, 0
	.set	fd_stdout, 1

	.set	system_call_exit, 1
	.set	system_call_read, 3
	.set	system_call_write, 4

	.data

moji:
	.string "moji\n"
moji_len = . - moji

io_buffer:
	.skip	512, 0
io_buffer_size = . - io_buffer

input_buffer:
	.skip	1024, 0
input_buffer_size = . - input_buffer

	.text
	.global	_start

syscall:
	svc	#0
	bx	lr

// r0: from buffer
// r1: to buffer
// r2: offset
// r3: count
copy_buffer:
	mov	r4, #0
copy_buffer_loop:
	cmp	r4, r3
	bxeq	lr

	add	r5, r2, r4
	ldrb	r6, [r0, r4]
	strb	r6, [r1, r5]
	add	r4, r4, #1

	b	copy_buffer_loop

readline:
	mov	r8, #0	// init read size
readline_loop:
	// read from stdin to small io_buffer
	mov	r0, #fd_stdin
	ldr	r1, =io_buffer
	add	r1, r1, r8
	mov	r2, #io_buffer_size
	mov	r7, #system_call_read
	push	{lr}
	bl	syscall
	pop	{lr}
	mov	r9, r0

	// check number of byte read
	cmp	r9, #0
        moveq	r0, r8
        moveq	r1, #0
	bxeq	lr

	// check count of bytes read totally
	add	r10, r9, r8
	cmp	r10, #input_buffer_size
	movgt	r0, r10
	ldrgt	r1, =io_buffer
	bxgt	lr

	// copy io_buffer to input_buffer
	mov	r8, r10
	ldr	r0, =io_buffer
	ldr	r1, =input_buffer
	mov	r2, r8
	mov	r3, r9
	push	{lr, r8}
	bl	copy_buffer
	pop	{lr, r8}

	b	readline_loop

_start:
	bl	readline

	// print readline result
	mov	r2, #input_buffer_size
	mov	r0, #fd_stdout
	ldr	r1, =input_buffer
	mov	r7, #system_call_write
	bl	syscall

// 	mov	r0, #fd_stdout
//	ldr	r1, =moji
//	mov	r2, #moji_len
//	mov	r7, #system_call_write
//	bl	syscall

	mov	r0, #0
	mov	r7, #system_call_exit
	bl	syscall
